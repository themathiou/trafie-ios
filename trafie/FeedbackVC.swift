//
//  FeedbackVC.swift
//  trafie
//
//  Created by mathiou on 13/03/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FeedbackVC : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var feedbackTypeSegmentation: UISegmentedControl!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var osLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var sendFeedbackButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancelButton.tintColor = CLR_NOTIFICATION_RED
        self.sendFeedbackButton.tintColor = UIColor.blueColor()
        
        self.feedbackTypeSegmentation.selectedSegmentIndex = 0
        self.deviceLabel.text = "Device: \(UIDevice.currentDevice().model)"
        self.osLabel.text = "iOS: \(UIDevice.currentDevice().systemVersion)"
        self.appVersionLabel.text = "trafie version: \(NSBundle .mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)"

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        self.toggleUIElementsBasedOnNetworkStatus()
    }
    
    // MARK:- Network Connection
    /**
    Notification handler for Network Status Change
    
    - Parameter notification: notification that handles event from Reachability Status Change
    */
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        self.toggleUIElementsBasedOnNetworkStatus()
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
    
    @IBAction func feedbackTypeChanged(sender: UISegmentedControl) {
        /// if Bug show data
        if feedbackTypeSegmentation.selectedSegmentIndex == 0 {
            self.deviceLabel.text = "Device: \(UIDevice.currentDevice().model)"
            self.osLabel.text = "iOS: \(UIDevice.currentDevice().systemVersion)"
        } else {
            self.deviceLabel.text = "Device: - "
            self.osLabel.text = "iOS: - "
        }
    }
    
    
    @IBAction func dismissView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func sendFeedback(sender: AnyObject) {
        Utils.dismissFirstResponder(self.view)

        let feedbackType: FeedbackType = feedbackTypeSegmentation.selectedSegmentIndex == 0 ? FeedbackType.Bug : FeedbackType.FeatureRequest
        Utils.showNetworkActivityIndicatorVisible(true)
        ApiHandler.sendFeedback(self.deviceLabel.text!, os_version: self.osLabel.text!, app_version: self.appVersionLabel.text!, feedback_type: feedbackType)
            .responseJSON { request, response, result in
                Utils.showNetworkActivityIndicatorVisible(false)
                switch result {
                case .Success(_):
                    Utils.log(String(response))
                    if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                        self.dismissViewControllerAnimated(true, completion: {})
                    } else {
                        //Utils.log(json["message"].string!)
                        SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                    }
                case .Failure(let data, let error):
                    Utils.log("Request failed with error: \(error)")
                    SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                    if let data = data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    
}