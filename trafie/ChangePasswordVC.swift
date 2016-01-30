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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleSaveButton()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    @IBAction func saveChanges(sender: AnyObject) {
        if self.newPasswordField.text != self.repeatPasswordField.text {
            log("Passwords doesn't match")
            SweetAlert().showAlert("Oooops!", subTitle: "Passwords doesn't match. Try again.", style: AlertStyle.Warning)
        } else if self.oldPasswordField.text?.characters.count < 6 || self.newPasswordField.text?.characters.count < 6 || self.repeatPasswordField.text?.characters.count < 6 {
            log("Passwords doesn't match")
            SweetAlert().showAlert("Oooops!", subTitle: "Passwords should be at least 6 characters long.", style: AlertStyle.Warning)
        } else {
            let userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
            ApiHandler.changePassword(userId, oldPassword: self.oldPasswordField.text!, password: self.newPasswordField.text!)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let data):
                        log(String(response))
                        let json = JSON(data)
                        if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                            self.dismissViewControllerAnimated(true, completion: {})
                        } else if statusCode422.evaluateWithObject(String((response?.statusCode)!)) {
                            log(json["message"].string!)
                            log("\(json["errors"][0]["field"].string!) : \(json["errors"][0]["code"].string!)" )
                            SweetAlert().showAlert("Invalid old email", subTitle: "Please try again.", style: AlertStyle.Warning)
                        } else {
                            log(json["message"].string!)
                            SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                        }
                    case .Failure(let data, let error):
                        log("Request failed with error: \(error)")
                        SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                        if let data = data {
                            log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
        }
    }
    
    @IBAction func editingOldPasswordEnded(sender: AnyObject) {
        if self.oldPasswordField.text?.characters.count < 6 {
            highlightTextField(self.oldPasswordField, hasError: true)
            _oldPasswordError = true
        } else {
            highlightTextField(self.oldPasswordField, hasError: false)
            _oldPasswordError = false
        }
        
        toggleSaveButton()
    }
    
    
    @IBAction func editingNewPasswordEnded(sender: AnyObject) {
        if self.newPasswordField.text?.characters.count < 6 {
            highlightTextField(self.newPasswordField, hasError: true)
            _newPasswordError = true
        } else {
            highlightTextField(self.newPasswordField, hasError: false)
            _newPasswordError = false
        }
    }
    
    @IBAction func editingRepeatNewPassword(sender: AnyObject) {
        if self.repeatPasswordField.text?.characters.count < 6 && (self.newPasswordField.text != self.repeatPasswordField.text){
            highlightTextField(self.repeatPasswordField, hasError: true)
            _repeatNewPasswordError = true
        } else {
            highlightTextField(self.repeatPasswordField, hasError: false)
            _repeatNewPasswordError = false
            _passwordsMatch = true
        }
        
        toggleSaveButton()
    }
    
    func toggleSaveButton() {
        if !_newPasswordError && !_oldPasswordError && !_repeatNewPasswordError && _passwordsMatch {
            self.saveButton.enabled = true
            self.saveButton.tintColor = UIColor.blueColor()
        } else {
            self.saveButton.enabled = false
            self.saveButton.tintColor = CLR_MEDIUM_GRAY
        }
    }
    
    func highlightTextField(textField: UITextField, hasError: Bool) {
        if hasError {
            textField.textColor = CLR_NOTIFICATION_RED
        } else {
            textField.textColor = CLR_DARK_GRAY
        }
    }
    
}