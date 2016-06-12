

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


class ActivitiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIViewControllerTransitioningDelegate  {

    // MARK:- Outlets and Variables
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingActivitiesView: UIView!
    @IBOutlet weak var addActivityBarButton: UIBarButtonItem!

    var refreshControl: UIRefreshControl!
    var addActivityVC: UINavigationController!
    var userId : String = ""
    
    private let animationController = DAExpandAnimation()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        if self.userId == "" {
            let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
            self.presentViewController(loginVC, animated: true, completion: nil)
        }
        
        DBInterfaceHandler.fetchUserActivitiesFromServer(self.userId)
        
//        let name = "iOS : Activities ViewController"
        
        // [START screen_view_hit_swift]
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
        // [END screen_view_hit_swift]
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
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ActivitiesVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.activitiesTableView.addSubview(refreshControl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Checks the number of activities and if user has validate his email. 
     If both are true
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
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        self.toggleUIElementsBasedOnNetworkStatus()
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsOfActivities.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsOfActivities[sortedSections[section]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("activityTableCell") as! ActivtitiesTableViewCell
        let tableSection = sectionsOfActivities[sortedSections[indexPath.section]]
        
        let activity: Activity = tableSection![indexPath.row]
    
        dateFormatter.dateFormat = "MMM d"
        let finalDate: String = dateFormatter.stringFromDate(activity.getDate())
        
        cell.performanceLabel.text = activity.getReadablePerformance()
        cell.competitionLabel.text = activity.getCompetition()
        cell.dateLabel.text = finalDate
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cellToSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cellToSelect.contentView.backgroundColor = UIColor.whiteColor()
        
        let tableSection = sectionsOfActivities[sortedSections[indexPath.section]]
        let activity: Activity = tableSection![indexPath.row]
        viewingActivityID = activity.getActivityId()
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedSections[section]
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("activityTableCellHeader") as! ActivitiesTableViewCellHeader
        headerCell.backgroundColor = CLR_LIGHT_GRAY
        headerCell.headerTitle.font = UIFont.systemFontOfSize(22)
        headerCell.headerTitle.textColor = CLR_DARK_GRAY
        headerCell.headerTitle.text = sortedSections[section]
        
        return headerCell
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

        ApiHandler.getAllActivitiesByUserId(self.userId, updatedFrom: lastFetchTimestamp)
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            Utils.log("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { request, response, result in
            Utils.showNetworkActivityIndicatorVisible(false)
            switch result {
            case .Success(let JSONResponse):
                Utils.log(String(JSONResponse))
                Utils.log("Response with code \(response?.statusCode)")
                
                if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                    let date = NSDate()
                    // This defines the format of lastFetchingActivitiesDate which used in different places. (i.e refreshContoller)
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    lastFetchingActivitiesDate = dateFormatter.stringFromDate(date)

                    self.activitiesArray = JSON(JSONResponse)
                    // JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
                    for (_, activity):(String,JSON) in self.activitiesArray {
                        let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
                        let _readablePerformance = activity["isOutdoor"]
                            ? Utils.convertPerformanceToReadable(activity["performance"].stringValue,
                                discipline: activity["discipline"].stringValue,
                                measurementUnit: selectedMeasurementUnit)
                            : Utils.convertPerformanceToReadable(activity["performance"].stringValue,
                                discipline: activity["discipline"].stringValue,
                                measurementUnit: selectedMeasurementUnit) + "i"

                        let _activity = Activity(
                            userId: activity["userId"].stringValue,
                            activityId: activity["_id"].stringValue,
                            discipline: activity["discipline"].stringValue,
                            performance: activity["performance"].stringValue,
                            readablePerformance: _readablePerformance,
                            date: activity["date"] != nil ? Utils.timestampToDate(activity["date"].stringValue) : NSDate(),
                            rank: activity["rank"].stringValue,
                            location: activity["location"].stringValue,
                            competition: activity["competition"].stringValue,
                            notes: activity["notes"].stringValue,
                            isPrivate: activity["isPrivate"].stringValue == "false" ? false : true,
                            isOutdoor: activity["isOutdoor"] ? true : false
                        )
                        
                        if (activity["isDeleted"].stringValue == "true") {
                            let oldKey = String(currentCalendar.components(.Year, fromDate: _activity.getDate()).year)
                            removeActivity(_activity, section: oldKey)
                        } else {
                            // add activity
                            addActivity(_activity, section: String(currentCalendar.components(.Year, fromDate: _activity.getDate()).year))
                        }
                    }
                    
                    if self.activitiesArray.count == 0 {
                        self.activitiesTableView.emptyDataSetDelegate = self
                        self.activitiesTableView.emptyDataSetSource = self
                    }
                    
                    self.reloadActivitiesTableView()
                    Utils.log("self.activitiesArray.count -> \(self.activitiesArray.count)")
                    
                    self.loadingActivitiesView.hidden = true
                    self.activitiesLoadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                } else {
                    SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                }

            case .Failure(let data, let error):
                Utils.log("Request failed with error: \(error)")
                self.activitiesArray = []
                sectionsOfActivities = Dictionary<String, Array<Activity>>()
                sortedSections = [String]()

                if let data = data {
                    Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }

    /**
     Request all activities of user from local DB.
     
     - Parameter userId: the id of user we want to fetch the activities
     */
    func loadActivitiesFromDB(userId : String, isRefreshing : Bool?=false) {
        activitiesRealm = uiRealm.objects(ActivityMaster)
        Utils.log("-------loadActivitiesFromDB----- \(activitiesRealm)")
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
        self.loadActivitiesFromDB(self.userId)
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
