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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTextField.delegate = self
        self.errorMessage.hidden = true
        self.loadingIndicator.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendEmail(sender: AnyObject) {
        let validationResponse : ErrorMessage = validateEmail()
        let requestedEmail = self.emailTextField.text!

        switch validationResponse {
        case .InvalidEmail:
            self.errorMessage.text = ErrorMessage.InvalidEmail.rawValue
            self.errorMessage.hidden = false
        case .NoError:
            ApiHandler.resetPasswordRequest(requestedEmail)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(_):
                        let statusCode : Int = response!.statusCode
                        switch statusCode {
                        case 200:
                            self.errorMessage.hidden = false
                            self.emailTextField.hidden = true
                            self.sendEmailButton.hidden = true
                            self.errorMessage.text = "Great! We send you a reset link at \(requestedEmail). Open it and follow the steps in order to reset your password."
                        case 404:
                            self.errorMessage.text = "We can't find \(requestedEmail). Check your email and try again."
                            self.errorMessage.hidden = false
                        default:
                            self.errorMessage.text = "Something went wrong with your request. Please try again in a minute."
                            self.errorMessage.hidden = false
                        }

                        
                    case .Failure(let data, let error):
                        log("Request failed with error: \(error)")
                        self.errorMessage.text = "Something went wrong with your request. Please try again in a minute."
                        self.errorMessage.hidden = false
                        if let data = data {
                            log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
        default:
            self.errorMessage.text = "Default Case"
            self.errorMessage.hidden = false
        }
    }
    
    // Validate email
    func validateEmail() -> ErrorMessage {
        return emailValidator.evaluateWithObject(self.emailTextField.text) == true ? .NoError : .InvalidEmail
    }
}