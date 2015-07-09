

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
//let testUserId = "5446515576d2b90200000001" //mathiou private profile get 404
//let testUserId = "5446515576d2b90200000004" //babis public profile - no data

class TRFActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let activities = TRFActivity()
    var activitiesArray : JSON = []
    //    var refreshControl:UIRefreshControl!
    
    
    @IBOutlet weak var activitiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesTableView.delegate = self;
        self.activitiesTableView.dataSource = self;
        
        
        //Refresh page
        //        self.refreshControl = UIRefreshControl()
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        //        self.activitiesTableView.addSubview(refreshControl)

        //get user's activities
        loadActivities(testUserId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------- call REST attemp --------//
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        
        // Return the number of sections.
        if (self.activitiesArray.count == 0) {
            return 1
        } else {
            // TO-DO
            // Display a message when the table is empty
            var messageLabel: UILabel!
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            self.activitiesTableView.backgroundView = messageLabel;
            
        }
        
        return 0

    }
    
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
            cell.notesLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero."
        }

        return cell
    }
    
    
    func loadActivities(userId : String)
    {
        println("--------------Load Activities-----------------")
        //self.activitiesArray = activities.getActivitiesByUserID("5446517776d2b90200000054")
        let url = trafieURL + "users/\(userId)/activities"
        Alamofire.request(.GET, url)
        //.authenticate(user: "user@trafie.com", password: "123123")
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            println("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { (request, response, JSONObject, error) in
//            println("request: \(request)")
//            println("response: \(response)")
//            println("JSONObject: \(JSONObject)")
//            println("error: \(error)")
            
            if (error == nil && JSONObject != nil) {
                self.activitiesArray = JSON(JSONObject!)
            } else {
                self.activitiesArray = []
            }
            
            self.activitiesTableView.reloadData()
            println("self.activitiesArray.count -> \(self.activitiesArray.count)")
        }
    }

}
