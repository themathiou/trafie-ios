//
//  ProfileViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class ProfileVC: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var mainDiscipline: UILabel!
    @IBOutlet weak var isMale: UILabel!
    @IBOutlet weak var birthday: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var userEmail: UITableViewCell!
    @IBOutlet weak var emailStatusIndication: UIImageView!
    @IBOutlet weak var emailStatusRefreshSpinner: UIActivityIndicatorView!
    
    let tapEmailIndication = UITapGestureRecognizer()
    
    @IBOutlet var reportProblemButton: UIButton!
    

    let dateformatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadProfile:", name:"reloadProfile", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)

        tapEmailIndication.addTarget(self, action: "showEmailIndicationView")
        self.emailStatusIsUpdating(false)
        self.userEmail.addGestureRecognizer(tapEmailIndication)

        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        setSettingsValuesFromNSDefaultToViewFields()
    }
    
    // MARK:- Network Connection
    /**
        Notification handler for Network Status Change

        - Parameter notification: notification that handles event from Reachability Status Change
    */
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
    }
    
    //email
    /**
    Function that activates the action-sheet for feedback options.
    1. Report a problem 
    2. Request new feature 
    3. Cancel

    - Parameter sender: the object that activates the actionsheet
    */
    @IBAction func showActionSheet(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .Alert)
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        
        let systemInfo: String = "Device: \(UIDevice.currentDevice().model) <br> Operating System: \(UIDevice.currentDevice().systemVersion)"
        
        let reportProblem = UIAlertAction(title: "Report a problem", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            picker.setToRecipients(["support@trafie.com"])
            picker.setSubject("Report a problem")
            picker.setMessageBody("The problem I found in trafie is: <br><br><br> \(systemInfo)", isHTML: true)
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let requestFeature = UIAlertAction(title: "Request New Feature", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            picker.setToRecipients(["support@trafie.com"])
            picker.setSubject("Request a feature")
            picker.setMessageBody("What I would love to see in trafie is:", isHTML: true)
            self.presentViewController(picker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            Utils.log("Cancelled")
        })
        
        optionMenu.addAction(reportProblem)
        optionMenu.addAction(requestFeature)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /**
    Prompt a logout dialog for loging out. 
    If user accepts, logs out the user and clean all data related to him.
    If cancel closes the prompt window.
    
    - Parameter sender: the object that activates the logout action.
    */
    @IBAction func logout(sender: AnyObject) {
        SweetAlert().showAlert("Logout", subTitle: "Are you sure?", style: AlertStyle.None, buttonTitle:"Stay here", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Logout", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                Utils.log("Logout Cancelled")
            }
            else {
                Utils.clearLocalUserData()
                let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
                self.presentViewController(loginVC, animated: true, completion: nil)
            }
        }
        
    }

    @objc private func reloadProfile(notification: NSNotification){
        self.setSettingsValuesFromNSDefaultToViewFields()
    }
    
    /// Reads values from NSUserDefaults and applies them into fields of UI.
    func setSettingsValuesFromNSDefaultToViewFields() {
        self.dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let disciplineReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String)!
        let countryreadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("country") as? String)!

        self.firstname.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as? String
        setInputFieldTextStyle(self.firstname, placeholderText: "Name")
        self.lastname.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as? String
        setInputFieldTextStyle(self.lastname, placeholderText: "Lastname")
        self.about.text = NSUserDefaults.standardUserDefaults().objectForKey("about") as? String
        setTextViewTextStyle(self.about, placeholderText: ABOUT_PLACEHOLDER_TEXT )
        self.mainDiscipline.text = NSLocalizedString(disciplineReadable, comment:"translation of discipline")
        setInputFieldTextStyle(self.mainDiscipline, placeholderText: "Your Discipline")
        self.isMale.text = NSUserDefaults.standardUserDefaults().boolForKey("isMale") ? "male" : "female"
        setInputFieldTextStyle(self.isMale, placeholderText: "Gender")
        self.birthday.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        setInputFieldTextStyle(self.birthday, placeholderText: "Birthday")
        self.country.text = NSLocalizedString(countryreadable, comment:"translation of country")
        setInputFieldTextStyle(self.country, placeholderText: "Country")
        self.email.text = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        
        //emailIndication
        let isValidEmail: Bool = NSUserDefaults.standardUserDefaults().boolForKey("isValid")
        if isValidEmail {
            setIconWithColor(self.emailStatusIndication, iconName: "ic_check", color: CLR_NOTIFICATION_GREEN)
        } else {
            setIconWithColor(self.emailStatusIndication, iconName: "ic_error_outline", color: CLR_NOTIFICATION_ORANGE)
        }
    }

    /// Fetch local user's settings in order to check if email address is validated. Updates indication icon accordingly and push the proper ui-view for user-email-indication
    func showEmailIndicationView() {
        let userEmailVC = self.storyboard!.instantiateViewControllerWithIdentifier("UserEmailNavigationController")
        self.emailStatusIsUpdating(true)
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        getLocalUserSettings(userId)
            .then { promise -> Void in
                
                self.emailStatusIsUpdating(false)
                if promise == .Success {
                    self.presentViewController(userEmailVC, animated: true, completion: nil)
                } else if promise == .Unauthorised {
                    // SHOULD NEVER HAPPEN.
                    // LOGOUT USER
                    Utils.clearLocalUserData()
                    let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
                    self.presentViewController(loginVC, animated: true, completion: nil)
                }
        }
    }
    
    /**
     Defines the ui of texts in fields regarding the values that passed. Handles empty and filled state.
     
     - Parameter label: label text
     - Parameter placeholderText: placeholder text

     */
    // FIXME: checkout how this and next function are used.
    func setInputFieldTextStyle(label: UILabel, placeholderText: String) {
        if label.text == "" {
            label.text = placeholderText
            label.font = IF_PLACEHOLDER_FONT
            label.textColor = CLR_MEDIUM_GRAY
        } else {
            label.font = IF_STANDARD_FONT
            label.textColor = CLR_DARK_GRAY
        }
    }
    
    /**
     Defines the ui of text views regarding the values that passed. Handles empty and filled state.
     
     - Parameter textView: label text
     - Parameter placeholderText: placeholder text
     
     */
    func setTextViewTextStyle(textView: UITextView, placeholderText: String) {
        if textView.text == "" {
            textView.text = placeholderText
            textView.font = IF_PLACEHOLDER_FONT
            textView.textColor = CLR_MEDIUM_GRAY
        } else {
            textView.font = IF_STANDARD_FONT
            textView.textColor = CLR_DARK_GRAY
        }
    }
    
    /**
     Hides email status icon and show spinner

     - Parameter isLoading: boolean that indicates if localUserSettings are loaded
     */
    func emailStatusIsUpdating(isUpdating: Bool) {
        self.emailStatusRefreshSpinner.hidden = !isUpdating
        self.emailStatusIndication.hidden = isUpdating
    }

}
