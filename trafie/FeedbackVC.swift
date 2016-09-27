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
  
  let tapViewRecognizer = UITapGestureRecognizer()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : FeedBack ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(FeedbackVC.showConnectionStatusChange(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    Reach().monitorReachabilityChanges()
    tapViewRecognizer.addTarget(self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tapViewRecognizer)
    
    self.cancelButton.tintColor = CLR_NOTIFICATION_RED
    self.sendFeedbackButton.tintColor = UIColor.blue
    self.feedbackTypeSegmentation.selectedSegmentIndex = 0
    self.deviceLabel.text = "Device: \(UIDevice.current.model)"
    self.osLabel.text = "iOS: \(UIDevice.current.systemVersion)"
    self.appVersionLabel.text = "trafie version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
    
    Utils.log("\(Reach().connectionStatus())")
    self.toggleUIElementsBasedOnNetworkStatus()
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(_ notification: Notification) {
    Utils.showConnectionStatusChange()
  }
  
  func toggleUIElementsBasedOnNetworkStatus() {
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
      self.sendFeedbackButton.isEnabled = false
      self.sendFeedbackButton.tintColor = CLR_LIGHT_GRAY
    case .online(.wwan), .online(.wiFi):
      self.sendFeedbackButton.isEnabled = true
      self.sendFeedbackButton.tintColor = UIColor.blue
    }
  }
  
  func dismissKeyboard() {
    Utils.dismissFirstResponder(view)
  }
  
  @IBAction func dismissView(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: {})
  }
  
  @IBAction func sendFeedback(_ sender: AnyObject) {
    Utils.dismissFirstResponder(view)
    var feedbackType: FeedbackType
    
    if self.messageField.text.utf16.count < 10 {
      SweetAlert().showAlert("Oooops!", subTitle: "Message should have more than 10 characters.", style: AlertStyle.error)
    } else {
      switch feedbackTypeSegmentation.selectedSegmentIndex {
      case 1:
        feedbackType = FeedbackType.FeatureRequest
      case 2:
        feedbackType = FeedbackType.Comment
      default:
        feedbackType = FeedbackType.Bug
      }
      
      let device: String = UIDevice.current.model
      let os: String = UIDevice.current.systemVersion
      
      Utils.showNetworkActivityIndicatorVisible(true)
      ApiHandler.sendFeedback(feedback: self.messageField.text,
        platform: device,
        osVersion: os,
        appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as! String,
        feedbackType: feedbackType)
        .responseJSON { response in
          Utils.showNetworkActivityIndicatorVisible(false)
          
          if response.result.isSuccess {
            Utils.log(String(describing: response.result.value))
            if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
              SweetAlert().showAlert("Got it!", subTitle: "Thank you!", style: AlertStyle.success)
              self.dismiss(animated: true, completion: {})
            } else {
              //Utils.log(json["message"].string!)
              SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
            }
          } else if response.result.isFailure {
            Utils.log("Request failed with error: \(response.result.error)")
            SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
            if let data = response.data {
              Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
            }
            
          }
      }
    }
  }
  
  
}
