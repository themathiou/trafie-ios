//
//  TRFProfileViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class TRFProfileViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var mainDiscipline: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var birthday: UILabel!
    @IBOutlet weak var country: UILabel!
    
    @IBOutlet var reportProblemButton: UIButton!
    

    let dateformatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setSettingsValuesFromNSDefaultToViewFields()
    }
    
    
    //email
    @IBAction func showActionSheet(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .Alert)
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        
        let systemInfo: String = "Device: \(UIDevice.currentDevice().model) <br> Operating System: \(UIDevice.currentDevice().systemVersion)"
        
        let reportProblem = UIAlertAction(title: "Report a problem", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            picker.setSubject("Report a problem")
            picker.setMessageBody("The problem I found in trafie is: <br><br><br> \(systemInfo)", isHTML: true)
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let requestFeature = UIAlertAction(title: "Request New Feature", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            picker.setSubject("Request a feature")
            picker.setMessageBody("What I would love to see in trafie is:", isHTML: true)
            self.presentViewController(picker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled", terminator: "")
        })
        
        optionMenu.addAction(reportProblem)
        optionMenu.addAction(requestFeature)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //logout
    @IBAction func logout(sender: AnyObject) {
        //Create the AlertController
        let logoutAlertController: UIAlertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled", terminator: "")
        })

        //Create and an option action
        let confirmAction: UIAlertAction = UIAlertAction(title: "Logout", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            resetValuesOfProfile();
            let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
            self.presentViewController(loginVC, animated: true, completion: nil)
        })

        logoutAlertController.addAction(cancelAction)
        logoutAlertController.addAction(confirmAction)
        
        self.presentViewController(logoutAlertController, animated: true, completion: nil)
        
    }
    
    // called when 'return' key pressed. return NO to ignore.
    
    //after all values have been set to NSDefault, display them in fields
    func setSettingsValuesFromNSDefaultToViewFields() {
        self.dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        self.firstname.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as? String
        self.lastname.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as? String
        self.about.text = NSUserDefaults.standardUserDefaults().objectForKey("about") as? String
        let disciplineReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String)!
        self.mainDiscipline.text = NSLocalizedString(disciplineReadable, comment:"translation of discipline")
        self.gender.text = NSUserDefaults.standardUserDefaults().objectForKey("gender") as? String
        self.birthday.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        let countryreadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("country") as? String)!
        self.country.text = NSLocalizedString(countryreadable, comment:"translation of country")
    }
    // end general
    

}
