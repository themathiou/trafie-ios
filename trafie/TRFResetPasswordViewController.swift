//
//  TRFResetPasswordViewController.swift
//  trafie
//
//  Created by mathiou on 19/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit

class TRFResetPasswordViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var backToLogin: UIButton!
    
    let emailValidator = NSPredicate(format:"SELF MATCHES %@", REGEX_EMAIL)
    
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
        valdateEmail()
        // TODO: check if email exist in our database and send email
        // TODO: show error messages if any
    }
    
    // Validate email
    func valdateEmail() {
        if emailValidator.evaluateWithObject(self.emailTextField.text) == true {
            self.errorMessage.hidden = true
        } else {
            self.errorMessage.text = ErrorMessage.InvalidEmail.rawValue
            self.errorMessage.hidden = false
        }
    }
}