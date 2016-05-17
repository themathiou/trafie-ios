//
//  ChangePasswordViewController.swift
//  trafie
//
//  Created by mathiou on 20/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordVC : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dismissViewButton: UIBarButtonItem!
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var doneButton: UIButton = keyboardButtonCentered
    
    var _oldPasswordError: Bool = true
    var _newPasswordError: Bool = true
    var _repeatNewPasswordError: Bool = true
    var _passwordsMatch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChangePasswordVC.networkStatusChanged(_:)), name: ReachabilityStatusChangedNotification, object: nil)
        
        Reach().monitorReachabilityChanges()
        Utils.log("\(Reach().connectionStatus())")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        toggleUIElementsBasedOnNetworkStatus()

        toggleSaveButton()

        // Done button for keyboard and pickers
        doneButton.addTarget(self, action: #selector(ChangePasswordVC.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss view
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    // MARK:- Network Connection
    /**
     Handles notification for Network status changes
     */
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        self.toggleUIElementsBasedOnNetworkStatus()
    }
    
    /// Toggles UI Elements based on network status
    func toggleUIElementsBasedOnNetworkStatus() {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            self.saveButton.enabled = false
        case .Online(.WWAN), .Online(.WiFi):
            self.saveButton.enabled = true
        }
    }

    /// Validates form and if form is valid, sends the request for saving password change.
    @IBAction func saveChanges(sender: AnyObject) {
        Utils.dismissFirstResponder(view)

        if self.newPasswordField.text != self.repeatPasswordField.text {
            Utils.log("Passwords doesn't match")
            SweetAlert().showAlert("Oooops!", subTitle: "Passwords doesn't match. Try again.", style: AlertStyle.Warning)
        } else if self.oldPasswordField.text?.characters.count < 6 || self.newPasswordField.text?.characters.count < 6 || self.repeatPasswordField.text?.characters.count < 6 {
            Utils.log("Passwords doesn't match")
            SweetAlert().showAlert("Oooops!", subTitle: "Passwords should be at least 6 characters long.", style: AlertStyle.Warning)
        } else {
            let userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!

            Utils.showNetworkActivityIndicatorVisible(true)
            ApiHandler.changePassword(userId, oldPassword: self.oldPasswordField.text!, password: self.newPasswordField.text!)
                .responseJSON { request, response, result in
                    Utils.showNetworkActivityIndicatorVisible(false)
                    switch result {
                    case .Success(let data):
                        Utils.log(String(response))
                        let json = JSON(data)
                        if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                            SweetAlert().showAlert("Done!", subTitle: "Password changed!", style: AlertStyle.Success)
                            self.dismissViewControllerAnimated(true, completion: {})
                        } else if Utils.validateTextWithRegex(StatusCodesRegex._422.rawValue, text: String((response?.statusCode)!)) {
                            Utils.log(json["message"].string!)
                            Utils.log("\(json["errors"][0]["field"].string!) : \(json["errors"][0]["code"].string!)" )
                            SweetAlert().showAlert("Invalid old email", subTitle: "Please try again.", style: AlertStyle.Warning)
                        } else {
                            Utils.log(json["message"].string!)
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
    
    @IBAction func inputFieldEditingStarted(sender: UITextField) {
        sender.inputAccessoryView = doneButton
    }
    
    /// Called when editing old password ends
    @IBAction func editingOldPasswordEnded(sender: AnyObject) {
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
    @IBAction func editingNewPasswordEnded(sender: AnyObject) {
        if self.newPasswordField.text?.characters.count < 6 {
            Utils.textFieldHasError(self.newPasswordField, hasError: true)
            _newPasswordError = true
        } else {
            Utils.textFieldHasError(self.newPasswordField, hasError: false)
            _newPasswordError = false
        }
    }
    
    /// Called when editing repeat new password
    @IBAction func editingRepeatNewPassword(sender: AnyObject) {
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
            self.saveButton.enabled = true
            self.saveButton.tintColor = UIColor.blueColor()
        } else {
            self.saveButton.enabled = false
            self.saveButton.tintColor = CLR_MEDIUM_GRAY
        }
    }
    
    /// Function called from all "done" buttons of keyboards and pickers.
    func doneButton(sender: UIButton) {
        Utils.dismissFirstResponder(view)
    }

}