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
    var isUserVerified: Bool = false //init value only
    
    override func viewDidLoad() {
        self.emailTableView.delegate = self
        self.emailTableView.dataSource = self
        self.emailTableView.emptyDataSetDelegate = self
        self.emailTableView.emptyDataSetSource = self
        self.emailTableView.tableFooterView = UIView() // A little trick for removing the cell separators
        
        isUserVerified = NSUserDefaults.standardUserDefaults().boolForKey("isVerified")
    }
    
    // MARK:- Empty State handling
    /// Defines the text and the appearance for empty state title.
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isUserVerified ? "Great!" : "\(self.userEmail!) \n has not been verified yet!\n "
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(20),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    /// Defines the image for empty state
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let emptyStateImage: UIImage = (isUserVerified ? UIImage(named: "email_confirmed") : UIImage(named: "email_pending"))!
        return emptyStateImage
    }
    
    ///Defines the text and appearance of empty state's button
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(16.0),
            NSForegroundColorAttributeName: UIColor.blueColor()
        ]
        return isUserVerified ? nil : NSAttributedString(string: "Resend Email", attributes:attributes)
    }
    
    /// Background color for empty state
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(rgba: "#ffffff")
    }
    
    /// Handles the action for empty states button
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        Utils.showNetworkActivityIndicatorVisible(true)
        ApiHandler.resendEmailVerificationCodeRequest()
            .responseJSON { request, response, result in
                Utils.showNetworkActivityIndicatorVisible(false)
                switch result {
                case .Success(_):
                    if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                        SweetAlert().showAlert("Email Send", subTitle: "Check the email we have sent you and follow the link!", style: AlertStyle.Success)
                    } else if statusCode404.evaluateWithObject(String((response?.statusCode)!)) {
                        // SHOULD NEVER HAPPEN.
                        // LOGOUT USER
                        Utils.clearLocalUserData()
                        let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
                        self.presentViewController(loginVC, animated: true, completion: nil)
                    } else if statusCode422.evaluateWithObject(String((response?.statusCode)!)) {
                         SweetAlert().showAlert("All good!", subTitle: "This email is already verified.", style: AlertStyle.Success)
                    } else {
                        SweetAlert().showAlert("Something went wrong!", subTitle: "Email could not be sent! Please try again.", style: AlertStyle.Error)
                    }
                case .Failure(let data, let error):
                    Utils.log("Request for resend email failed with error: \(error)")
                    SweetAlert().showAlert("Something went wrong!", subTitle: "Email could not be sent! Please try again.", style: AlertStyle.Error)

                    if let data = data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    
    /// Defines the text and the appearance for the description text in empty state
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isUserVerified ? "Your email \(self.userEmail!) has been verified." : "Check the email we have sent you and follow the link. \n Cannot find it? Tap below."
        
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
