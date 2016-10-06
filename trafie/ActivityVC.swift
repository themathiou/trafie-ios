//
//  ActivityVC.swift
//  trafie
//
//  Created by mathiou on 26/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import Social
import SwiftyJSON
import UICircularProgressRing

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
  @IBOutlet weak var activityPictureView: UIImageView!
  @IBOutlet weak var emptyImageLabel: UILabel!
  
  @IBOutlet weak var twitterShareButton: UIButton!
  @IBOutlet weak var facebookShareButton: UIButton!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  
  var userId : String = ""
  var imageForSocialSharing = UIImageView()
  @IBOutlet weak var imageLoader: UICircularProgressRingView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : Activity ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(ActivityVC.reloadActivity(_:)), name:NSNotification.Name(rawValue: "reloadActivity"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ActivityVC.showConnectionStatusChange(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    
    self.imageLoader.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
    self.imageLoader.isHidden = true
    
    self.userId = (UserDefaults.standard.object(forKey: "userId") as? String)!
    loadActivity(viewingActivityID)
  }
  
  // MARK:- Social sharing
  // Facebook Sharing
  @IBAction func postToFacebook(_ sender: AnyObject) {
    if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
      let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)

      let shareUrl: URL = URL(string: "\(trafieURL)\(self.userId)?activityId=\(viewingActivityID)")!
      socialController?.add(shareUrl)
      self.present(socialController!, animated: true, completion: nil)
    } else {
      SweetAlert().showAlert("Enable Facebook.", subTitle: "Go to your phone Settings and sign in to your Facebook account.", style: AlertStyle.warning)
    }
  }
  
  // Twitter Sharing
  @IBAction func postToTwitter(_ sender: AnyObject) {
    if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
      let _activity = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: viewingActivityID as AnyObject)!
      
      let socialController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      socialController?.setInitialText("I just achieved \(performanceValue.text!) @ \(_activity.competition!). ~ via @_trafie")
      if self.activityPictureView.image != nil {
        socialController?.add(self.imageForSocialSharing.image)
      }
      let shareUrl: URL = URL(string: "\(trafieURL)\(self.userId)?activityId=\(viewingActivityID)")!
      socialController?.add(shareUrl)
      self.present(socialController!, animated: true, completion: nil)
    } else {
      SweetAlert().showAlert("Enable Twitter.", subTitle: "Go to your phone Settings and sign in to your Twitter account.", style: AlertStyle.warning)
    }
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(_ notification: Foundation.Notification) {
    Utils.showConnectionStatusChange()
  }
  
  /// Handles event for reloading activity. Used after editing current activity
  @objc fileprivate func reloadActivity(_ notification: Foundation.Notification){
    loadActivity(viewingActivityID)
  }
  
  /**
   Tries to sync local activity with one from the server
   
   - Parameter activityId: the id of activity we want to sync
   If activity is existed and edited we compared the two dates and keep the latest one.
   */
  @IBAction func syncActivity(sender: AnyObject) {
    setNotificationState(.Info, notification: statusBarNotification, style:.statusBarNotification)
    self.syncActivityButton.isEnabled = false
    
    let status = Reach().connectionStatus()
    
    let localActivity = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: viewingActivityID as AnyObject)!
    /// activity to post to server
    let activity: [String:AnyObject] = ["discipline": localActivity.discipline! as AnyObject,
                                        "performance": localActivity.performance! as AnyObject,
                                        "date": localActivity.dateUnixTimestamp! as AnyObject,
                                        "rank": localActivity.rank! as AnyObject,
                                        "location": localActivity.location! as AnyObject,
                                        "competition": localActivity.competition! as AnyObject,
                                        "notes": localActivity.notes! as AnyObject,
                                        "comments": localActivity.comments! as AnyObject,
                                        "isOutdoor": localActivity.isOutdoor as AnyObject,
                                        "isPrivate": localActivity.isPrivate as AnyObject]
    
    switch status {
    case .unknown, .offline:
      SweetAlert().showAlert("You are offline!", subTitle: "You cannot sync activities when offline! Try again when internet is available!", style: AlertStyle.warning)
    case .online(.wwan), .online(.wiFi):
      statusBarNotification.displayNotificationWithMessage("Syncing activity...", completion: {})
      Utils.showNetworkActivityIndicatorVisible(true)
      
      // Newly created activity.
      // ActivityId is a random NSUUID that contains alphanumeric and '-'.
      // Doesn't yet exist in server. We delete existing activity from local realm and add the new one with normal activityId.
      if localActivity.activityId?.contains("-") != false {
        Utils.log(String(describing: localActivity))
        ApiHandler.postActivity(userId: self.userId, activityObject: activity)
          .responseJSON { response in
            if let JSON = response.result.value {
              print("JSON: \(JSON)")
            }
            if response.result.isSuccess {
              let responseJSONObject = JSON(response.result.value)
              if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                Utils.log("\(response.request)")
                Utils.log("\(responseJSONObject)")
                
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
                  "imageUrl": responseJSONObject["picture"].stringValue,
                  "isDeleted": responseJSONObject["isDeleted"].boolValue ? true : false,
                  "isOutdoor": responseJSONObject["isOutdoor"].boolValue ? true : false,
                  "isPrivate": responseJSONObject["isPrivate"].boolValue ? true : false,
                  "isDraft": false ])
//                // save activity from server
                _syncedActivity.update()
                
                SweetAlert().showAlert("Great!", subTitle: "Activity synced.", style: AlertStyle.success)
//                Utils.log("Activity Synced: \(_syncedActivity)")
                viewingActivityID = _syncedActivity.activityId!
                self.loadActivity(viewingActivityID)
              } else if Utils.validateTextWithRegex(StatusCodesRegex._404.rawValue, text: String((response.response!.statusCode))) {
                SweetAlert().showAlert("Activity doesn't exist.", subTitle: "This activity doesn't exists in our server. Delete it from your phone.", style: AlertStyle.warning)
                self.dismiss(animated: false, completion: {})
              } else {
                if let errorCode = responseJSONObject["errors"][0]["code"].string { //under 403 statusCode
                  Utils.log(errorCode)
                  if errorCode == "non_verified_user_activity_limit" {
                    SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more activities.", style: AlertStyle.warning)
                  } else {
                    Utils.log(errorCode)
                    SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. Try again later.", style: AlertStyle.error)
                    self.syncActivityButton.isEnabled = true
                  }
                }
              }
            } else if response.result.isFailure {
              Utils.log("Request failed with error: \(response.result.error)")
              SweetAlert().showAlert("Still locally.", subTitle: "Activity couldn't synced. Try again when internet is available.", style: AlertStyle.warning)
              self.dismiss(animated: false, completion: {})
              if let data = response.data {
                Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
              }
            }
            
            // Dismissing status bar notification
            Utils.showNetworkActivityIndicatorVisible(false)
            statusBarNotification.dismissNotification()
            
        }
      }
      else { // Existed activity. Need to be synced with server.
        ApiHandler.updateActivityById(userId: userId, activityId: (localActivity.activityId)!, activityObject: activity)
          .responseJSON { response in
            Utils.showNetworkActivityIndicatorVisible(false)
            
            let responseJSONObject = response.result.value as? JSON
            if response.result.isSuccess {
              if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                Utils.log("\(response)")
                Utils.log("\(responseJSONObject)")
                
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                let _syncedActivity = ActivityModelObject(value: [
                  "userId": responseJSONObject?["userId"].stringValue,
                  "activityId": responseJSONObject?["_id"].stringValue,
                  "discipline": responseJSONObject?["discipline"].stringValue,
                  "performance": responseJSONObject?["performance"].stringValue,
                  "date": Utils.timestampToDate(responseJSONObject?["date"].stringValue),
                  "dateUnixTimestamp": responseJSONObject?["date"].stringValue,
                  "rank": responseJSONObject?["rank"].stringValue,
                  "location": responseJSONObject?["location"].stringValue,
                  "competition": responseJSONObject?["competition"].stringValue,
                  "notes": responseJSONObject?["notes"].stringValue,
                  "comments": responseJSONObject?["comments"].stringValue,
                  "imageUrl": responseJSONObject?["picture"].stringValue,
                  "isDeleted": (responseJSONObject?["isDeleted"].boolValue)! ? true : false,
                  "isOutdoor": (responseJSONObject?["isOutdoor"].boolValue)! ? true : false,
                  "isPrivate": (responseJSONObject?["isPrivate"].boolValue)! ? true : false,
                  "isDraft": false ])
                
                _syncedActivity.update()
                Utils.log("Activity Edited: \(_syncedActivity)")
                SweetAlert().showAlert("Sweet!", subTitle: "That's right! \n Activity has been edited.", style: AlertStyle.success)
              } else if Utils.validateTextWithRegex(StatusCodesRegex._404.rawValue, text: String((response.response!.statusCode))) {
                SweetAlert().showAlert("Activity doesn't exist.", subTitle: "This activity doesn't exists in our server. Delete it from your phone.", style: AlertStyle.warning)
                self.dismiss(animated: false, completion: {})
              } else {
                SweetAlert().showAlert("Ooops.", subTitle: "something went wrong. Try again later.", style: AlertStyle.error)
                self.syncActivityButton.isEnabled = true
              }
            } else if response.result.isFailure {
              Utils.log("Request failed with error: \(response.result.error)")
              SweetAlert().showAlert("Saved locally.", subTitle: "Activity saved only in your phone. Try to sync when internet is available.", style: AlertStyle.warning)
              self.dismiss(animated: false, completion: {})
              if let data = response.data {
                Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
              }
            }
            
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadActivity"), object: nil)
            
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
  func loadActivity(_ activityId: String) {
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    let _activity = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: activityId as AnyObject)!
    
    self.performanceValue.text = _activity.readablePerformance
    self.disciplineValue.text = NSLocalizedString((_activity.discipline)!, comment:"translation of discipline")
    self.competitionValue.text = "@"+(_activity.competition)!
    self.dateValue.text = dateFormatter.string(from: _activity.date)
    self.rankValue.text = _activity.rank != "" ? _activity.rank : "-"
    self.locationValue.text = _activity.location != "" ? _activity.location : "-"
    self.syncActivityText.isHidden = !_activity.isDraft
    self.syncActivityButton.isHidden = !_activity.isDraft
    self.facebookShareButton.isHidden = _activity.isDraft
    self.twitterShareButton.isHidden = _activity.isDraft
    
    // evil hack to make notes to wrap around label
    let notes = "                      \"\(_activity.notes != nil ? _activity.notes! : " ... ")\""
    self.notesValue.text = "\(notes)"
    let comments = "                  \"\(_activity.comments != nil ? _activity.comments! : " ... ")\""
    self.commentsValue.text = "\(comments)"
    
    if _activity.imageUrl != "" && _activity.imageUrl != nil{
      self.emptyImageLabel.isHidden = true
      self.imageLoader.isHidden = false
      let screenSize: CGRect = UIScreen.main.bounds

      self.activityPictureView.kf.setImage(with: URL(string: _activity.imageUrl!),
                                           progressBlock: { receivedSize, totalSize in
                                            let _progress: CGFloat = (CGFloat(receivedSize) / CGFloat(totalSize)) * 100
                                            self.imageLoader.setProgress(value: _progress, animationDuration: 0.2) {
                                              print("\(_progress)")
                                            }},
                                           completionHandler: { image, error, cacheType, imageURL in
                                            self.imageLoader.isHidden = true
                                            self.activityPictureView.image = image?.resizeToWidth(screenSize.width)
                                            self.imageForSocialSharing.image = image
      })
    } else {
      self.emptyImageLabel.isHidden = false
    }
  }
  
  /// Dismisses the view
  @IBAction func dismissButton(_ sender: UIButton) {
    self.dismiss(animated: true, completion: {})
    self.closeButton.isHidden = true
    viewingActivityID = ""
  }
  
  /// Opens edit activity view
  @IBAction func editActivity(_ sender: AnyObject) {
    isEditingActivity = true
    let _activity = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: viewingActivityID as AnyObject)!
    editingActivityID = _activity.activityId!
    //open edit activity view
    let next = self.storyboard!.instantiateViewController(withIdentifier: "AddEditActivityController")
    self.present(next, animated: true, completion: nil)
  }
}
