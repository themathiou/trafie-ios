//
//  LoginViewController.swift
//  trafie
//
//  Created by mathiou on 8/9/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class LoginVC: UIViewController, UITextFieldDelegate
{

    // MARK: Outlets and Variables
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var registerLink: UIButton!
    @IBOutlet weak var resetPasswordLink: UIButton!
    
    /// Keyboard done button
    var doneButton: UIButton = keyboardButtonCentered
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.loadingIndicator.hidden = true
        self.errorMessage.hidden = true
        self.registerLink.hidden = false
        self.resetPasswordLink.hidden = false
        
        // Done button for keyboard and pickers
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
    }
    
    override func viewDidAppear(animated: Bool) {
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController
        
        // Automatic login if user already has a token and a userId
        if (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)! != ""
            && (NSUserDefaults.standardUserDefaults().objectForKey("refreshToken") as? String)! != ""
            && (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)! != "" {
                
            self.isLoading(true)
            
            let userId: String = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String

            getLocalUserSettings(userId)
            .then { promise -> Void in
                if promise == .Success {
                    self.presentViewController(activitiesVC, animated: true, completion: nil)
                } else if promise == .Unauthorised {
                    let refreshToken: String = NSUserDefaults.standardUserDefaults().objectForKey("refreshToken") as! String
                    ApiHandler.authorizeWithRefreshToken(refreshToken)
                        .responseJSON { request, response, result in
                            
                            Utils.log(String(response))
                            Utils.showNetworkActivityIndicatorVisible(false)
                            switch result {
                            case .Success(let JSONResponse):
                                Utils.log("\(JSONResponse)")
                                if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                                    if JSONResponse["access_token"] !== nil {
                                        let token : String = (JSONResponse["access_token"] as? String)!
                                        let refreshToken: String = (JSONResponse["refresh_token"] as? String)!
                                        
                                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                                        NSUserDefaults.standardUserDefaults().setObject(refreshToken, forKey: "refreshToken")
                                        
                                        getLocalUserSettings(userId)
                                            .then { promise -> Void in
                                                if promise == .Success {
                                                    self.presentViewController(activitiesVC, animated: true, completion: nil)
                                                } else {
                                                    // logout the user
                                                    self.showErrorWithMessage("Something went wrong...")
                                                    self.isLoading(false)
                                                }
                                        }
                                        
                                    } else {
                                        self.isLoading(false)
                                        print(JSONResponse["error"])
                                        self.showErrorWithMessage(ErrorMessage.InvalidCredentials.rawValue)
                                    }
                                } else {
                                    self.isLoading(false)
                                    self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
                                }
                                
                            case .Failure(let data, let error):
                                Utils.log("Request failed with error: \(error)")
                                SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                                self.isLoading(false)
                                if let data = data {
                                    Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                                }
                            }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK:- Methods

    
    /// called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        Utils.dismissFirstResponder(view)
        return true;
    }
    
    /// Called when user taps main button. Validates fields and calls authorize and login functions
    @IBAction func login(sender: AnyObject) {
        validateFields()
        if self.errorMessage.text == "" {
            cleanErrorMessage()
            self.isLoading(true)
            self.authorizeAndLogin()
        }
    }

    @IBAction func emailEditingDidBegin(sender: UITextField) {
        sender.inputAccessoryView = doneButton
    }
    
    @IBAction func passwordEditingDidBegin(sender: UITextField) {
        sender.inputAccessoryView = doneButton
    }
    

    /// Request an authorization token and logs user in.
    func authorizeAndLogin() {
        //grant_type, clientId and client_secret should be moved to a configuration properties file.
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController

        Utils.showNetworkActivityIndicatorVisible(true)
        ApiHandler.authorize(self.emailTextField.text!, password: self.passwordTextField.text!, grant_type: "password", client_id: "iphone", client_secret: "secret")
            .responseJSON { request, response, result in

                Utils.showNetworkActivityIndicatorVisible(false)
                switch result {
                case .Success(let JSONResponse):
                    Utils.log("\(JSONResponse)")
                    if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
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
                                        self.isLoading(false)
                                    }
                            }
                            
                        } else {
                            self.isLoading(false)
                            print(JSONResponse["error"])
                            self.showErrorWithMessage(ErrorMessage.InvalidCredentials.rawValue)
                        }
                    } else {
                        self.isLoading(false)
                        self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
                    } 
                case .Failure(let data, let error):
                    Utils.log("Request failed with error: \(error)")
                    SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                    self.isLoading(false)
                    if let data = data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    /**
     Enables/Disables the UI elements. Disabled elements are needed in loading states when we don't want
     user to interacts with app. Affected elements **emailTextField, passwordTextField, registerLink, resetPasswordLink**
     
     - Parameter isEnabled: Boolean that defines if elements will be enabled or not.
     */
    func enableUIElements(isEnabled: Bool) {
        self.emailTextField.enabled = isEnabled
        self.passwordTextField.enabled = isEnabled
        self.registerLink.enabled = isEnabled
        self.resetPasswordLink.enabled = isEnabled
        
        //if fields are enabled then links are visible
        self.registerLink.hidden = !isEnabled
        self.resetPasswordLink.hidden = !isEnabled
    }
    
    /**
     Activates/Deactivates loading state
     
     - Parameter loading: Boolean that defines if we are in loading state
    */
    func isLoading(isLoading: Bool) {
        self.loadingIndicator.hidden = !isLoading
        self.emailTextField.hidden = isLoading
        self.passwordTextField.hidden = isLoading
        self.loginButton.hidden = isLoading
        enableUIElements(!isLoading)
        if isLoading {
            self.loadingIndicator.startAnimating()
        } else {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    /// Validates email and password field.
    func validateFields() {
        self.cleanErrorMessage()
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            showErrorWithMessage(ErrorMessage.EmailAndPasswordAreRequired.rawValue)
            
            if self.emailTextField.text == "" {
                self.emailTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.emailTextField.layer.borderWidth = 1
            }
            
            if self.passwordTextField.text == ""{
                self.passwordTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.passwordTextField.layer.borderWidth = 1
            }
        }
        
    }
    
    /// Function called from all "done" buttons of keyboards and pickers.
    func doneButton(sender: UIButton) {
        Utils.dismissFirstResponder(view)
    }
    
    func showErrorWithMessage(message: String) {
        self.errorMessage.hidden = false
        self.errorMessage.text = message
    }
    
    func cleanErrorMessage() {
        self.errorMessage.hidden = true
        self.errorMessage.text = ""
        self.emailTextField.layer.borderWidth = 0
        self.passwordTextField.layer.borderWidth = 0
    }

}
