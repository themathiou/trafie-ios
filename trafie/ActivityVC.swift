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
    @IBOutlet weak var disciplineValue: UILabel!
    @IBOutlet weak var competitionValue: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var rankValue: UILabel!
    @IBOutlet weak var notesValue: UILabel!
    

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editBarButton: UIBarButtonItem!

    var activity : Activity = Activity()
    var userId : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadActivity:", name:"reloadActivity", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)

        Reach().monitorReachabilityChanges()
        Utils.log("\(Reach().connectionStatus())")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        toggleUIElementsBasedOnNetworkStatus()

        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        loadActivity(viewingActivityID)
        
    }

    /// Handles notification for Network status changes
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        self.toggleUIElementsBasedOnNetworkStatus()
    }
    
    func toggleUIElementsBasedOnNetworkStatus() {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            areActionsAvailable(false)
        case .Online(.WWAN), .Online(.WiFi):
            areActionsAvailable(true)
        }
    }
    
    func areActionsAvailable(areAvailable: Bool) {
        if areAvailable {
            self.editBarButton.enabled = true
            self.deleteButton.enabled = true
            self.deleteButton.backgroundColor = CLR_NOTIFICATION_ORANGE
        } else {
            self.editBarButton.enabled = false
            self.deleteButton.enabled = false
            self.deleteButton.backgroundColor = CLR_LIGHT_GRAY
        }
    }
    
    /// Handles event for reloading activity. Used after editing current activity
    @objc private func reloadActivity(notification: NSNotification){
        loadActivity(viewingActivityID)
    }
    
    /**
     Loads the activity from activities array.
     
     - Parameter activityId : the id of the activity we want to show
     */
    func loadActivity(activityId: String) {
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle

        self.activity = getActivityFromActivitiesArrayById(activityId)
        self.performanceValue.text = activity.getReadablePerformance()
        self.disciplineValue.text = NSLocalizedString(activity.getDiscipline(), comment:"translation of discipline")
        self.competitionValue.text = "@"+activity.getCompetition()
        self.dateValue.text = dateFormatter.stringFromDate(activity.getDate())
        
        self.rankValue.text = activity.getRank() != "" ? activity.getRank() : "-"
        self.locationValue.text = activity.getLocation() != "" ? activity.getLocation() : "-"
        // evil hack to make notes to wrap around label
        let notes = activity.getNotes() != "" ? "            \"" + activity.getNotes() : "            \" ... "
        self.notesValue.text = "\(notes)\""
    }
    
    /// Dismisses the view
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
        viewingActivityID = ""
    }

    /// Opens edit activity view
    @IBAction func editActivity(sender: AnyObject) {
            isEditingActivity = true
            editingActivityID = self.activity.getActivityId()
            //open edit activity view
            let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
            self.presentViewController(next, animated: true, completion: nil)
    }
    
    /// Prompts a confirmation message to user and, if he confirms the request, deletes the activity.
    @IBAction func deleteActivity(sender: AnyObject) {
        SweetAlert().showAlert("Delete Activity", subTitle: "Are you sure you want to delete your performance from \"\(self.activity.getCompetition())\"?", style: AlertStyle.Warning, buttonTitle:"Keep it", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Delete it", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                Utils.log("Deletion Cancelled")
            }
            else {

                Utils.showNetworkActivityIndicatorVisible(true)
                ApiHandler.deleteActivityById(self.userId, activityId: self.activity.getActivityId())
                    .responseJSON { request, response, result in
                        Utils.showNetworkActivityIndicatorVisible(false)
                        switch result {
                        case .Success(_):
                            if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                                Utils.log("Activity \"\(self.activity.getActivityId())\" Deleted Succesfully")
                                
                                let oldKey = String(currentCalendar.components(.Year, fromDate: self.activity.getDate()).year)
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
                            } else {
                                SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                            }
                            
                            
                        case .Failure(let data, let error):
                            Utils.log("Request for deletion failed with error: \(error)")
                            cleanSectionsOfActivities()
                            SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                            if let data = data {
                                Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                }
            }
        }
    }
    
}
