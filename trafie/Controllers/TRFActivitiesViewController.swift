//
//  TRFActivitiesViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

//user-id  : "5446517776d2b90200000054"

class TRFActivitiesViewController: UITableViewController {
    
    let activities = TRFActivityModel()
    var activitiesArray = [TRFActivityModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //get user's activities
        activitiesArray = activities.getActivitiesByUserID("5446517776d2b90200000054") as! [(TRFActivityModel)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //let activity : TRFActivityModel
    
//    @IBAction func GetActivities(sender: UIButton) {
//        activities.getActivitiesByUserID("5446517776d2b90200000054")
//    }

}
