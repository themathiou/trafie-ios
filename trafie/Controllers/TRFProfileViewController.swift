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

class TRFProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

//  variables
    let emptyState = ["Nothing to select"]
    let PLACEHOLDER_TEXT = "About you"
    let MAX_NUMBER_OF_NOTES_CHARS = 200
    
//  fields
    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    @IBOutlet weak var aboutFieldLetterCounter: UILabel!
    @IBOutlet weak var aboutField: UITextView!
    
    
    @IBOutlet weak var mainDisciplineField: UITextField!
    @IBOutlet weak var birthdayInputField: UITextField!
    @IBOutlet weak var countriesInputField: UITextField!
    @IBOutlet weak var privacyToggle: UISwitch!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    
    @IBOutlet var reportProblemButton: UIButton!
    
    
//  pickers
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var countriesPickerView:UIPickerView = UIPickerView()
    var doneButton: UIButton = UIButton (frame: CGRectMake(100, 100, 100, 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserSettings()

        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.countriesPickerView.dataSource = self;
        self.countriesPickerView.delegate = self;
        self.aboutField.delegate = self
        self.fnameField.delegate = self
        self.lnameField.delegate = self
        
        applyPlaceholderStyle(aboutField!, placeholderText: PLACEHOLDER_TEXT)

        //TO-DO the rest of user's settings
        self.fnameField.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as? String
        self.lnameField.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as? String
        self.aboutField.text = NSUserDefaults.standardUserDefaults().objectForKey("about") as! String
        self.mainDisciplineField.text = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String
        self.privacyToggle.setOn(NSUserDefaults.standardUserDefaults().objectForKey("isPrivate") as! Bool, animated: false)
        self.genderSegment.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().objectForKey("gender") as! String == "male" ?  1 : 2
        self.birthdayInputField.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        self.countriesInputField.text = NSUserDefaults.standardUserDefaults().objectForKey("country") as? String
        
        //donebutton
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
    }
    
//  Firstname
    @IBAction func fnameFieldEdit(sender: UITextField) {
        NSUserDefaults.standardUserDefaults().setObject(sender.text, forKey: "firstname")
        print(sender.text, terminator: "")
    }
    
//  Lastname
    @IBAction func lnameFieldEdit(sender: UITextField) {
        NSUserDefaults.standardUserDefaults().setObject(sender.text, forKey: "lastname")
        print(sender.text, terminator: "")
    }

//  Main Discipline
    @IBAction func mainDisciplineEditing(sender: UITextField) {
        sender.inputView = disciplinesPickerView
        if self.mainDisciplineField.text == "" {
            self.disciplinesPickerView.selectRow(5, inComponent: 0, animated: true)
        }
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }
    
//  Privacy
    @IBAction func privacyEditing(sender: UISwitch) {
        if sender.on {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isPrivate")
            print("The gig is up", terminator: "")
        } else {
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isPrivate")
            print("Nope", terminator: "")
        }
        
    }

//  Gender
    @IBAction func genderSegmentEdit(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex, terminator: "")
    }

 
//  Birthday
    @IBAction func birthdayFieldEditing(sender: UITextField) {
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton

    }

    func datePickerValueChanged(sender: UIDatePicker) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        NSUserDefaults.standardUserDefaults().setObject(dateformatter.stringFromDate(sender.date), forKey: "birthday")
        birthdayInputField.text = dateformatter.stringFromDate(sender.date)
    }
    
//  Countries field

    @IBAction func countriesFieldEditing(sender: UITextField) {
        sender.inputView = countriesPickerView
    }
    
    //about field
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
    }
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == aboutField && aTextView.text == PLACEHOLDER_TEXT
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = "textView.text".utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == aboutField && textView.text == PLACEHOLDER_TEXT
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            
            let textLength : Int = MAX_NUMBER_OF_NOTES_CHARS - aboutField.text.characters.count
            aboutFieldLetterCounter.text = String(textLength)
            
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView == self.aboutField) {
            NSUserDefaults.standardUserDefaults().setObject(self.aboutField.text, forKey: "about")
        }
    }
    
    
    //email
    @IBAction func showActionSheet(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .Alert)
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        
        let reportProblem = UIAlertAction(title: "Report a problem", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            picker.setSubject("Report a problem")
            picker.setMessageBody("The problem I found in trafie is:", isHTML: true)
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let requestFeature = UIAlertAction(title: "Request New Feature", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            picker.setSubject("Request a feature")
            picker.setMessageBody("What I would love to see in trafie is: ", isHTML: true)
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
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    //--  General functions
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case disciplinesPickerView:
            return disciplinesAll.count;
        case countriesPickerView:
            return countries.count;
        default:
            return 1;
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case disciplinesPickerView:
            return NSLocalizedString(disciplinesAll[row], comment:"translation of discipline \(row)")
        case countriesPickerView:
            return countries[row]
        default:
            return emptyState[0];
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case disciplinesPickerView:
            mainDisciplineField.text = NSLocalizedString(disciplinesAll[row], comment:"text shown in text field for \(row)")
            NSUserDefaults.standardUserDefaults().setObject(disciplinesAll[row], forKey: "mainDiscipline")
        case countriesPickerView:
            countriesInputField.text = countries[row]
            NSUserDefaults.standardUserDefaults().setObject(countries[row], forKey: "country")
        default:
            print("Did select row of uknown picker? wtf?", terminator: "")
        }
    }
    
    // TODO: Handle all uipickerviews
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1: // Main discipline picker view
            mainDisciplineField.resignFirstResponder()
            print("Main discipline pickerview", terminator: "");
        case 2: // MBirthday picker view
            birthdayInputField.resignFirstResponder()
            print("Birthday pickerview", terminator: "");
        default:
            print("doneButton default", terminator: "");
        }
    }
    
    func getUserSettings() {
        TRFApiHandler.getUserById()
            .responseJSON { request, response, result in
                print("--- getUserById('me') ---")
                switch result {
                case .Success(let JSONResponse):
                    print(request, terminator: "")
                    print(response, terminator: "")
                    print(result, terminator: "")
                    print(JSONResponse, terminator: "")
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }
    // end general

}
