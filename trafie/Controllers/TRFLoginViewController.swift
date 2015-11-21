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

    // MARK: Outlets and Variables
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainActionButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.loadingIndicator.hidden = true

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
       authorizeLogin()
    }
    
    
    func authorizeLogin() {
        //grant_type, clientId and client_secret should be moved to a configuration properties file.
        let activitiesVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabBarViewController") as! UITabBarController
        self.loadingIndicator.hidden = false
        self.loadingIndicator.startAnimating()
        
        TRFApiHandler.authorize(self.emailTextField.text, password: self.passwordTextField.text, grant_type: "password", client_id: "iphone", client_secret: "secret")
            .responseJSON { request, response, result in
                print("--- Authorize ---")
                print(request)
                print(response)
                print(result)
                switch result {
                case .Success(let JSONResponse):
                    print("--- Authorize -> Success ---")

                    if JSONResponse["access_token"] !== nil {
                        let token : String = (JSONResponse["access_token"] as? String)!
                        let userId : String = (JSONResponse["user_id"] as? String)!
                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                        NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
                        
                        getLocalUserSettings()
                        
                        self.presentViewController(activitiesVC, animated: true, completion: nil)
                    } else {
                        print(JSONResponse["error"])
                    }
                
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
                
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.hidden = true
            }
    }

}
