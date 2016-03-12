

//
//  ActivitiesViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet

class ActivitiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    // MARK:- Outlets and Variables
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingActivitiesView: UIView!
    
    var refreshControl: UIRefreshControl!
    var addActivityVC: UINavigationController!
    var userId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Notification Events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivitiesTableView:", name:"reloadActivities", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)

        Reach().monitorReachabilityChanges()
        Utils.log("\(Reach().connectionStatus())")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        
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
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.activitiesTableView.addSubview(refreshControl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- Network Connection
    /**
        Handles notification for Network status changes
    */
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
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
    
        dateFormatter.dateStyle = .MediumStyle
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
        ApiHandler.getAllActivitiesByUserId(self.userId, from: lastFetchTimestamp)
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            Utils.log("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { request, response, result in
            Utils.showNetworkActivityIndicatorVisible(false)
            switch result {
            case .Success(let JSONResponse):
                Utils.log(String(JSONResponse))
                Utils.log("Response with code \(response?.statusCode)")
                
                if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                    let date = NSDate()
                    // This defines the format of lastFetchingActivitiesDate which used in different places. (i.e refreshContoller)
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    lastFetchingActivitiesDate = dateFormatter.stringFromDate(date)

                    self.activitiesArray = JSON(JSONResponse)
                    // JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
                    for (_, activity):(String,JSON) in self.activitiesArray {
                        let _readablePerformance = activity["isOutdoor"]
                            ? Utils.convertPerformanceToReadable(activity["performance"].stringValue, discipline: activity["discipline"].stringValue)
                            : Utils.convertPerformanceToReadable(activity["performance"].stringValue, discipline: activity["discipline"].stringValue) + "i"

                        let activity = Activity(
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
                        
                        // add activity
                        addActivity(activity, section: String(currentCalendar.components(.Year, fromDate: activity.getDate()).year)) 
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

    // MARK:- Empty State handling
    /// Defines the text and the appearance for empty state title.
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Your history will be displayed here!"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    /// Defines the image for empty state
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "medal")
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
        let text = "You can add your first activity here, \n or by tapping '+' on top right"
        
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
