

//
//  ActivitiesViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Alamofire
import DZNEmptyDataSet
import RealmSwift


class ActivitiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIViewControllerTransitioningDelegate, RealmResultsControllerDelegate  {

    // MARK:- Outlets and Variables
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingActivitiesView: UIView!
    @IBOutlet weak var addActivityBarButton: UIBarButtonItem!

    private let animationController = DAExpandAnimation()

    var refreshControl: UIRefreshControl = UIRefreshControl()
    var addActivityVC: UINavigationController!
    var userId : String = ""
    
    
    var rrc: RealmResultsController<ActivityModelObject, ActivityObject>?

// TODO: consider if need to add custom configuration
//    lazy var realmConfiguration: Realm.Configuration = {
//        guard let doc = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first else {
//            return Realm.Configuration.defaultConfiguration
//        }
//        let custom = doc.stringByAppendingString("/example.realm")
//        return Realm.Configuration(fileURL: NSURL(string: custom))
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let name = "iOS : Activities ViewController"
        Utils.googleViewHitWatcher(name);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Notification Events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivitiesVC.reloadActivitiesTableView(_:)), name:"reloadActivities", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivitiesVC.networkStatusChanged(_:)), name: ReachabilityStatusChangedNotification, object: nil)

        Reach().monitorReachabilityChanges()
        Utils.log("\(Reach().connectionStatus())")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        toggleUIElementsBasedOnNetworkStatus()

        //initialize editable mode to false.
        isEditingActivity = false
        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        
        self.activitiesTableView.delegate = self
        self.activitiesTableView.dataSource = self
        //get user's activities
        loadingActivitiesView.hidden = true
        loadActivities(self.userId)

        self.activitiesTableView.estimatedRowHeight = 100
        self.activitiesTableView.rowHeight = UITableViewAutomaticDimension //automatic resize cells
        self.activitiesTableView.contentInset = UIEdgeInsetsZero //table view reaches the ui edges
        self.activitiesTableView.tableFooterView = UIView() // A little trick for removing the cell separators
        
        // View Controllers
        addActivityVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddEditActivityController") as! UINavigationController


        //Pull down to refresh
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ActivitiesVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.activitiesTableView.addSubview(refreshControl)
        
        ///Realm
        let request = RealmRequest<ActivityModelObject>(predicate: NSPredicate(value: true), realm: uiRealm, sortDescriptors: [SortDescriptor(property: "year"), SortDescriptor(property: "date")])
        rrc = try! RealmResultsController<ActivityModelObject, ActivityObject>(request: request, sectionKeyPath: "year", mapper: ActivityObject.map)
        rrc!.delegate = self
        rrc!.performFetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table view protocols
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let num: Int = (rrc != nil) ? rrc!.numberOfSections : 0
        return num
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num: Int = (rrc != nil) ? rrc!.numberOfObjectsAt(section) : 0
        return num
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("activityTableCell") as! ActivtitiesTableViewCell
        //let tableSection = sectionsOfActivities[sortedSections[indexPath.section]]

        let activity = rrc!.objectAt(indexPath)
        
        dateFormatter.dateFormat = "MMM d YYYY"
        let finalDate: String = dateFormatter.stringFromDate(activity.date)
        
        cell.performanceLabel.text = activity.readablePerformance
        cell.competitionLabel.text = activity.competition
        cell.dateLabel.text = finalDate
        cell.notSyncedLabel.hidden = !activity.isDraft
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cellToSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cellToSelect.contentView.backgroundColor = UIColor.whiteColor()

        let _activity: ActivityObject = rrc!.objectAt(indexPath)
        viewingActivityID = _activity.activityId!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keyPath: String = (rrc != nil) ? rrc!.sections[section].keyPath : "Year..."
        return "\(keyPath)"
    }
    
    // footer
