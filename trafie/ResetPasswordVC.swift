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
    
    /// Done button for keyboards
    var doneButton: UIButton = keyboardButtonCentered
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTextField.delegate = self
        self.errorMessage.hidden = true
        self.loadingIndicator.hidden = true
        
        // Done button for keyboard and pickers
        doneButton.addTarget(self, action: #selector(ResetPasswordVC.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailEditingDidBegin(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }
    
    @IBAction func emailEditingDidEnd(sender: UITextField) {
        if Utils.validateEmail(self.emailTextField.text!) == .InvalidEmail {
            self.emailTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            self.emailTextField.layer.borderWidth = 1
            self.errorMessage.hidden = false
            self.errorMessage.text = ErrorMessage.InvalidEmail.rawValue
        } else {
            self.emailTextField.layer.borderWidth = 0
            self.errorMessage.hidden = true
            self.errorMessage.text = ""
        }
    }
    
    /// Sends request for email which contains password-reset hash.
    @IBAction func sendEmail(sender: AnyObject) {
        Utils.dismissFirstResponder(view)
        let validationResponse : ErrorMessage = Utils.validateEmail(self.emailTextField.text!)
        let requestedEmail = self.emailTextField.text!

        switch validationResponse {
        case .InvalidEmail:
            self.errorMessage.text = ErrorMessage.InvalidEmail.rawValue
            self.errorMessage.hidden = false
        case .NoError:
            Utils.showNetworkActivityIndicatorVisible(true)
            ApiHandler.resetPasswordRequest(requestedEmail)
                .responseJSON { request, response, result in
                    Utils.showNetworkActivityIndicatorVisible(false)
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
                        Utils.log("Request failed with error: \(error)")
                        self.errorMessage.text = "Something went wrong with your request. Please try again in a minute."
                        self.errorMessage.hidden = false
                        if let data = data {
                            Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
        default:
            self.errorMessage.text = "Default Case"
            self.errorMessage.hidden = false
        }
    }
    
    /// Function called from all "done" buttons of keyboards and pickers.
    func doneButton(sender: UIButton) {
        Utils.dismissFirstResponder(view)
    }
}