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
    
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstnameField.delegate = self
        lastnameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self
//        self.registerButton.enabled = false
        
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
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
                
        }
    }
    
}
