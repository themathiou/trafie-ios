//
//  UserEmailVC.swift
//  trafie
//
//  Created by mathiou on 07/02/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SwiftyJSON

class UserEmailVC : UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet var emailTableView: UITableView!
    let userEmail = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
    var isValidEmail: Bool = false //init value only
    
    override func viewDidLoad() {
        self.emailTableView.delegate = self
        self.emailTableView.dataSource = self
        self.emailTableView.emptyDataSetDelegate = self
        self.emailTableView.emptyDataSetSource = self
        self.emailTableView.tableFooterView = UIView() // A little trick for removing the cell separators
        
        isValidEmail = NSUserDefaults.standardUserDefaults().boolForKey("isValid")
    }
    
    // MARK:- Empty State handling
    /// Defines the text and the appearance for empty state title.
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isValidEmail ? "Great!" : "\(self.userEmail!) \n has not been confirmed yet!\n "
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(20),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    /// Defines the image for empty state
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let emptyStateImage: UIImage = (isValidEmail ? UIImage(named: "email_confirmed") : UIImage(named: "email_pending"))!
        return emptyStateImage
    }
    
    ///Defines the text and appearance of empty state's button
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(15.0),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        return isValidEmail ? nil : NSAttributedString(string: "Resend Email", attributes:attributes)
    }
    
    /// Background color for empty state
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(rgba: "#ffffff")
    }
    
    /// Handles the action for empty states button
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        ApiHandler.resendEmailVerificationCodeRequest()
            .responseJSON { request, response, result in
                switch result {
                case .Success(_):
                    if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                        SweetAlert().showAlert("Email Send", subTitle: "Check the email we have send you and follow the link!", style: AlertStyle.Success)
                    } else if statusCode404.evaluateWithObject(String((response?.statusCode)!)) {
                        // SHOULD NEVER HAPPEN.
                        // LOGOUT USER
                        Utils.resetValuesOfProfile()
                        sectionsOfActivities.removeAll()
                        sortedSections.removeAll()
                        activitiesIdTable.removeAll()
                        lastFetchingActivitiesDate = ""
                        let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
                        self.presentViewController(loginVC, animated: true, completion: nil)
                    } else if statusCode422.evaluateWithObject(String((response?.statusCode)!)) {
                         SweetAlert().showAlert("Already Confirmed!", subTitle: "We have already confirm this email.", style: AlertStyle.Warning)
                    } else {
                        SweetAlert().showAlert("Something went wrong!", subTitle: "We couldn't send you this email. Please try again.", style: AlertStyle.Error)
                    }
                case .Failure(let data, let error):
                    Utils.log("Request for resend email failed with error: \(error)")
                    SweetAlert().showAlert("Something went wrong!", subTitle: "We couldn't send you this email. Please try again.", style: AlertStyle.Error)

                    if let data = data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    /// Defines the text and the appearance for the description text in empty state
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isValidEmail ? "Your email \(self.userEmail!) has been confirmed." : "Check the email you have send you and follow the link. \n\n IF you cannot find it, tap below and we will resend it to you."
        
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = NSLineBreakMode.ByWordWrapping
        para.alignment = NSTextAlignment.Center
        
        let attribs = [
            NSFontAttributeName: UIFont.systemFontOfSize(16),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: para
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    /// Dismiss the view
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
