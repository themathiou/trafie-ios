//
//  UserEmailVC.swift
//  trafie
//
//  Created by mathiou on 07/02/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import UIKit

class UserEmailVC : UIViewController, UIScrollViewDelegate {

  let userEmail = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
  var isUserVerified: Bool = false //init value only
  
  @IBOutlet weak var emptyStateImage: UIImageView!
  @IBOutlet weak var titleText: UILabel!
  @IBOutlet weak var infoText: UILabel!
  @IBOutlet weak var actionButton: UIButton!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : UserEmail ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    isUserVerified = NSUserDefaults.standardUserDefaults().boolForKey("isVerified")
    self.updateUI(isUserVerified)
  }

  /// Handles the action for empty states button
  @IBAction func resendEmailVerification(sender: AnyObject) {
    Utils.showNetworkActivityIndicatorVisible(true)
    ApiHandler.resendEmailVerificationCodeRequest()
      .responseJSON { response in
        Utils.showNetworkActivityIndicatorVisible(false)
        
        if response.result.isSuccess {
          if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
            SweetAlert().showAlert("Email Send", subTitle: "Check the email we have sent you and follow the link!", style: AlertStyle.Success)
          } else if Utils.validateTextWithRegex(StatusCodesRegex._404.rawValue, text: String((response.response!.statusCode))) {
            // SHOULD NEVER HAPPEN.
            // LOGOUT USER
            Utils.clearLocalUserData()
            let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
            self.presentViewController(loginVC, animated: true, completion: nil)
          } else if Utils.validateTextWithRegex(StatusCodesRegex._422.rawValue, text: String((response.response!.statusCode))) {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isVerified")
            self.updateUI(true)
            SweetAlert().showAlert("All good!", subTitle: "This email is already verified.", style: AlertStyle.Success)
          } else {
            SweetAlert().showAlert("Something went wrong!", subTitle: "Email could not be sent! Please try again.", style: AlertStyle.Error)
          }
        } else if response.result.isFailure {
          Utils.log("Request for resend email failed with error: \(response.result.error)")
          SweetAlert().showAlert("Something went wrong!", subTitle: "Email could not be sent! Please try again.", style: AlertStyle.Error)
          
          if let data = response.data {
            Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
          }
        }
    }
  }
  
  /// Dismiss the view
  @IBAction func dismissView(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: {})
  }
  
  /// Set elements according the email verification status.
  func updateUI(isUserVerified: Bool) {
    self.emptyStateImage.image = isUserVerified ? UIImage(named: "email_confirmed") : UIImage(named: "email_pending")
    self.titleText.text = isUserVerified ? "Great!" : "\(self.userEmail!) has not been verified yet!"
    self.infoText.text = isUserVerified ? "Your email \(self.userEmail!) has been verified." : "Check the email we have sent you and follow the link. \n Cannot find it? Tap below to send again."
    self.actionButton.hidden = isUserVerified
  }
}
