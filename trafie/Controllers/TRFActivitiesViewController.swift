

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

//let testUserId = "5446517676d2b90200000015" //high jumper HEROKU
//let testUserId = "55eb09250ca74346850b56c3" //user@trafie.com LOCAL
let testUserId = "55eb0e269c6e3a5f870bc651" //lue_jacqui3889@trafie.com LOCAL

class TRFActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Outlets and Variables
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivitiesTableView:", name:"load", object: nil)
        
        //initialize editable mode to false.
        // TODO: check with enumeration for states
        isEditingActivity = false
        
        self.activitiesTableView.delegate = self;
        self.activitiesTableView.dataSource = self;

        self.activitiesTableView.estimatedRowHeight = 100
        self.activitiesTableView.rowHeight = UITableViewAutomaticDimension //automatic resize cells
        self.activitiesTableView.contentInset = UIEdgeInsetsZero //table view reaches the ui edges
        
        //Pull down to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.activitiesTableView.addSubview(refreshControl)

        //get user's activities
        loadActivities(testUserId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mutableActivitiesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityTableCell", forIndexPath: indexPath) as! TRFActivtitiesTableViewCell

        if mutableActivitiesArray.count > 0 && mutableActivitiesArray.count >= indexPath.row
        {
            let activity: TRFActivity = mutableActivitiesArray[indexPath.row] as! TRFActivity
            
            // TODO: NEEDS TO BE FUNCTION
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let activityDate: String = activity.getDate()
            let dateShow : NSDate = dateFormatter.dateFromString(activityDate)!
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let finalDate: String = dateFormatter.stringFromDate(dateShow)
            
            cell.performanceLabel.text = activity.getReadablePerformance()
            cell.competitionLabel.text = activity.getCompetition()
            cell.dateLabel.text = finalDate
            cell.locationLabel.text = activity.getLocation()
            cell.notesLabel.text = activity.getNotes()
            cell.optionsButton.accessibilityValue = activity.getUserId()
        }
        return cell
    }
    
    func loadActivities(userId : String)
    {
        self.activitiesLoadingIndicator.startAnimating()

        TRFApiHandler.getAllActivitiesByUserId(userId, from: "", to: "", discipline:"")
        //.authenticate(user: "user@trafie.com", password: "123123")
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            print("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { response in
//        print("request: \(request)")
        print("response: \(response)")
//        print("JSONObject: \(result)")
            
            //Clear activities array.
            //TODO: enhance functionality for minimum data transfer
            mutableActivitiesArray = []
            
//            if (JSONObject != nil) {
//                self.activitiesArray = JSON(JSONObject)
//                // TODO: REFACTOR
//                //JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
//                for (index, activity):(String,JSON) in self.activitiesArray {
//                    var activityModel = TRFActivity(
//                        userId: activity["_id"].stringValue,
//                        discipline: activity["discipline"].stringValue,
//                        performance: activity["performance"].stringValue,
//                        readablePerformance: convertPerformanceToReadable(activity["performance"].stringValue, discipline: activity["discipline"].stringValue),
//                        date: activity["date"].stringValue,
//                        place: activity["place"].stringValue,
//                        location: activity["location"].stringValue,
//                        competition: activity["competition"].stringValue,
//                        notes: activity["notes"].stringValue,
//                        isPrivate: activity["private"].stringValue
//                    )
//                    
//                     mutableActivitiesArray.addObject(activityModel)
//                }
//            } else {
//                self.activitiesArray = []
//                mutableActivitiesArray = []
//            }
            
            self.reloadActivitiesTableView()
            print("self.activitiesArray.count -> \(self.activitiesArray.count)")
            
            self.activitiesLoadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
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
        loadActivities(testUserId)
    }
    
    @IBAction func activityOptionsActionSheet(sender: UIButton) {
        let activity : TRFActivity = getActivityFromActivitiesArrayById(sender.accessibilityValue!)
 
        // Alert Controller Instances
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let deletecVerificationAlert = UIAlertController(title: nil, message: "Are you sure you want to delete your performance from \(activity.getCompetition())?", preferredStyle: .Alert)
        
        // Actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive , handler: {
            (alert: UIAlertAction!) -> Void in
            self.presentViewController(deletecVerificationAlert, animated: true, completion: nil)
            print("Activity to Delete \(sender.accessibilityValue)")
        })

        let editAction = UIAlertAction(title: "Edit", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            isEditingActivity = true
            
            // TODO: get parameters from activitiesArray in ViewDidLoad AND COMPLETE EDITING ACTIVITY
            editingActivityID = sender.accessibilityValue!

            //open edit activity view
            let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
            self.presentViewController(next, animated: true, completion: nil)
            print("Choose to Edit")
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        let confirmAction = UIAlertAction(title: "OK", style: .Default , handler: {
            (alert: UIAlertAction!) -> Void in
            TRFApiHandler.deleteActivityById(testUserId, activityId: sender.accessibilityValue!)
            .responseJSON { response in
//                print("request: \(request)")
//                print("response: \(response)")
//                print("JSONObject: \(JSONObject)")
//                if let err = error
//                {
//                    // got an error while deleting, need to handle it
//                    print("error calling DELETE on \(request!.URL)")
//                    print(err)
//                    
//                } else {
//                    print("Activity Deleted Succesfully")
//                    print(sender.accessibilityValue)
//                    for var i = 0; i < mutableActivitiesArray.count; i++ {
//                        if (mutableActivitiesArray[i] as! TRFActivity).getActivityId() == activity.getActivityId() {
//                            mutableActivitiesArray.removeObjectAtIndex(i)
//                        }
//                    }
//                    self.reloadActivitiesTableView()
//                }
            }

            print("Deleted")
        })
        

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(editAction)
        optionMenu.addAction(cancelAction)
        
        deletecVerificationAlert.addAction(confirmAction)
        deletecVerificationAlert.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    

}
