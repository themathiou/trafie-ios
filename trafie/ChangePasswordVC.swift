//
//  ChangePasswordViewController.swift
//  trafie
//
//  Created by mathiou on 20/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ChangePasswordVC : UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var dismissViewButton: UIBarButtonItem!
  @IBOutlet weak var oldPasswordField: UITextField!
  @IBOutlet weak var newPasswordField: UITextField!
  @IBOutlet weak var repeatPasswordField: UITextField!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  
  var _oldPasswordError: Bool = true
  var _newPasswordError: Bool = true
  var _repeatNewPasswordError: Bool = true
  var _passwordsMatch: Bool = false
  let tapViewRecognizer = UITapGestureRecognizer()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : ChangePassword ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(ChangePasswordVC.showConnectionStatusChange(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    Reach().monitorReachabilityChanges()
    tapViewRecognizer.addTarget(self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tapViewRecognizer)

    Utils.log("\(Reach().connectionStatus())")
    toggleUIElementsBasedOnNetworkStatus()
    
    toggleSaveButton()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // Dismiss view
  @IBAction func dismissView(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: {})
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(_ notification: Notification) {
    Utils.showConnectionStatusChange()
  }
  
  /// Toggles UI Elements based on network status
  func toggleUIElementsBasedOnNetworkStatus() {
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
      Utils.showConnectionStatusChange()
      self.saveButton.isEnabled = false
    case .online(.wwan), .online(.wiFi):
      self.saveButton.isEnabled = true
    }
  }
  
  /// Validates form and if form is valid, sends the request for saving password change.
  @IBAction func saveChanges(_ sender: AnyObject) {
    Utils.dismissFirstResponder(view)
    
    if self.newPasswordField.text != self.repeatPasswordField.text {
      Utils.log("Passwords doesn't match")
      SweetAlert().showAlert("Oooops!", subTitle: "Passwords doesn't match. Try again.", style: AlertStyle.warning)
    } else if self.oldPasswordField.text?.characters.count < 6 || self.newPasswordField.text?.characters.count < 6 || self.repeatPasswordField.text?.characters.count < 6 {
      Utils.log("Passwords doesn't match")
      SweetAlert().showAlert("Oooops!", subTitle: "Passwords should be at least 6 characters long.", style: AlertStyle.warning)
    } else {
      let userId = (UserDefaults.standard.object(forKey: "userId") as? String)!
      
      Utils.showNetworkActivityIndicatorVisible(true)
      ApiHandler.changePassword(userId: userId, oldPassword: self.oldPasswordField.text!, password: self.newPasswordField.text!)
        .responseJSON { response in
          Utils.showNetworkActivityIndicatorVisible(false)
          if response.result.isSuccess {
            Utils.log(String(describing: response.result))
            let json = JSON(response.data!)
            if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
              SweetAlert().showAlert("Done!", subTitle: "Password changed!", style: AlertStyle.success)
              self.dismiss(animated: true, completion: {})
            } else if Utils.validateTextWithRegex(StatusCodesRegex._422.rawValue, text: String((response.response!.statusCode))) {
              Utils.log(json["message"].string!)
              Utils.log("\(json["errors"][0]["field"].string!) : \(json["errors"][0]["code"].string!)" )
              SweetAlert().showAlert("Invalid old email", subTitle: "Please try again.", style: AlertStyle.warning)
            } else {
              Utils.log(json["message"].string!)
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
  
  /// Called when editing old password ends
  @IBAction func editingOldPasswordEnded(_ sender: AnyObject) {
    if self.oldPasswordField.text?.characters.count < 6 {
      Utils.textFieldHasError(self.oldPasswordField, hasError: true)
      _oldPasswordError = true
    } else {
      Utils.textFieldHasError(self.oldPasswordField, hasError: false)
      _oldPasswordError = false
    }
    toggleSaveButton()
  }
  
  /// Called when editing new passwords ends
  @IBAction func editingNewPasswordEnded(_ sender: AnyObject) {
    if self.newPasswordField.text?.characters.count < 6 {
      Utils.textFieldHasError(self.newPasswordField, hasError: true)
      _newPasswordError = true
    } else {
      Utils.textFieldHasError(self.newPasswordField, hasError: false)
      _newPasswordError = false
    }
  }
  
  /// Called when editing repeat new password
  @IBAction func editingRepeatNewPassword(_ sender: AnyObject) {
    if self.repeatPasswordField.text?.characters.count < 6 && (self.newPasswordField.text != self.repeatPasswordField.text){
      Utils.textFieldHasError(self.repeatPasswordField, hasError: true)
      _repeatNewPasswordError = true
    } else {
      Utils.textFieldHasError(self.repeatPasswordField, hasError: false)
      _repeatNewPasswordError = false
      _passwordsMatch = true
    }
    
    toggleSaveButton()
  }
  
  
  /// Toggle save button
  func toggleSaveButton() {
    if !_newPasswordError && !_oldPasswordError && !_repeatNewPasswordError && _passwordsMatch {
      self.saveButton.isEnabled = true
      self.saveButton.tintColor = UIColor.blue
    } else {
      self.saveButton.isEnabled = false
      self.saveButton.tintColor = CLR_MEDIUM_GRAY
    }
  }
  
  func dismissKeyboard() {
    Utils.dismissFirstResponder(view)
  }
  
}
