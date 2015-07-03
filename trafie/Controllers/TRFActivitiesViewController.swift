

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

let testUserId = "5446517676d2b90200000015" //high jumper

class TRFActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let activities = TRFActivityModel()
    var activitiesArray : JSON = []
    
    
    @IBOutlet weak var activitiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesTableView.delegate = self;
        self.activitiesTableView.dataSource = self;
        
        // place tableview below status bar, cuz I think it's prettier that way
        self.activitiesTableView?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        
        //get user's activities
        loadActivities(testUserId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------- call REST attemp --------//
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
            cell.notesLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosq."
        }

        return cell
    }
    
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row % 2 == 0
//        {
//            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
//        }
//        else
//        {
//            cell.backgroundColor = UIColor.whiteColor()
//        }
//    }
    


    
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
            if (error === nil) {
                self.activitiesArray = JSON(JSONObject!)
                self.activitiesTableView.reloadData()
            }
        }
    }

}