//    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return section == 2 ? "Tap on a row to delete it" : nil
//    }
    
    // MARK: RealmResult
    
    func willChangeResults(controller: AnyObject) {
        print("🎁 WILLChangeResults")
        activitiesTableView.beginUpdates()
    }
    
    func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        Utils.log("🎁 didChangeObject '\((object as! ActivityModelObject).competition)' from: [\(oldIndexPath.section):\(oldIndexPath.row)] to: [\(newIndexPath.section):\(newIndexPath.row)] --> \(changeType)")
        switch changeType {
        case .Delete:
            activitiesTableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Insert:
            activitiesTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Move:
            activitiesTableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            activitiesTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Update:
            activitiesTableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        }
    }
    
    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        Utils.log("🎁 didChangeSection \(index) --> \(changeType)")
        switch changeType {
        case .Delete:
            activitiesTableView.deleteSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Insert:
            activitiesTableView.insertSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            break
        }
    }
    
    func didChangeResults(controller: AnyObject) {
        Utils.log("🎁 DIDChangeResults")
        activitiesTableView.endUpdates()
    }

    
    /**
     Checks the number of activities and if user has validate his email. 
     If both are true allows him to create new activity
     */
    @IBAction func openAddActivity(sender: AnyObject) {
        let numberOfActivities = activitiesIdTable.count
        let isVerified: Bool = NSUserDefaults.standardUserDefaults().boolForKey("isVerified")
        if !isVerified && numberOfActivities == MAX_NUMBER_OF_ACTIVITIES_BEFORE_VERIFIED {
            SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more than 10 activities.", style: AlertStyle.Error)
        } else {
            let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
            self.presentViewController(next, animated: true, completion: nil)
        }
    }
    
    
    // MARK:- Network Connection
    /**
        Handles notification for Network status changes
    */
    func networkStatusChanged(notification: NSNotification) {
//        Utils.log("networkStatusChanged to \(notification.userInfo)")
//        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
//        self.toggleUIElementsBasedOnNetworkStatus()
    }
    
    /// Toggles UI Elements based on network status
    func toggleUIElementsBasedOnNetworkStatus() {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            self.addActivityBarButton.enabled = false
        case .Online(.WWAN), .Online(.WiFi):
            self.addActivityBarButton.enabled = true
        }
    }
    
    // MARK:- Table View Methods
    
    /**
     Tries to sync local activity with one from the server
     
     - Parameter activityId: the id of activity we want to sync
     If activity is existed and edited we compared the two dates and keep the latest one.
     */
    func syncActivity(activityId: AnyObject) {
        // TODO:process only when network is available
        setNotificationState(.Info, notification: statusBarNotification, style:.NavigationBarNotification)
        statusBarNotification.displayNotificationWithMessage("Syncing activity...", completion: {})

        if activityId is NSUUID { // Newly created activity. Doesn't yet exist in server
            let localActivity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: activityId)
            /// activity to post to server
            let activity: [String:AnyObject] = ["discipline": String(localActivity!.discipline),
                            "performance": localActivity!.performance!,
                            "date": localActivity!.date,
                            "rank": localActivity!.rank!,
                            "location": localActivity!.location!,
                            "competition": localActivity!.competition!,
                            "notes": localActivity!.notes!,
                            "isOutdoor": localActivity!.isOutdoor,
                            "isPrivate": localActivity!.isPrivate ]

            Utils.showNetworkActivityIndicatorVisible(true)
            ApiHandler.postActivity(self.userId, activityObject: activity)
                .responseJSON { request, response, result in
                    
                    Utils.showNetworkActivityIndicatorVisible(false)
                    switch result {
                    case .Success(let JSONResponse):
                        let responseJSONObject = JSON(JSONResponse)
                        if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                            Utils.log("\(request)")
                            Utils.log("\(JSONResponse)")
                            
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            
                            let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
                            let _readablePerformance = responseJSONObject["isOutdoor"]
                                ? Utils.convertPerformanceToReadable(responseJSONObject["performance"].stringValue,
                                    discipline: responseJSONObject["discipline"].stringValue,
                                    measurementUnit: selectedMeasurementUnit)
                                : Utils.convertPerformanceToReadable(responseJSONObject["performance"].stringValue,
                                    discipline: responseJSONObject["discipline"].stringValue,
                                    measurementUnit: selectedMeasurementUnit) + "i"
                            
                            // delete draft from realm
                            try! uiRealm.write {
                                uiRealm.deleteNotified(localActivity!)
                            }

                            let _syncedActivity = ActivityModelObject(value: [
                                "userId": responseJSONObject["userId"].stringValue,
                                "activityId": responseJSONObject["_id"].stringValue,
                                "discipline": responseJSONObject["discipline"].stringValue,
                                "performance": responseJSONObject["performance"].stringValue,
                                "readablePerformance": _readablePerformance,
                                "date": Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                "dateUnixTimestamp": responseJSONObject["date"].stringValue,
                                "rank": responseJSONObject["rank"].stringValue,
                                "location": responseJSONObject["location"].stringValue,
                                "competition": responseJSONObject["competition"].stringValue,
                                "notes": responseJSONObject["notes"].stringValue,
                                "isDeleted": responseJSONObject["isDeleted"] ? true : false,
                                "isOutdoor": responseJSONObject["isOutdoor"] ? true : false,
                                "isPrivate": responseJSONObject["isPrivate"] ? true : false,
                                "isDraft": false ])
                            // save activity from server
                            _syncedActivity.update()

                            SweetAlert().showAlert("Great!", subTitle: "Activity synced.", style: AlertStyle.Success)
                            Utils.log("Activity Synced: \(_syncedActivity)")
                            
                            self.dismissViewControllerAnimated(false, completion: {})
                        } else {
                            if let errorCode = responseJSONObject["errors"][0]["code"].string { //under 403 statusCode
                                if errorCode == "non_verified_user_activity_limit" {
                                    SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more activities.", style: AlertStyle.Error)
                                }
                            } else {
                                SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                            }
                        }
                        
                    case .Failure(let data, let error):
                        Utils.log("Request failed with error: \(error)")
                        SweetAlert().showAlert("Still locally.", subTitle: "Activity couldn't synced. Try again when internet is available.", style: AlertStyle.Warning)
                        self.dismissViewControllerAnimated(false, completion: {})
                        if let data = data {
                            Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
                    // Dismissing status bar notification
                    statusBarNotification.dismissNotification()
            }
        } else { // Existed activity. Need to be synced with server.

            Utils.log("Existed activity. need to be synced with server")
        }
        
        
    }
    
    
    /**
     TODO: rename to loadActivitiesFromServer

     Request all activities of user from server.
     If is refreshing shows an indication.

     - Parameter userId: the id of user we want to fetch the activities
     - Parameter isRefreshing: boolean for refreshing state. Default false.
    */
    func loadActivities(userId : String, isRefreshing : Bool?=false) {
        if (isRefreshing! == false) {
            self.activitiesLoadingIndicator.startAnimating()
            self.loadingActivitiesView.hidden = false
        }
        
        /// We request data from server only with unix timestamp
        let lastFetchTimestamp: String = lastFetchingActivitiesDate != "" ?
            String(Utils.dateToTimestamp(lastFetchingActivitiesDate.stringByReplacingOccurrencesOfString(" ", withString: "T"))) : ""

        Utils.showNetworkActivityIndicatorVisible(true)
        DBInterfaceHandler.fetchUserActivitiesFromServer(self.userId, updatedFrom: lastFetchTimestamp)
        self.loadingActivitiesView.hidden = true
        self.activitiesLoadingIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    /**
     Called from notification event in order to sync the activities table view with it's data.
    */
    @objc private func reloadActivitiesTableView(notification: NSNotification){
        self.activitiesTableView.reloadData()
    }
    
    /**
     Called explicitly in order to sync the activities table view with it's data.
    */
    func reloadActivitiesTableView(){
        self.activitiesTableView.reloadData()
    }
    
    /**
     Called when activity list is going to be refreshed. Checks the connectivity 
     and adjust accordingly the ui of refreshController.
    */
    func refresh(sender:AnyObject)
    {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            self.refreshControl.attributedTitle = NSAttributedString(string: "You are Offline")
            self.refreshControl.endRefreshing()
        default:
            self.refreshControl.attributedTitle = NSAttributedString(string: "Last Update: " + lastFetchingActivitiesDate)
            loadActivities(self.userId, isRefreshing: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController
        
        if let selectedCell = sender as? UITableViewCell {
            toViewController.transitioningDelegate = self
            toViewController.modalPresentationStyle = .Custom
            toViewController.view.backgroundColor = UIColor.blackColor()
            
            animationController.collapsedViewFrame = {
                return selectedCell.frame
            }
            animationController.animationDuration = 0.5
            
            if let indexPath = activitiesTableView.indexPathForCell(selectedCell) {
                activitiesTableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }

    // MARK:- Empty State handling
    /// Defines the text and the appearance for empty state title.
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Too quiet in here..."
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    /// Defines the image for empty state
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "activities_empty_state")
    }
    
    ///Defines the text and appearance of empty state's button
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(19.0),
            NSForegroundColorAttributeName: CLR_DARK_GRAY
        ]
        
        return NSAttributedString(string: "Add Your First Activity", attributes:attributes)
    }
    
    /// Background color for empty state
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(rgba: "#ffffff")
    }
    
    /// Handles the action for empty states button
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.presentViewController(addActivityVC, animated: true, completion: nil)
    }
    
    /// Defines the text and the appearance for the description text in empty state
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add your first activity \n by tapping on the add button."
        
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = NSLineBreakMode.ByWordWrapping
        para.alignment = NSTextAlignment.Center
        
        let attribs = [
            NSFontAttributeName: UIFont.systemFontOfSize(14),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: para
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
}
