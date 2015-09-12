

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

var mutableActivitiesArray : NSMutableArray = []

class TRFActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Outlets and Variables
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivitiesTableView:", name:"load", object: nil)
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
            var activities: TRFActivity = mutableActivitiesArray[indexPath.row] as! TRFActivity
            cell.performanceLabel.text = activities.getPerformance()
            cell.competitionLabel.text = activities.getCompetition()
            cell.dateLabel.text = activities.getDate()
            cell.locationLabel.text = activities.getLocation()
            cell.notesLabel.text = activities.getNotes()
            cell.optionsButton.accessibilityValue = activities.getUserId()
        }
        return cell
    }
    
    func loadActivities(userId : String)
    {
        self.activitiesLoadingIndicator.startAnimating()

        TRFApiHandler.getAllActivitiesByUserId(userId, from: "", to: "", discipline:"")
        //.authenticate(user: "user@trafie.com", password: "123123")
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            println("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { (request, response, JSONObject, error) in
        println("request: \(request)")
        println("response: \(response)")
        println("JSONObject: \(JSONObject)")
        println("error: \(error)")
            
            //Clear activities array.
            //TODO: enhance functionality for minimum data transfer
            mutableActivitiesArray = []
            
            if (error == nil && JSONObject != nil) {
                self.activitiesArray = JSON(JSONObject!)
                // TODO: REFACTOR
                //JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
                for (index: String, activity: JSON) in self.activitiesArray {
                    var activityModel = TRFActivity(
                        userId: activity["_id"].stringValue,
                        discipline: activity["discipline"].stringValue,
                        performance: convertPerformanceToReadable(activity["performance"].stringValue, activity["discipline"].stringValue),
                        date: activity["date"].stringValue,
                        place: activity["place"].stringValue,
                        location: activity["location"].stringValue,
                        competition: activity["competition"].stringValue,
                        notes: activity["notes"].stringValue,
                        isPrivate: activity["private"].stringValue
                    )
                    
                     mutableActivitiesArray.addObject(activityModel)
                }
            } else {
                self.activitiesArray = []
                mutableActivitiesArray = []
            }
            
            self.reloadActivitiesTableView()
            println("self.activitiesArray.count -> \(self.activitiesArray.count)")
            
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
        var activityCompetition: String = ""
        var activityID: String = ""
        
        for (key, subJson) in self.activitiesArray {
            if let id = subJson["_id"].string {
                if id == sender.accessibilityValue {
                    activityID = id
                    if let location = subJson["competition"].string {
                        activityCompetition = location
                        println(activityCompetition)
                    }
                }
            }
        }

        // Alert Controller Instances
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let deletecVerificationAlert = UIAlertController(title: nil, message: "Are you sure you want to delete your performance from \(activityCompetition)?", preferredStyle: .Alert)
        
        // Actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive , handler: {
            (alert: UIAlertAction!) -> Void in
            self.presentViewController(deletecVerificationAlert, animated: true, completion: nil)
            println("Activity to Delete \(sender.accessibilityValue)")
        })

        let editAction = UIAlertAction(title: "Edit", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("File Edited")
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        let confirmAction = UIAlertAction(title: "OK", style: .Default , handler: {
            (alert: UIAlertAction!) -> Void in
            TRFApiHandler.deleteActivityById(testUserId, activityId: sender.accessibilityValue)
            .responseJSON { (request, response, JSONObject, error) in
//                println("request: \(request)")
//                println("response: \(response)")
//                println("JSONObject: \(JSONObject)")
                if let err = error
                {
                    // got an error while deleting, need to handle it
                    println("error calling DELETE on \(request.URL)")
                    println(err)
                    
                } else {
                    println("Activity Deleted Succesfully")
                    println(sender.accessibilityValue)
                    for var i = 0; i < mutableActivitiesArray.count; i++ {
                        if (mutableActivitiesArray[i] as! TRFActivity).getActivityId() == activityID {
                            mutableActivitiesArray.removeObjectAtIndex(i)
                        }
                    }
                    self.reloadActivitiesTableView()
                }
            }

            println("Deleted")
        })
        

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(editAction)
        optionMenu.addAction(cancelAction)
        
        deletecVerificationAlert.addAction(confirmAction)
        deletecVerificationAlert.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    

}
