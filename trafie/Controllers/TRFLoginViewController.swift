//
//  TRFLoginViewController.swift
//  trafie
//
//  Created by mathiou on 8/9/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit

class TRFLoginViewController : UIViewController, UITextFieldDelegate
{
    /**
    States in which the Login Page can be.

    - Login: Login Page.
    - Register: Registration Page.
    - ForgotPassword: A page with an input field for email in which we'll send the change-password-mail.
    */
    enum States : String {
        case Login = "Login"
        case Register = "Register"
        case ForgotPassword = "ForgotPassword"
    }

    // MARK: Outlets and Variables
    var currentState: States = .Login
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainActionButton: UIButton!
    @IBOutlet weak var leftLink: UIButton! //change between Login and Register
    @IBOutlet weak var forgotPasswordLink: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailTextField.delegate=self
        passwordTextField.delegate=self

        //Inititialize state when Login page loaded.
        currentState = .Login
        applyChangesInUIForState(currentState)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK:- Methods
    ///Action to change currentState
    @IBAction func changeStateTo(sender: UIButton){
        switch sender {
        case leftLink: //change between Login and Register
            if(currentState == .Login) {
                currentState = .Register
            } else if(currentState == .Register || currentState == .ForgotPassword) {
                currentState = .Login
            }
        case forgotPasswordLink:
            currentState = .ForgotPassword
        default:
            currentState = .Login
        }
        applyChangesInUIForState(currentState)
    }

    ///Makes the proper changes in UI elements in order to have everything in place
    ///
    ///:param: state The state in which we navigate to.
    func applyChangesInUIForState(state: States) {
        switch currentState {
        case .Login:
            leftLink.setTitle("Register", forState: .Normal)
            forgotPasswordLink.hidden = false
            passwordTextField.hidden = false
            mainActionButton.setTitle("Login", forState: .Normal)
        case .Register:
            leftLink.setTitle("Login", forState: .Normal)
            forgotPasswordLink.hidden = false
            passwordTextField.hidden = false
            mainActionButton.setTitle("Register", forState: .Normal)
        case .ForgotPassword:
            passwordTextField.hidden = true
            leftLink.setTitle("Register", forState: .Normal)
            forgotPasswordLink.hidden = true
            mainActionButton.setTitle("Send me email", forState: .Normal)
        }
        print("Current State: \(currentState.rawValue)")
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    
    // called when user clicks login button
    @IBAction func authorizeLogin(sender: AnyObject) {
        //grant_type, clientId and client_secret should be moved to a configuration properties file.
        let activitiesvc = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController
        
        TRFApiHandler.authorize(self.emailTextField.text, password: self.passwordTextField.text, grant_type: "password", client_id: "iphone", client_secret: "secret")
            .responseJSON { request, response, result in
                switch result {
                case .Success(let JSONResponse):
                    print("--- Success ---")
                    //print(JSONResponse)

                    let token : String = (JSONResponse["access_token"] as? String)!
                    let userId : String = (JSONResponse["user_id"] as? String)!
                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                    NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")

                    self.presentViewController(activitiesvc, animated: true, completion: nil)
                
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
                
            }
    }
    


}
