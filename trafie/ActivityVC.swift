//
//  ActivityVC.swift
//  trafie
//
//  Created by mathiou on 26/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

class ActivityVC : UIViewController, UIScrollViewDelegate {
    
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
    
    var activity : Activity = Activity()
    var userId : String = ""
    
    // TODO: move to Commons with the repeated logic in code
    let calendar = NSCalendar.currentCalendar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivity:", name:"reloadActivity", object: nil)
        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        loadActivity(viewingActivityID)
        
    }
    
    @objc private func reloadActivity(notification: NSNotification){
        loadActivity(viewingActivityID)
    }
    
    func loadActivity(activityId: String) {
        // TODO: NEEDS TO BE FUNCTION
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle

        self.activity = getActivityFromActivitiesArrayById(activityId)
        self.performanceValue.text = activity.getReadablePerformance()
        self.competitionValue.text = activity.getCompetition()
        self.dateValue.text = dateFormatter.stringFromDate(activity.getDate())
        
        let notes = activity.getNotes() != "" ? activity.getNotes() : "Nothing to say about this competition..."
        self.rankValue.text = activity.getRank() != "" ? activity.getRank() : "-"
        self.locationValue.text = activity.getLocation() != "" ? activity.getLocation() : "-"
        self.notesValue.text = "\"\(notes)\""
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
    }
    
    @IBAction func deleteActivity(sender: AnyObject) {
        SweetAlert().showAlert("Delete Activity", subTitle: "Are you sure you want to delete your performance from \(self.activity.getCompetition())?", style: AlertStyle.Warning, buttonTitle:"Keep it", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Delete it", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                log("Deletion Cancelled")
            }
            else {
                ApiHandler.deleteActivityById(self.userId, activityId: self.activity.getActivityId())
                    .responseJSON { request, response, result in
                        switch result {
                        case .Success(_):
                            log("Activity \"\(self.activity.getActivityId())\" Deleted Succesfully")
                            
                            let oldKey = String(self.calendar.components(.Year, fromDate: self.activity.getDate()).year) //activity.getDate().componentsSeparatedByString("-")[0]
                            removeActivity(self.activity, section: oldKey)
                            // remove id from activitiesIdTable
                            for var i=0; i < activitiesIdTable.count; i++ {
                                if activitiesIdTable[i] == self.activity.getActivityId() {
                                    activitiesIdTable.removeAtIndex(i)
                                    break
                                }
                            }
                            
                            SweetAlert().showAlert("Deleted!", subTitle: "Your activity has been deleted!", style: AlertStyle.Success)
                            
                            // inform activitiesView to refresh data and close view
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadActivities", object: nil)
                            self.dismissViewControllerAnimated(true, completion: {})
                            viewingActivityID = ""
                            
                        case .Failure(let data, let error):
                            log("Request for deletion failed with error: \(error)")
                            cleanSectionsOfActivities()
                            
                            if let data = data {
                                log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                }
            }
        }
    }
    
}
