//
//  ActivityVC.swift
//  trafie
//
//  Created by mathiou on 26/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import RealmSwift

class ActivityVC : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var performanceValue: UILabel!
    @IBOutlet weak var disciplineValue: UILabel!
    @IBOutlet weak var competitionValue: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var rankValue: UILabel!
    @IBOutlet weak var notesValue: UILabel!
    @IBOutlet weak var commentsValue: UILabel!
    @IBOutlet weak var syncActivityButton: UIButton!
    @IBOutlet weak var syncActivityText: UILabel!
    

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    var userId : String = ""

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let name = "iOS : Activity ViewController"
        Utils.googleViewHitWatcher(name);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivityVC.reloadActivity(_:)), name:"reloadActivity", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivityVC.showConnectionStatusChange(_:)), name: ReachabilityStatusChangedNotification, object: nil)

        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!

        loadActivity(viewingActivityID)
    }

    // MARK:- Network Connection
    /**
     Calls Utils function for network change indication
     
     - Parameter notification : notification event
     */
    @objc func showConnectionStatusChange(notification: NSNotification) {
        Utils.showConnectionStatusChange()
    }
    
    /// Handles event for reloading activity. Used after editing current activity
    @objc private func reloadActivity(notification: NSNotification){
        loadActivity(viewingActivityID)
    }
    
    /**
     Tries to sync local activity with one from the server
     
     - Parameter activityId: the id of activity we want to sync
     If activity is existed and edited we compared the two dates and keep the latest one.
     */
    @IBAction func syncActivity(sender: AnyObject) {
        setNotificationState(.Info, notification: statusBarNotification, style:.StatusBarNotification)

        let status = Reach().connectionStatus()
        
        let localActivity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: viewingActivityID)!
        /// activity to post to server
        let activity: [String:AnyObject] = ["discipline": localActivity.discipline!,
                                            "performance": localActivity.performance!,
                                            "date": localActivity.dateUnixTimestamp!,
                                            "rank": localActivity.rank!,
                                            "location": localActivity.location!,
                                            "competition": localActivity.competition!,
                                            "notes": localActivity.notes!,
                                            "comments": localActivity.comments!,
                                            "isOutdoor": localActivity.isOutdoor,
                                            "isPrivate": localActivity.isPrivate ]

        switch status {
        case .Unknown, .Offline:
            SweetAlert().showAlert("You are offline!", subTitle: "You cannot sync activities when offline! Try again when internet is available!", style: AlertStyle.Warning)
        case .Online(.WWAN), .Online(.WiFi):
            statusBarNotification.displayNotificationWithMessage("Syncing activity...", completion: {})
            Utils.showNetworkActivityIndicatorVisible(true)

            // Newly created activity. 
            // ActivityId is a random NSUUID that contains alphanumeric and '-'.
            // Doesn't yet exist in server. We delete existing activity from local realm and add the new one with normal activityId.
            if ((localActivity.activityId?.containsString("-")) != false) {
                Utils.log(String(localActivity))
                ApiHandler.postActivity(self.userId, activityObject: activity)
                    .responseJSON { request, response, result in
                        switch result {
                        case .Success(let JSONResponse):
                            let responseJSONObject = JSON(JSONResponse)
                            if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                                Utils.log("\(request)")
                                Utils.log("\(JSONResponse)")
                                
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                                // delete draft from realm
                                try! uiRealm.write {
                                    uiRealm.deleteNotified(localActivity)
                                }
                                
                                let _syncedActivity = ActivityModelObject(value: [
                                    "userId": responseJSONObject["userId"].stringValue,
                                    "activityId": responseJSONObject["_id"].stringValue,
                                    "discipline": responseJSONObject["discipline"].stringValue,
                                    "performance": responseJSONObject["performance"].stringValue,
                                    "date": Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                    "dateUnixTimestamp": responseJSONObject["date"].stringValue,
                                    "rank": responseJSONObject["rank"].stringValue,
                                    "location": responseJSONObject["location"].stringValue,
                                    "competition": responseJSONObject["competition"].stringValue,
                                    "notes": responseJSONObject["notes"].stringValue,
                                    "comments": responseJSONObject["comments"].stringValue,
                                    "isDeleted": responseJSONObject["isDeleted"] ? true : false,
                                    "isOutdoor": responseJSONObject["isOutdoor"] ? true : false,
                                    "isPrivate": responseJSONObject["isPrivate"] ? true : false,
                                    "isDraft": false ])
                                // save activity from server
                                _syncedActivity.update()
                                
                                SweetAlert().showAlert("Great!", subTitle: "Activity synced.", style: AlertStyle.Success)
                                Utils.log("Activity Synced: \(_syncedActivity)")
                                viewingActivityID = _syncedActivity.activityId!
                                self.loadActivity(viewingActivityID)
                            } else {
                                if let errorCode = responseJSONObject["errors"][0]["code"].string { //under 403 statusCode
                                    if errorCode == "non_verified_user_activity_limit" {
                                        SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more activities.", style: AlertStyle.Error)
                                    }
                                } else {
                                    SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                                }
                            }
                            
                        case .Failure(let data, let error):
                            Utils.log("Request failed with error: \(error)")
                            SweetAlert().showAlert("Still locally.", subTitle: "Activity couldn't synced. Try again when internet is available.", style: AlertStyle.Warning)
                            self.dismissViewControllerAnimated(false, completion: {})
                            if let data = data {
                                Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                        // Dismissing status bar notification
                        Utils.showNetworkActivityIndicatorVisible(false)
                        statusBarNotification.dismissNotification()
                }
            }
            else { // Existed activity. Need to be synced with server.
                ApiHandler.updateActivityById(userId, activityId: (localActivity.activityId)!, activityObject: activity)
                    .responseJSON { request, response, result in
                        Utils.showNetworkActivityIndicatorVisible(false)
                        switch result {
                        case .Success(let JSONResponse):
                            if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                                Utils.log("Success")
                                Utils.log("\(JSONResponse)")
                                
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                
                                var responseJSONObject = JSON(JSONResponse)
                                
                                let _syncedActivity = ActivityModelObject(value: [
                                    "userId": responseJSONObject["userId"].stringValue,
                                    "activityId": responseJSONObject["_id"].stringValue,
                                    "discipline": responseJSONObject["discipline"].stringValue,
                                    "performance": responseJSONObject["performance"].stringValue,
                                    "date": Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                    "dateUnixTimestamp": responseJSONObject["date"].stringValue,
                                    "rank": responseJSONObject["rank"].stringValue,
                                    "location": responseJSONObject["location"].stringValue,
                                    "competition": responseJSONObject["competition"].stringValue,
                                    "notes": responseJSONObject["notes"].stringValue,
                                    "comments": responseJSONObject["comments"].stringValue,
                                    "isDeleted": responseJSONObject["isDeleted"] ? true : false,
                                    "isOutdoor": responseJSONObject["isOutdoor"] ? true : false,
                                    "isPrivate": responseJSONObject["isPrivate"] ? true : false,
                                    "isDraft": false ])
                                
                                _syncedActivity.update()
                                Utils.log("Activity Edited: \(_syncedActivity)")
                                SweetAlert().showAlert("Sweet!", subTitle: "That's right! \n Activity has been edited.", style: AlertStyle.Success)
                            } else {
                                SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                            }
                            
                        case .Failure(let data, let error):
                            Utils.log("Request failed with error: \(error)")
                            SweetAlert().showAlert("Saved locally.", subTitle: "Activity saved only in your phone. Try to sync when internet is available.", style: AlertStyle.Warning)
                            self.dismissViewControllerAnimated(false, completion: {})
                            if let data = data {
                                Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadActivity", object: nil)
                        
                        // Dismissing status bar notification
                        statusBarNotification.dismissNotification()
                }
            }
        }
    }

    /**
     Loads the activity from activities array.
     
     - Parameter activityId : the id of the activity we want to show
     */
    func loadActivity(activityId: String) {
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
        let _activity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: activityId)!

        self.performanceValue.text = _activity.readablePerformance
        self.disciplineValue.text = NSLocalizedString((_activity.discipline)!, comment:"translation of discipline")
        self.competitionValue.text = "@"+(_activity.competition)!
        self.dateValue.text = dateFormatter.stringFromDate(_activity.date)
        self.rankValue.text = _activity.rank != "" ? _activity.rank : "-"
        self.locationValue.text = _activity.location != "" ? _activity.location : "-"
        self.syncActivityText.hidden = !_activity.isDraft
        self.syncActivityButton.hidden = !_activity.isDraft
        
        // evil hack to make notes to wrap around label
        let notes = "            \"\(_activity.notes != nil ? _activity.notes! : " ... ")\""
        self.notesValue.text = "\(notes)"
        let comments = "                   \"\(_activity.comments != nil ? _activity.comments! : " ... ")\""
        self.commentsValue.text = "\(comments)"
    }
    
    /// Dismisses the view
    @IBAction func dismissButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
        self.closeButton.hidden = true
        viewingActivityID = ""
    }

    /// Opens edit activity view
    @IBAction func editActivity(sender: AnyObject) {
        isEditingActivity = true
        let _activity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: viewingActivityID)!
        editingActivityID = _activity.activityId!
        //open edit activity view
        let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
        self.presentViewController(next, animated: true, completion: nil)
    }
}
