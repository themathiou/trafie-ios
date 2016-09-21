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

  let tapViewRecognizer = UITapGestureRecognizer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tapViewRecognizer.addTarget(self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tapViewRecognizer)
    
    emailTextField.delegate = self
    passwordTextField.delegate = self
    self.loadingIndicator.isHidden = true
    self.errorMessage.isHidden = true
    self.registerLink.isHidden = false
    self.resetPasswordLink.isHidden = false
    
    self.toggleUIElementsBasedOnNetworkStatus() //should be called after UI elements initiated

    //Google Analytics Hit Watcher
    let name = "iOS : Login ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidAppear(_ animated: Bool) {
    let activitiesVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBarViewController") as! UITabBarController
    let status = Reach().connectionStatus()
    let isUserOnline: Bool = (status.description != ReachabilityStatus.unknown.description
      && status.description != ReachabilityStatus.offline.description)
    
    // Automatic login if user already has a token and a userId
    if isUserOnline && (UserDefaults.standard.object(forKey: "token") as? String)! != ""
      && (UserDefaults.standard.object(forKey: "refreshToken") as? String)! != ""
      && (UserDefaults.standard.object(forKey: "userId") as? String)! != "" {
      
      self.isLoading(true)
      
      let userId: String = UserDefaults.standard.object(forKey: "userId") as! String
      
      getLocalUserSettings(userId)
        .then { promise -> Void in
          if promise == .Success {
            self.present(activitiesVC, animated: true, completion: nil)
          } else if promise == .Unauthorised {
            let refreshToken: String = UserDefaults.standard.object(forKey: "refreshToken") as! String
            ApiHandler.authorizeWithRefreshToken(refreshToken)
              .responseJSON { response in
                
                Utils.log(String(response))
                Utils.showNetworkActivityIndicatorVisible(false)
                let JSONResponse = response.result.value!
                if response.result.isSuccess {
                  if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                    if JSONResponse["access_token"] !== nil {
                      let token : String = (JSONResponse["access_token"] as? String)!
                      let refreshToken: String = (JSONResponse["refresh_token"] as? String)!
                      
                      UserDefaults.standard.set(token, forKey: "token")
                      UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                      
                      getLocalUserSettings(userId)
                        .then { promise -> Void in
                          if promise == .Success {
                            self.present(activitiesVC, animated: true, completion: nil)
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
                } else if response.result.isFailure {
                  Utils.log("Request failed with error: \(response.result.error)")
                  self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
                  self.isLoading(false)
                  if let data = response.data {
                    Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8)!)")
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
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    Utils.dismissFirstResponder(view)
    return true;
  }
  
  /// Called when user taps main button. Validates fields and calls authorize and login functions
  @IBAction func login(_ sender: AnyObject) {
    validateFields()
    if self.errorMessage.text == "" {
      cleanErrorMessage()
      self.isLoading(true)
      self.authorizeAndLogin()
    }
  }
  
  
  /// Request an authorization token and logs user in.
  func authorizeAndLogin() {
    //grant_type, clientId and client_secret should be moved to a configuration properties file.
    let activitiesVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBarViewController") as! UITabBarController
    
    Utils.showNetworkActivityIndicatorVisible(true)
    ApiHandler.authorize(self.emailTextField.text!, password: self.passwordTextField.text!, grant_type: "password", client_id: "iphone", client_secret: "secret")
      .responseJSON { response in
        let JSONResponse = response.result.value!
        Utils.showNetworkActivityIndicatorVisible(false)
        if response.result.isSuccess {
          Utils.log("\(JSONResponse)")
          if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
            if JSONResponse["access_token"] !== nil {
              let token : String = (JSONResponse["access_token"] as? String)!
              let refreshToken: String = (JSONResponse["refresh_token"] as? String)!
              let userId : String = (JSONResponse["user_id"] as? String)!
              
              UserDefaults.standard.set(token, forKey: "token")
              UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
              UserDefaults.standard.set(userId, forKey: "userId")
              
              DBInterfaceHandler.fetchUserActivitiesFromServer(userId, isDeleted: "false")
              getLocalUserSettings(userId)
                .then { promise -> Void in
                  if promise == .Success {
                    self.present(activitiesVC, animated: true, completion: nil)
                  } else {
                    // logout the user
                    self.showErrorWithMessage("Something went wrong...")
                    self.isLoading(false)
                  }
              }
              
            } else {
              self.isLoading(false)
              self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
            }
          } else {
            self.isLoading(false)
            let error: String = (JSONResponse["error_description"] as? String)!
            if error == "Invalid resource owner credentials" {
              self.showErrorWithMessage(ErrorMessage.InvalidCredentials.rawValue)
            } else {
              self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
            }
          }
        } else if response.result.isFailure {
          Utils.log("Request failed with error: \(response.result.error)")
          self.showErrorWithMessage(ErrorMessage.GeneralError.rawValue)
          self.isLoading(false)
          if let data = response.data {
            Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8)!)")
          }
        }
    }
  }
  
  /**
   Enables/Disables the UI elements. Disabled elements are needed in loading states when we don't want
   user to interacts with app. Affected elements **emailTextField, passwordTextField, registerLink, resetPasswordLink**
   
   - Parameter isEnabled: Boolean that defines if elements will be enabled or not.
   */
  func enableUIElements(_ isEnabled: Bool) {
    self.emailTextField.isEnabled = isEnabled
    self.passwordTextField.isEnabled = isEnabled
    self.registerLink.isEnabled = isEnabled
    self.resetPasswordLink.isEnabled = isEnabled
    
    //if fields are enabled then links are visible
    self.registerLink.isHidden = !isEnabled
    self.resetPasswordLink.isHidden = !isEnabled
  }
  
  /**
   Activates/Deactivates loading state
   
   - Parameter loading: Boolean that defines if we are in loading state
   */
  func isLoading(_ isLoading: Bool) {
    self.loadingIndicator.isHidden = !isLoading
    self.emailTextField.isHidden = isLoading
    self.passwordTextField.isHidden = isLoading
    self.loginButton.isHidden = isLoading
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
        self.emailTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).cgColor
        self.emailTextField.layer.borderWidth = 1
      }
      
      if self.passwordTextField.text == ""{
        self.passwordTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).cgColor
        self.passwordTextField.layer.borderWidth = 1
      }
    }
    
  }
  
  func dismissKeyboard() {
    Utils.dismissFirstResponder(view)
  }
  
  func showErrorWithMessage(_ message: String) {
    self.errorMessage.isHidden = false
    self.errorMessage.text = message
  }
  
  func cleanErrorMessage() {
    self.errorMessage.isHidden = true
    self.errorMessage.text = ""
    self.emailTextField.layer.borderWidth = 0
    self.passwordTextField.layer.borderWidth = 0
  }
  
  func toggleUIElementsBasedOnNetworkStatus() {
    let status = Reach().connectionStatus()
    Utils.log("networkStatus: \(status)")
    switch status {
    case .unknown, .offline:
      self.loginButton.isEnabled = false
      self.emailTextField.isEnabled = false
      self.passwordTextField.isEnabled = false
      self.showErrorWithMessage(ErrorMessage.YouAreNotConnectedToTheInternet.rawValue)
    case .online(.wwan), .online(.wiFi):
      if self.errorMessage.text == ErrorMessage.YouAreNotConnectedToTheInternet.rawValue {
        self.errorMessage.text = " "
      }
      self.loginButton.isEnabled = true
      self.emailTextField.isEnabled = true
      self.passwordTextField.isEnabled = true
    }
  }
  
}
