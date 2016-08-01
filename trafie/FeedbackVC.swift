//
//  FeedbackVC.swift
//  trafie
//
//  Created by mathiou on 13/03/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit

class FeedbackVC : UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var feedbackTypeSegmentation: UISegmentedControl!
  @IBOutlet weak var messageField: UITextView!
  @IBOutlet weak var deviceLabel: UILabel!
  @IBOutlet weak var osLabel: UILabel!
  @IBOutlet weak var appVersionLabel: UILabel!
  @IBOutlet weak var sendFeedbackButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : FeedBack ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.cancelButton.tintColor = CLR_NOTIFICATION_RED
    self.sendFeedbackButton.tintColor = UIColor.blueColor()
    
    self.feedbackTypeSegmentation.selectedSegmentIndex = 0
    self.deviceLabel.text = "Device: \(UIDevice.currentDevice().model)"
    self.osLabel.text = "iOS: \(UIDevice.currentDevice().systemVersion)"
    self.appVersionLabel.text = "trafie version: \(NSBundle .mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)"
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackVC.showConnectionStatusChange(_:)), name: ReachabilityStatusChangedNotification, object: nil)
    Reach().monitorReachabilityChanges()
    Utils.log("\(Reach().connectionStatus())")
    self.toggleUIElementsBasedOnNetworkStatus()
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(notification: NSNotification) {
    Utils.showConnectionStatusChange()
  }
  
  func toggleUIElementsBasedOnNetworkStatus() {
    let status = Reach().connectionStatus()
    switch status {
    case .Unknown, .Offline:
      self.sendFeedbackButton.enabled = false
      self.sendFeedbackButton.tintColor = CLR_LIGHT_GRAY
    case .Online(.WWAN), .Online(.WiFi):
      self.sendFeedbackButton.enabled = true
      self.sendFeedbackButton.tintColor = UIColor.blueColor()
    }
  }
  
  @IBAction func dismissView(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: {})
  }
  
  @IBAction func sendFeedback(sender: AnyObject) {
    Utils.dismissFirstResponder(view)
    var feedbackType: FeedbackType
    
    if self.messageField.text.utf16.count < 10 {
      SweetAlert().showAlert("Oooops!", subTitle: "Message should have more than 10 characters.", style: AlertStyle.Error)
    } else {
      switch feedbackTypeSegmentation.selectedSegmentIndex {
      case 1:
        feedbackType = FeedbackType.FeatureRequest
      case 2:
        feedbackType = FeedbackType.Comment
      default:
        feedbackType = FeedbackType.Bug
      }
      
      let device: String = UIDevice.currentDevice().model
      let os: String = UIDevice.currentDevice().systemVersion
      
      Utils.showNetworkActivityIndicatorVisible(true)
      ApiHandler.sendFeedback(self.messageField.text,
        platform: device,
        osVersion: os,
        appVersion: NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")! as! String,
        feedbackType: feedbackType)
        .responseJSON { response in
          Utils.showNetworkActivityIndicatorVisible(false)
          
          if response.result.isSuccess {
            Utils.log(String(response.result.value))
            if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
              SweetAlert().showAlert("Got it!", subTitle: "Thank you!", style: AlertStyle.Success)
              self.dismissViewControllerAnimated(true, completion: {})
            } else {
              //Utils.log(json["message"].string!)
              SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
            }
          } else if response.result.isFailure {
            Utils.log("Request failed with error: \(response.result.error)")
            SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
            if let data = response.data {
              Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
            }
            
          }
      }
      
    }
    
    
    
  }
  
  
}