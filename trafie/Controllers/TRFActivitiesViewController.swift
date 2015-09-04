

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

let testUserId = "5446517676d2b90200000015" //high jumper - full data

class TRFActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets and Variables
    let activities = TRFActivity()
    var activitiesArray : JSON = []
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activitiesLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesTableView.delegate = self;
        self.activitiesTableView.dataSource = self;

        self.activitiesTableView.estimatedRowHeight = 100
        self.activitiesTableView.rowHeight = UITableViewAutomaticDimension //automatic resize cells
        self.activitiesTableView.contentInset = UIEdgeInsetsZero //table view reaches the ui edges

        //get user's activities
        loadActivities(testUserId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activitiesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityTableCell", forIndexPath: indexPath) as! TRFActivtitiesTableViewCell

        if self.activitiesArray != nil && self.activitiesArray.count >= indexPath.row
        {
            let activities = self.activitiesArray[indexPath.row]
            cell.performanceLabel.text = activities["formatted_performance"].stringValue
            cell.competitionLabel.text = activities["competition"].stringValue
            cell.dateLabel.text = activities["formatted_date"].stringValue
            cell.locationLabel.text = activities["location"].stringValue
            cell.notesLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos"
            cell.optionsButton.accessibilityValue = activities["_id"].stringValue
        }
        return cell
    }
    
    func loadActivities(userId : String)
    {
        self.activitiesLoadingIndicator.startAnimating()

        TRFApiHandler.getAllActivitiesByUserId(userId, from: "2014-01-01", to: "2014-12-01", discipline:"high_jump")
        //.authenticate(user: "user@trafie.com", password: "123123")
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            println("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { (request, response, JSONObject, error) in
        println("request: \(request)")
//        println("response: \(response)")
//        println("JSONObject: \(JSONObject)")
//        println("error: \(error)")
            
            if (error == nil && JSONObject != nil) {
                self.activitiesArray = JSON(JSONObject!)
            } else {
                self.activitiesArray = []
            }
            
            self.activitiesTableView.reloadData()
            println("self.activitiesArray.count -> \(self.activitiesArray.count)")
            
            self.activitiesLoadingIndicator.stopAnimating()
        }
    }
    
    @IBAction func activityOptionsActionSheet(sender: UIButton) {
        // Alert Controller Instances
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let verificationAlert = UIAlertController(title: nil, message: "Are you sure you want to delete \(sender.accessibilityValue)?", preferredStyle: .Alert)
        
        // Actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive , handler: {
            (alert: UIAlertAction!) -> Void in
            self.presentViewController(verificationAlert, animated: true, completion: nil)
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
            println("Cancelled")
        })
        

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(editAction)
        optionMenu.addAction(cancelAction)
        
        verificationAlert.addAction(confirmAction)
        verificationAlert.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    

}
