//
//  TRFRegisterViewController.swift
//  trafie
//
//  Created by mathiou on 21/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit


class TRFRegisterViewController : UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginLink: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstnameField.delegate = self
        lastnameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self
        self.loadingIndicator.hidden = true
        self.errorMessage.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func register(sender: AnyObject) {
        validateFields()
        if self.errorMessage.text == "" {
            cleanErrorMessage()
            enableUIElements(false)
            loadingOn()
            registerUserData()
        }
    }
    
    func registerUserData() {
        TRFApiHandler.register(self.firstnameField.text, lastName: self.lastnameField.text, email: self.emailField.text, password: self.passwordField.text, repeatPassword: self.repeatPasswordField.text)
            .responseJSON { request, response, result in
                print("--- Register ---")
                print(request)
                print(response)
                print(result)
                switch result {
                case .Success(let JSONResponse):
                    print("--- Register -> Success ---")
                    print(JSONResponse)
                    
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    self.showErrorWithMessage(ErrorMessage.RegistrationGeneralError.rawValue)
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
                
                self.enableUIElements(true)
                self.loadingOff()
        }
    }
    
    func enableUIElements(isEnabled: Bool) {
        self.firstnameField.enabled = isEnabled
        self.lastnameField.enabled = isEnabled
        self.emailField.enabled = isEnabled
        self.passwordField.enabled = isEnabled
        self.repeatPasswordField.enabled = isEnabled
        self.loginLink.enabled = isEnabled
    }
    
    func loadingOn() {
        self.loadingIndicator.hidden = false
        self.loadingIndicator.startAnimating()
    }
    
    func loadingOff() {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
    }
    
    func validateFields() {
        self.cleanErrorMessage()
        if self.firstnameField.text == "" || self.lastnameField.text == "" || self.emailField.text == ""
            || self.passwordField.text == "" || self.repeatPasswordField.text == "" {
            showErrorWithMessage(ErrorMessage.AllFieldsAreRequired.rawValue)
            
            if self.firstnameField.text == "" {
                self.firstnameField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.firstnameField.layer.borderWidth = 1
            }
                
            if self.lastnameField.text == "" {
                self.lastnameField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.lastnameField.layer.borderWidth = 1
            }
                
            if self.emailField.text == "" {
                self.emailField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.emailField.layer.borderWidth = 1
            }
                
            if self.passwordField.text == "" {
                self.passwordField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.passwordField.layer.borderWidth = 1
            }
            
            if self.repeatPasswordField.text == "" {
                self.repeatPasswordField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
                self.repeatPasswordField.layer.borderWidth = 1
            }
            
        } else if self.passwordField.text != self.repeatPasswordField.text {
            showErrorWithMessage(ErrorMessage.PasswordAndRepeatPasswordShouldMatch.rawValue)
            self.passwordField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.passwordField.layer.borderWidth = 1
            self.repeatPasswordField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.repeatPasswordField.layer.borderWidth = 1
        }
        
    }
    
    func showErrorWithMessage(message: String) {
        self.errorMessage.hidden = false
        self.errorMessage.text = message
    }
    
    func cleanErrorMessage() {
        self.errorMessage.hidden = true
        self.errorMessage.text = ""
        self.firstnameField.layer.borderWidth = 0
        self.lastnameField.layer.borderWidth = 0
        self.emailField.layer.borderWidth = 0
        self.passwordField.layer.borderWidth = 0
        self.repeatPasswordField.layer.borderWidth = 0

    }

    
}
