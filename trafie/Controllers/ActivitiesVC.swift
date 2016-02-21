

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

    // TODO: move to Commons with the repeated logic in code
    let calendar = NSCalendar.currentCalendar()
    var userId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Notification Events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivitiesTableView:", name:"reloadActivities", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)

        Reach().monitorReachabilityChanges()
        Utils.log(">>>>>>>>>>>>>>>>>>>> \(Reach().connectionStatus())")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        
        //initialize editable mode to false.
        // TODO: check with enumeration for states
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
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")

        //let status = Reach().connectionStatus()
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
    
        // TODO: NEEDS TO BE FUNCTION
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        let finalDate: String = dateFormatter.stringFromDate(activity.getDate())
        
        //let discipline: String = activity.getDiscipline()
        
        cell.performanceLabel.text = activity.getReadablePerformance()
        //cell.disciplineLabel.text = NSLocalizedString(discipline, comment:"translation of discipline \(discipline)")
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
    
    func loadActivities(userId : String, isRefreshing : Bool?=false) {
        if (isRefreshing! == false) {
            self.activitiesLoadingIndicator.startAnimating()
            self.loadingActivitiesView.hidden = false
        }

        
        ApiHandler.getAllActivitiesByUserId(self.userId) // TODO: add from: lastFetchingActivitiesDate
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            Utils.log("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { request, response, result in
            switch result {
            case .Success(let JSONResponse):
                Utils.log(String(JSONResponse))
                //Clear activities array.
                //TODO: enhance functionality for minimum data transfer
                
                //TODO: enhance to work with timestamp
                let date = NSDate() // "Jul 23, 2014, 11:01 AM" <-- looks local without seconds. But:
                let formatter = NSDateFormatter()
                // TODO: Should be reomved somewhere else.
                //This defines the format of lastFetchingActivitiesDate which used in different places. (i.e refreshContoller)
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                lastFetchingActivitiesDate = formatter.stringFromDate(date)
                //lastFetchingActivitiesDate = "2015-11-20"

                self.activitiesArray = JSON(JSONResponse)
                // TODO: REFACTOR
                //JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
                for (_, activity):(String,JSON) in self.activitiesArray {
                    let activity = Activity(
                        userId: activity["userId"].stringValue,
                        activityId: activity["_id"].stringValue,
                        discipline: activity["discipline"].stringValue,
                        performance: activity["performance"].stringValue,
                        readablePerformance: Utils.convertPerformanceToReadable(activity["performance"].stringValue,
                        discipline: activity["discipline"].stringValue),
                        date: Utils.timestampToDate(activity["date"].stringValue),
                        rank: activity["rank"].stringValue,
                        location: activity["location"].stringValue,
                        competition: activity["competition"].stringValue,
                        notes: activity["notes"].stringValue,
                        isPrivate: activity["isPrivate"].stringValue == "false" ? false : true,
                        isOutdoor: activity["isOutdoor"].stringValue == "false" ? false : true
                    )

                    // add activity
                    // let yearOfActivity = activity.getDate().componentsSeparatedByString("-")[0]
                    addActivity(activity, section: String(self.calendar.components(.Year, fromDate: activity.getDate()).year))

                }
                
                //NOT SURE IF HERE IS THE BEST PLACE TO ADD THIS
                if self.activitiesArray.count == 0 {
                    self.activitiesTableView.emptyDataSetDelegate = self
                    self.activitiesTableView.emptyDataSetSource = self
                }

                self.reloadActivitiesTableView()
                Utils.log("self.activitiesArray.count -> \(self.activitiesArray.count)")
                
                // TODO: become function
                self.loadingActivitiesView.hidden = true
                self.activitiesLoadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
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
            self.refreshControl.attributedTitle = NSAttributedString(string: "Last Update: " + lastFetchingActivitiesDate)
            loadActivities(self.userId, isRefreshing: true)
        }
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

        func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
            return UIImage(named: "medal")
        }
    
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
        self.presentViewController(addActivityVC, animated: true, completion: nil)
    }
    
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
