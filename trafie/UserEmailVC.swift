//
//  UserEmailVC.swift
//  trafie
//
//  Created by mathiou on 07/02/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class UserEmailVC : UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet var emailTableView: UITableView!
    let userEmail = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
    let isValidEmail: Bool = NSUserDefaults.standardUserDefaults().boolForKey("isValid")
    
    override func viewDidLoad() {

        self.emailTableView.delegate = self
        self.emailTableView.dataSource = self
        self.emailTableView.emptyDataSetDelegate = self
        self.emailTableView.emptyDataSetSource = self
        self.emailTableView.tableFooterView = UIView() // A little trick for removing the cell separators
    }
    
    // MARK:- Empty State handling
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isValidEmail ? "Great!" : "\(self.userEmail!) \n has not been confirmed yet!\n "
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(20),
            NSForegroundColorAttributeName: CLR_MEDIUM_GRAY
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
//    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "filename")
//    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(19.0),
            NSForegroundColorAttributeName: CLR_DARK_GRAY
        ]
        
        return isValidEmail ? nil : NSAttributedString(string: "Resend Email", attributes:attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(rgba: "#ffffff")
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        //TODO: call API to send again the verification email
        SweetAlert().showAlert("Email Send", subTitle: "Check the email we have send you and follow the link!", style: AlertStyle.Success)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = isValidEmail ? "Your email \(self.userEmail!) has been confirmed." : "Check the email you have send you, when you registered and follow the link. \n\n IF you cannot find it, tap below and we will resend it to you."
        
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = NSLineBreakMode.ByWordWrapping
        para.alignment = NSTextAlignment.Center
        
        let attribs = [
            NSFontAttributeName: UIFont.systemFontOfSize(14),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: para
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
