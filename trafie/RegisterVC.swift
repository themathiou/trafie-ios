//
//  RegisterViewController.swift
//  trafie
//
//  Created by mathiou on 21/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit


class RegisterVC : UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginLink: UIButton!
    
    /// Done button for keyboards
    var doneButton: UIButton = keyboardButtonCentered
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let name = "iOS : Register ViewController"
        Utils.googleViewHitWatcher(name);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegisterVC.showConnectionStatusChange(_:)), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()

        firstnameField.delegate = self
        lastnameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        self.loadingIndicator.hidden = true
        self.errorMessage.hidden = false
        self.errorMessage.text = " "
        
        self.toggleUIElementsBasedOnNetworkStatus() //should be called after UI elements initiated
        
        // Done button for keyboard and pickers
        doneButton.addTarget(self, action: #selector(RegisterVC.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        Utils.dismissFirstResponder(view)
        return true
    }
    
    // Firstname
    @IBAction func firstNameEditingDidEnd(sender: UITextField) {
        if self.firstnameField.text?.characters.count < 2 || self.firstnameField.text?.characters.count > 35 {
            self.firstnameField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.firstnameField.layer.borderWidth = 1
            showErrorWithMessage(ErrorMessage.FieldLengthShouldBe2To35.rawValue)
        } else if Utils.isTextFieldValid(self.firstnameField, regex: REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS) {
            self.lastnameField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.lastnameField.layer.borderWidth = 1
            showErrorWithMessage(ErrorMessage.FieldShouldContainsOnlyAZDashQuotSpace.rawValue)
        } else {
            self.firstnameField.layer.borderWidth = 0
            self.errorMessage.text = " "
        }
    }
    
    @IBAction func firstNameEditingDidBegin(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }
    
    // Lastname
    @IBAction func lastNameEditingDidBegin(sender: UITextField) {
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton
    }
    
    @IBAction func lastNameEditingDidEnd(sender: UITextField) {
        if self.lastnameField.text?.characters.count < 2 || self.lastnameField.text?.characters.count > 35 {
            self.lastnameField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.lastnameField.layer.borderWidth = 1
            showErrorWithMessage(ErrorMessage.FieldLengthShouldBe2To35.rawValue)
        } else if Utils.isTextFieldValid(self.lastnameField, regex: REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS) {
            self.lastnameField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.lastnameField.layer.borderWidth = 1
            showErrorWithMessage(ErrorMessage.FieldShouldContainsOnlyAZDashQuotSpace.rawValue)
        } else {
            self.lastnameField.layer.borderWidth = 0
            self.errorMessage.text = " "
        }
    }

    // Email
    @IBAction func emailEditingDidBegin(sender: UITextField) {
        doneButton.tag = 3
        sender.inputAccessoryView = doneButton
    }

    @IBAction func emailEditingDidEnd(sender: UITextField) {
        if Utils.validateEmail(self.emailField.text!) == .InvalidEmail {
            self.emailField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.emailField.layer.borderWidth = 1
            showErrorWithMessage(ErrorMessage.InvalidEmail.rawValue)
        } else {
            self.emailField.layer.borderWidth = 0
            self.errorMessage.text = " "
        }
    }
    
    // Password
    @IBAction func passwordEditingDidBegin(sender: UITextField) {
        doneButton.tag = 4
        sender.inputAccessoryView = doneButton
    }

    @IBAction func passwordEditingDidEnd(sender: UITextField) {
        if self.passwordField.text?.characters.count < 6 {
            self.passwordField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.passwordField.layer.borderWidth = 1
            showErrorWithMessage(ErrorMessage.ShortPassword.rawValue)
        } else {
            self.passwordField.layer.borderWidth = 0
            self.errorMessage.text = " "
        }
    }

    /// calls function to validate fields and then registers user data
    @IBAction func register(sender: AnyObject) {
        validateFields()
        if self.errorMessage.text == " " {
            cleanErrorMessage()
            enableUIElements(false)
            loadingOn()
            registerUserData()
        }
    }
    
    /// Registers user data. If login is succesful logs user in with his credentials and security token.
    func registerUserData() {
        Utils.dismissFirstResponder(view)
        Utils.showNetworkActivityIndicatorVisible(true)
        ApiHandler.register(self.firstnameField.text!, lastName: self.lastnameField.text!, email: self.emailField.text!, password: self.passwordField.text!)
            .responseJSON { response in
                
                Utils.showNetworkActivityIndicatorVisible(false)
                if response.result.isSuccess {
                    
                    let json = JSON(response.result.value!)
                    Utils.log("\(json)")
                    // IF registration is OK, then login with given credentials
                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                        
                        SweetAlert().showAlert("Welcome!", subTitle: "Please check your email and click \"Activate\" in the message we just send you at \n \(self.emailField.text!).", style: AlertStyle.Success, buttonTitle:"Got it") { (confirmed) -> Void in
                            self.authorizeAndLogin()
                        }
                    } else {
                        self.cleanErrorMessage() // clean old error messages in order to show errors from server.
                        if let errorField = json["errors"][0]["field"].string {
                            var errorMessage: String = ErrorMessage.GeneralError.rawValue
                            
                            switch(errorField) {
                            case "email":
                                if let errorCode = json["errors"][0]["code"].string {
                                    if errorCode == "already_exists" {
                                        errorMessage = ErrorMessage.EmailAlreadyExists.rawValue
                                    }
                                }
                                Utils.highlightErrorTextField(self.emailField, hasError: true)
                            case "firstName":
                                if let errorCode = json["errors"][0]["code"].string {
                                    if errorCode == "invalid" {
                                        errorMessage = ErrorMessage.FieldShouldContainsOnlyAZDashQuotSpace.rawValue
                                    }
                                }
                                Utils.highlightErrorTextField(self.firstnameField, hasError: true)
                            case "lastName":
                                if let errorCode = json["errors"][0]["code"].string {
                                    if errorCode == "invalid" {
                                        errorMessage = ErrorMessage.FieldShouldContainsOnlyAZDashQuotSpace.rawValue
                                    }
                                }
                                Utils.highlightErrorTextField(self.lastnameField, hasError: true)
                            case "password":
                                if let errorCode = json["errors"][0]["code"].string {
                                    if errorCode == "invalid" {
                                        errorMessage = ErrorMessage.ShortPassword.rawValue
                                    }
                                }
                                Utils.highlightErrorTextField(self.passwordField, hasError: true)
                            default:
                                errorMessage = ErrorMessage.GeneralError.rawValue
                            }
                            
                            self.showErrorWithMessage(errorMessage)
                            self.enableUIElements(true)
                        }
                    }
                } else if response.result.isFailure {
                    Utils.log("Request failed with error: \(response.result.error)")
                    self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
                    if let data = response.data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }

                
                self.enableUIElements(true)
                self.loadingOff()
        }
    }
    
    /**
     Enables/Disables the UI elements. Disabled elements are needed in loading states when we don't want
     user to interacts with app. Affected elements **firstnameField, lastnameField, emailField, passwordField, loginLink**
     
     - Parameter isEnabled: Boolean that defines if elements will be enabled or not.
     */
    func enableUIElements(isEnabled: Bool) {
        self.firstnameField.enabled = isEnabled
        self.lastnameField.enabled = isEnabled
        self.emailField.enabled = isEnabled
        self.passwordField.enabled = isEnabled
        self.loginLink.enabled = isEnabled
    }
    
    /// Activates loading state
    func loadingOn() {
        self.loadingIndicator.hidden = false
        self.loadingIndicator.startAnimating()
    }
    
    /// Deactivates loading state
    func loadingOff() {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
    }
    
    /// Validates fields **firstnameField, lastnameField, emailField, passwordField**
    func validateFields() {
        self.cleanErrorMessage()
        if self.firstnameField.text == "" || self.lastnameField.text == "" || self.emailField.text == ""
            || self.passwordField.text == "" {
            showErrorWithMessage(ErrorMessage.AllFieldsAreRequired.rawValue)
            
            if self.firstnameField.text == "" {
                Utils.highlightErrorTextField(self.firstnameField, hasError: true)
            }
                
            if self.lastnameField.text == "" {
                Utils.highlightErrorTextField(self.lastnameField, hasError: true)
            }
                
            if self.emailField.text == "" {
                Utils.highlightErrorTextField(self.emailField, hasError: true)
            }
                
            if self.passwordField.text == "" {
                Utils.highlightErrorTextField(self.passwordField, hasError: true)
            }
        }
    }

    
    func showErrorWithMessage(message: String) {
        self.errorMessage.text = message
    }
    
    func cleanErrorMessage() {
        self.errorMessage.text = " "
        self.firstnameField.layer.borderWidth = 0
        self.lastnameField.layer.borderWidth = 0
        self.emailField.layer.borderWidth = 0
        self.passwordField.layer.borderWidth = 0
    }
    
    /// Function called from all "done" buttons of keyboards and pickers.
    func doneButton(sender: UIButton) {
        Utils.dismissFirstResponder(view)
    }

    /// Request an authorization token and logs user in.
    func authorizeAndLogin() {
        //grant_type, clientId and client_secret should be moved to a configuration properties file.
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController
        
        Utils.showNetworkActivityIndicatorVisible(true)
        ApiHandler.authorize(self.emailField.text!, password: self.passwordField.text!, grant_type: "password", client_id: "iphone", client_secret: "secret")
            .responseJSON { response in
                Utils.showNetworkActivityIndicatorVisible(false)
                let JSONResponse = response.result.value!
                if response.result.isSuccess {
                    Utils.log("\(JSONResponse)")
                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                        if JSONResponse["access_token"] !== nil {
                            let token : String = (JSONResponse["access_token"] as? String)!
                            let refreshToken: String = (JSONResponse["refresh_token"] as? String)!
                            let userId : String = (JSONResponse["user_id"] as? String)!
                            
                            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                            NSUserDefaults.standardUserDefaults().setObject(refreshToken, forKey: "refreshToken")
                            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
                            
                            getLocalUserSettings(userId)
                                .then { promise -> Void in
                                    if promise == .Success {
                                        self.presentViewController(activitiesVC, animated: true, completion: nil)
                                    } else {
                                        // logout the user
                                        self.showErrorWithMessage("Something went wrong...")
                                    }
                            }
                            
                        } else {
                            print(JSONResponse["error"])
                            self.showErrorWithMessage(ErrorMessage.InvalidCredentials.rawValue)
                            self.enableUIElements(true)
                            self.loadingOff()
                        }
                    } else {
                        self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
                    }
                } else if response.result.isFailure {
                    Utils.log("Request failed with error: \(response.result.error)")
                    self.enableUIElements(true)
                    self.loadingOff()
                    if let data = response.data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
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
            self.showErrorWithMessage(ErrorMessage.YouAreNotConnectedToTheInternet.rawValue)
            self.registerButton.enabled = false
        case .Online(.WWAN), .Online(.WiFi):
            if self.errorMessage.text == ErrorMessage.YouAreNotConnectedToTheInternet.rawValue {
                self.errorMessage.text = ""
            }
            self.registerButton.enabled = true
        }
    }
}
