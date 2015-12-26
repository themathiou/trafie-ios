//
//  TRFActivityVC.swift
//  trafie
//
//  Created by mathiou on 26/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

class TRFActivityVC : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var performanceValue: UILabel!
    @IBOutlet weak var competitionValue: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var rankValue: UILabel!
    @IBOutlet weak var notesValue: UILabel!
    
    var activity : TRFActivity = TRFActivity()
    var userId : String = ""
    
    // TODO: move to Commons with the repeated logic in code
    let calendar = NSCalendar.currentCalendar()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity = getActivityFromActivitiesArrayById(viewingActivityID)
        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        
        self.performanceValue.text = activity.getReadablePerformance()
        self.competitionValue.text = activity.getCompetition()
        self.dateValue.text = String(activity.getDate())
        self.rankValue.text = activity.getRank()
        self.locationValue.text = activity.getLocation()
        self.notesValue.text = activity.getNotes()
    }
    
    
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
        viewingActivityID = ""
    }
    
    @IBAction func editActivity(sender: AnyObject) {
            isEditingActivity = true
            
            // TODO: get parameters from activitiesArray in ViewDidLoad AND COMPLETE EDITING ACTIVITY
            editingActivityID = self.activity.getActivityId()
            //open edit activity view
            let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
            self.presentViewController(next, animated: true, completion: nil)
            print("Choose to Edit", terminator: "")
    }
    
    @IBAction func deleteActivity(sender: AnyObject) {
        let deleteVerificationAlert = UIAlertController(title: nil, message: "Are you sure you want to delete your performance from \(self.activity.getCompetition())?", preferredStyle: .Alert)
        
        let confirmDeletion = UIAlertAction(title: "OK", style: .Default , handler: {
            (alert: UIAlertAction!) -> Void in
            TRFApiHandler.deleteActivityById(self.userId, activityId: self.activity.getActivityId())
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(_):
                        print("Activity \"\(self.activity.getActivityId())\" Deleted Succesfully")
                        print(self.activity.getActivityId())
                        
                        let oldKey = String(self.calendar.components(.Year, fromDate: self.activity.getDate()).year) //activity.getDate().componentsSeparatedByString("-")[0]
                        removeActivity(self.activity, section: oldKey)
                        // remove id from activitiesIdTable
                        for var i=0; i < activitiesIdTable.count; i++ {
                            if activitiesIdTable[i] == self.activity.getActivityId() {
                                activitiesIdTable.removeAtIndex(i)
                                break
                            }
                        }

                        // inform activitiesView to refresh data and close view
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadActivities", object: nil)
                        self.dismissViewControllerAnimated(true, completion: {})
                        viewingActivityID = ""

                    case .Failure(let data, let error):
                        print("Request for deletion failed with error: \(error)")
                        cleanSectionsOfActivities()
                        
                        if let data = data {
                            print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled", terminator: "")
        })
        
        deleteVerificationAlert.addAction(confirmDeletion)
        deleteVerificationAlert.addAction(cancelAction)
        
        self.presentViewController(deleteVerificationAlert, animated: true, completion: nil)
    }
    
}
