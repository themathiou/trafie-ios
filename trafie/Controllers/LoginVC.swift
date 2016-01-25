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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.loadingIndicator.hidden = true
        self.errorMessage.hidden = true
        self.registerLink.hidden = false
        self.resetPasswordLink.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController
        
        // Automatic login if user already has a token and a userId
        // TODO: enhance for token expiration
        if (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)! != "" && (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)! != ""{
            enableUIElements(false)
            loadingOn()
            
            let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String

            getLocalUserSettings(userId)
            .then { promise -> Void in
                if promise == .Success {
                    self.presentViewController(activitiesVC, animated: true, completion: nil)
                } else if promise == .Unauthorised {
                    self.enableUIElements(true)
                    self.loadingOff()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK:- Methods

    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    // called when user taps main button
    @IBAction func login(sender: AnyObject) {
        validateFields()
        if self.errorMessage.text == "" {
            cleanErrorMessage()
            enableUIElements(false)
            loadingOn()
            authorizeAndLogin()
        }
    }
    
    func authorizeAndLogin() {
        //grant_type, clientId and client_secret should be moved to a configuration properties file.
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController
        ApiHandler.authorize(self.emailTextField.text, password: self.passwordTextField.text, grant_type: "password", client_id: "iphone", client_secret: "secret")
            .responseJSON { request, response, result in
                switch result {
                case .Success(let JSONResponse):
                    log("\(JSONResponse)")
                    if JSONResponse["access_token"] !== nil {
                        let token : String = (JSONResponse["access_token"] as? String)!
                        let userId : String = (JSONResponse["user_id"] as? String)!
                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                        NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
                        
                        getLocalUserSettings(userId)
                        .then { promise -> Void in
                            if promise == .Success {
                                self.presentViewController(activitiesVC, animated: true, completion: nil)
                            } else {
                                // TODO: WTF is this error text?
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
                    
                case .Failure(let data, let error):
                    log("Request failed with error: \(error)")
                    self.enableUIElements(true)
                    self.loadingOff()
                    if let data = data {
                        log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    func enableUIElements(isEnabled: Bool) {
        self.emailTextField.enabled = isEnabled
        self.passwordTextField.enabled = isEnabled
        self.registerLink.enabled = isEnabled
        self.resetPasswordLink.enabled = isEnabled
        
        //if fields are enabled then links are visible
        self.registerLink.enabled = !isEnabled
        self.resetPasswordLink.enabled = !isEnabled
    }
    
    func loadingOn() {
        self.loadingIndicator.hidden = false
        self.loginButton.hidden = true
        self.loadingIndicator.startAnimating()
    }
    
    func loadingOff() {
        self.loadingIndicator.stopAnimating()
        self.loginButton.hidden = false
        self.loadingIndicator.hidden = true
    }
    
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
