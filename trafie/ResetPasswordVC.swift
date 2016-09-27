//
//  ResetPasswordViewController.swift
//  trafie
//
//  Created by mathiou on 19/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit

class ResetPasswordVC : UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var errorMessage: UILabel!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet weak var sendEmailButton: UIButton!
  @IBOutlet weak var backToLogin: UIButton!
  
  let tapViewRecognizer = UITapGestureRecognizer()

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : ResetPassword ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordVC.showConnectionStatusChange(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    Reach().monitorReachabilityChanges()
    
    tapViewRecognizer.addTarget(self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tapViewRecognizer)
    
    emailTextField.delegate = self
    self.errorMessage.isHidden = true
    self.loadingIndicator.isHidden = true
    
    self.toggleUIElementsBasedOnNetworkStatus() //should be called after UI elements initiated
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func emailEditingDidEnd(_ sender: UITextField) {
    if Utils.validateEmail(self.emailTextField.text!) == .InvalidEmail {
      self.emailTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).cgColor
      self.emailTextField.layer.borderWidth = 1
      self.errorMessage.isHidden = false
      self.errorMessage.text = ErrorMessage.InvalidEmail.rawValue
    } else {
      self.emailTextField.layer.borderWidth = 0
      self.errorMessage.isHidden = true
      self.errorMessage.text = ""
    }
  }
  
  /// Sends request for email which contains password-reset hash.
  @IBAction func sendEmail(_ sender: AnyObject) {
    Utils.dismissFirstResponder(view)
    let validationResponse : ErrorMessage = Utils.validateEmail(self.emailTextField.text!)
    let requestedEmail = self.emailTextField.text!
    
    switch validationResponse {
    case .InvalidEmail:
      self.errorMessage.text = ErrorMessage.InvalidEmail.rawValue
      self.errorMessage.isHidden = false
    case .NoError:
      Utils.showNetworkActivityIndicatorVisible(true)
      ApiHandler.resetPasswordRequest(email: requestedEmail)
        .responseJSON { response in
          Utils.showNetworkActivityIndicatorVisible(false)
          
          if response.result.isSuccess {
            let statusCode : Int = response.response!.statusCode
            switch statusCode {
            case 200:
              self.errorMessage.isHidden = false
              self.emailTextField.isHidden = true
              self.sendEmailButton.isHidden = true
              self.errorMessage.text = "Great! We send you a reset link at \(requestedEmail). Open it and follow the steps in order to reset your password."
            case 404:
              self.errorMessage.text = "We can't find \(requestedEmail). Check your email and try again."
              self.errorMessage.isHidden = false
            default:
              self.errorMessage.text = "Something went wrong with your request. Please try again in a minute."
              self.errorMessage.isHidden = false
            }
          } else if response.result.isFailure {
            Utils.log("Request failed with error: \(response.result.error)")
            self.errorMessage.text = "Something went wrong with your request. Please try again in a minute."
            self.errorMessage.isHidden = false
            if let data = response.data {
              Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
            }
          }
      }
    default:
      self.errorMessage.text = "Default Case"
      self.errorMessage.isHidden = false
    }
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(_ notification: Notification) {
    Utils.showConnectionStatusChange()
  }
  
  func dismissKeyboard() {
    Utils.dismissFirstResponder(view)
  }
  
  func toggleUIElementsBasedOnNetworkStatus() {
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
      self.errorMessage.text = ErrorMessage.YouAreNotConnectedToTheInternet.rawValue
      self.errorMessage.isHidden = false
      self.sendEmailButton.isEnabled = false
    case .online(.wwan), .online(.wiFi):
      if self.errorMessage.text == ErrorMessage.YouAreNotConnectedToTheInternet.rawValue {
        self.errorMessage.text = ""
      }
      self.sendEmailButton.isEnabled = true
    }
  }
}
