

//
//  TRFActivitiesViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet

var userId : String = ""

class TRFActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    // MARK:- Outlets and Variables
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingActivitiesView: UIView!
    
    var refreshControl:UIRefreshControl!
    // TODO: move to Commons with the repeated logic in code
    let calendar = NSCalendar.currentCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Notification Events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivitiesTableView:", name:"reloadActivities", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
        print(">>>>>>>>>>>>>>>>>>>> \(Reach().connectionStatus())")
        
        //initialize editable mode to false.
        // TODO: check with enumeration for states
        isEditingActivity = false
        userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        
        self.activitiesTableView.delegate = self;
        self.activitiesTableView.dataSource = self;
        //get user's activities
        loadingActivitiesView.hidden = true
        loadActivities(userId)

        self.activitiesTableView.estimatedRowHeight = 100
        self.activitiesTableView.rowHeight = UITableViewAutomaticDimension //automatic resize cells
        self.activitiesTableView.contentInset = UIEdgeInsetsZero //table view reaches the ui edges
        self.activitiesTableView.tableFooterView = UIView() // A little trick for removing the cell separators
        

        //Pull down to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.activitiesTableView.addSubview(refreshControl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Network Connection
    func networkStatusChanged(notification: NSNotification) {
        print("networkStatusChanged to \(notification.userInfo)")
        
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            print("Not connected")
        case .Online(.WWAN):
            print("Connected via WWAN")
        case .Online(.WiFi):
            print("Connected via WiFi")
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("activityTableCell") as! TRFActivtitiesTableViewCell
        let tableSection = sectionsOfActivities[sortedSections[indexPath.section]]
        
        // image for option button
        let optionImage = UIImage(named:"ic_more_horiz")?.imageWithRenderingMode(
            UIImageRenderingMode.AlwaysTemplate)

        let activity: TRFActivity = tableSection![indexPath.row] 
    
        // TODO: NEEDS TO BE FUNCTION
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let activityDate: NSDate = activity.getDate()
        let dateShow : NSDate = activityDate //dateFormatter.dateFromString(activityDate)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let finalDate: String = dateFormatter.stringFromDate(dateShow)
        
        let discipline: String = activity.getDiscipline()
        
        cell.performanceLabel.text = activity.getReadablePerformance()
        cell.disciplineLabel.text = NSLocalizedString(discipline, comment:"translation of discipline \(discipline)")
        cell.rankLabel.text = activity.getRank()
        cell.competitionLabel.text = activity.getCompetition()
        cell.dateLabel.text = finalDate
        cell.locationLabel.text = activity.getLocation()
        cell.notesLabel.text = activity.getNotes()

        cell.optionsButton.accessibilityValue = activity.getActivityId()
        cell.optionsButton.tintColor = UIColor(white:0, alpha:0.50)
        cell.optionsButton.setImage(optionImage, forState:UIControlState.Normal)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedSections[section]
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("activityTableCellHeader") as! TRFActivtitiesTableViewCellHeader
        headerCell.backgroundColor = CLR_LIGHT_GRAY
        headerCell.headerTitle.font = UIFont.systemFontOfSize(22)
        headerCell.headerTitle.textColor = CLR_DARK_GRAY
        headerCell.headerTitle.text = sortedSections[section]
        
        return headerCell
    }
    
    func loadActivities(userId : String, isRefreshing : Bool?=false) {
        if (isRefreshing! == false) {
            self.activitiesLoadingIndicator.startAnimating()
            self.loadingActivitiesView.hidden = false
        }

        
        TRFApiHandler.getAllActivitiesByUserId(userId, from: lastFetchingActivitiesDate, to: "", discipline:"")
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            print("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { request, response, result in
            switch result {
            case .Success(let JSONResponse):
                print("--- Success ---")
                print("request >>> \(request)")
                //Clear activities array.
                //TODO: enhance functionality for minimum data transfer
                
                let date = NSDate() // "Jul 23, 2014, 11:01 AM" <-- looks local without seconds. But:
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                lastFetchingActivitiesDate = formatter.stringFromDate(date);
                //lastFetchingActivitiesDate = "2015-11-20"

                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                //print(JSONResponse)
                self.activitiesArray = JSON(JSONResponse)
                // TODO: REFACTOR
                //JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
                for (_, activity):(String,JSON) in self.activitiesArray {
                    print(activity)
                    let activity = TRFActivity(
                        userId: activity["userId"].stringValue,
                        activityId: activity["_id"].stringValue,
                        discipline: activity["discipline"].stringValue,
                        performance: activity["performance"].stringValue,
                        readablePerformance: convertPerformanceToReadable(activity["performance"].stringValue,
                        discipline: activity["discipline"].stringValue),
                        date: dateFormatter.dateFromString(activity["date"].stringValue)!,
                        rank: activity["rank"].stringValue,
                        location: activity["location"].stringValue,
                        competition: activity["competition"].stringValue,
                        notes: activity["notes"].stringValue,
                        isPrivate: activity["private"].stringValue
                    )

                    // add activity
                    // let yearOfActivity = activity.getDate().componentsSeparatedByString("-")[0]
                    addActivity(activity, section: String(self.calendar.components(.Year, fromDate: activity.getDate()).year))

                }
                
                //NOT SURE IF HERE IS THE BEST PLACE TO ADD THIS
                if self.activitiesArray.count == 0 {
                    self.activitiesTableView.emptyDataSetDelegate = self;
                    self.activitiesTableView.emptyDataSetSource = self;
                }

                self.reloadActivitiesTableView()
                print("self.activitiesArray.count -> \(self.activitiesArray.count)")
                
                // TODO: become function
                self.loadingActivitiesView.hidden = true
                self.activitiesLoadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
            case .Failure(let data, let error):
                print("Request failed with error: \(error)")
                self.activitiesArray = []
                sectionsOfActivities = Dictionary<String, Array<TRFActivity>>()
                sortedSections = [String]()

                if let data = data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }

    
    @objc private func reloadActivitiesTableView(notification: NSNotification){
        self.activitiesTableView.reloadData()
    }
    
    func reloadActivitiesTableView(){
        self.activitiesTableView.reloadData()
    }
    
    func refresh(sender:AnyObject)
    {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            self.refreshControl.attributedTitle = NSAttributedString(string: "You are Offline")
            self.refreshControl.endRefreshing()
        default:
            self.refreshControl.attributedTitle = NSAttributedString(string: "Loading the awesomeness!")
            loadActivities(userId, isRefreshing: true)
        }
    }
    
    @IBAction func activityOptionsActionSheet(sender: UIButton) {
        let activity : TRFActivity = getActivityFromActivitiesArrayById(sender.accessibilityValue!)
 
        // Alert Controller Instances
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let deleteVerificationAlert = UIAlertController(title: nil, message: "Are you sure you want to delete your performance from \(activity.getCompetition())?", preferredStyle: .Alert)
        
        // Actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive , handler: {
            (alert: UIAlertAction) -> Void in
            self.presentViewController(deleteVerificationAlert, animated: true, completion: nil)
            print("Activity to Delete \(sender.accessibilityValue)", terminator: "")
        })

        let editAction = UIAlertAction(title: "Edit", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            
            isEditingActivity = true
            
            // TODO: get parameters from activitiesArray in ViewDidLoad AND COMPLETE EDITING ACTIVITY
            editingActivityID = sender.accessibilityValue!

            //open edit activity view
            let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
            self.presentViewController(next, animated: true, completion: nil)
            print("Choose to Edit", terminator: "")
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled", terminator: "")
        })
        
        let confirmDeletion = UIAlertAction(title: "OK", style: .Default , handler: {
            (alert: UIAlertAction!) -> Void in
            TRFApiHandler.deleteActivityById(userId, activityId: sender.accessibilityValue!)
            .responseJSON { request, response, result in
                switch result {
                case .Success(_):
                    print("Activity \"\(sender.accessibilityValue)\" Deleted Succesfully")
                    print(sender.accessibilityValue)

                    let oldKey = String(self.calendar.components(.Year, fromDate: activity.getDate()).year) //activity.getDate().componentsSeparatedByString("-")[0]
                    removeActivity(activity, section: oldKey)
                    // remove id from activitiesIdTable
                    for var i=0; i < activitiesIdTable.count; i++ {
                        if activitiesIdTable[i] == activity.getActivityId() {
                            activitiesIdTable.removeAtIndex(i)
                            break
                        }
                    }

                    self.reloadActivitiesTableView()
                case .Failure(let data, let error):
                    print("Request for deletion failed with error: \(error)")
                    self.activitiesArray = []
                    cleanSectionsOfActivities()

                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
            }
        })
        

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(editAction)
        optionMenu.addAction(cancelAction)
        
        deleteVerificationAlert.addAction(confirmDeletion)
        deleteVerificationAlert.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    // MARK:- Empty State handling
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Your history will be displayed here!"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }

    //    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
    //        return UIImage(named: "empty-book")
    //    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(19.0),
            NSForegroundColorAttributeName: CLR_DARK_GRAY
        ]
        
        return NSAttributedString(string: "Add Your First Activity", attributes:attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(rgba: "#ffffff")
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddEditActivityController") as! UINavigationController
        
        self.presentViewController(activitiesVC, animated: true, completion: nil)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You can add your first activity here, or by tapping '+' on top right"
        
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
