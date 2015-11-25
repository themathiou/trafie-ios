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
import SwiftyJSON

class TRFProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

//  variables
    let emptyState = ["Nothing to select"]
    let PLACEHOLDER_TEXT = "About you (up to 200 characters)"
    let MAX_NUMBER_OF_NOTES_CHARS = 200
    
//  fields
    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    @IBOutlet weak var aboutFieldLetterCounter: UILabel!
    @IBOutlet weak var aboutField: UITextView!
    
    
    @IBOutlet weak var mainDisciplineField: UITextField!
    @IBOutlet weak var birthdayInputField: UITextField!
    @IBOutlet weak var countriesInputField: UITextField!
//    @IBOutlet weak var privacyToggle: UISwitch!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    
    @IBOutlet var reportProblemButton: UIButton!
    
    
//  pickers
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var countriesPickerView:UIPickerView = UIPickerView()
    var doneButton: UIButton = UIButton (frame: CGRectMake(100, 100, 100, 50))
    
    let dateformatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.countriesPickerView.dataSource = self;
        self.countriesPickerView.delegate = self;
        self.aboutField.delegate = self
        self.fnameField.delegate = self
        self.lnameField.delegate = self

        applyPlaceholderStyle(aboutField!, placeholderText: PLACEHOLDER_TEXT)
        
        setSettingsValuesFromNSDefaultToViewFields()
        
        //about text counter
        let initialAboutTextCharLength : Int = MAX_NUMBER_OF_NOTES_CHARS - aboutField.text.characters.count
        aboutFieldLetterCounter.text = String(initialAboutTextCharLength)
        
        //datePickerView
        datePickerView.datePickerMode = UIDatePickerMode.Date
        // limit birthday to 10 years back
        datePickerView.maximumDate = NSDate().dateByAddingTimeInterval(-315360000)
        
        //donebutton
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
    }
    
//  Firstname
    @IBAction func fnameFieldFocused(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }
    @IBAction func fnameFieldEdit(sender: UITextField) {
        let setting : [String : AnyObject]? = ["firstName": sender.text!]

        TRFApiHandler.updateLocalUserSettings(setting!)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let data):
                    print("--- Success -> updateLocalUserSettings---", terminator: "")
                    let json = JSON(data)
                    if json["error"].string! != "" {
                        print("Response data: \(data)")
                    } else {
                        NSUserDefaults.standardUserDefaults().setObject(sender.text, forKey: "firstname")
                    }
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
        print(sender.text, terminator: "")
    }
    
//  Lastname
    @IBAction func lnameFieldFocused(sender: UITextField) {
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton
    }
    @IBAction func lnameFieldEdit(sender: UITextField) {
        let setting : [String : AnyObject]? = ["lastName": sender.text!]
        TRFApiHandler.updateLocalUserSettings(setting!)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let data):
                    print("--- Success -> updateLocalUserSettings---", terminator: "")
                    let json = JSON(data)
                    if json["error"].string! != "" {
                        print("Response data: \(data)")
                    } else {
                        NSUserDefaults.standardUserDefaults().setObject(sender.text, forKey: "lastname")
                    }
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
        print(sender.text, terminator: "")
    }

//  Main Discipline
    @IBAction func mainDisciplineEditing(sender: UITextField) {
        sender.inputView = disciplinesPickerView
        if self.mainDisciplineField.text == "" {
            self.disciplinesPickerView.selectRow(5, inComponent: 0, animated: true)
        }
        doneButton.tag = 4
        sender.inputAccessoryView = doneButton
    }
    
    //Privacy
    //@IBAction func privacyEditing(sender: UISwitch) {
    //    if sender.on {
    //        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isPrivate")
    //        print("The gig is up", terminator: "")
    //    } else {
    //        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isPrivate")
    //        print("Nope", terminator: "")
    //    }
    //    
    //}

//  Gender
    @IBAction func genderSegmentEdit(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex, terminator: "")
        
        let gender = sender.selectedSegmentIndex == 0 ? "male" : "female" // 0: male, 1: female
        let setting : [String : AnyObject]? = ["gender": gender ]
        
        TRFApiHandler.updateLocalUserSettings(setting!)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let data):
                    print("--- Success -> updateLocalUserSettings---", terminator: "")
                    let json = JSON(data)
                    if json["error"].string! != "" {
                        print("Response data: \(data)")
                    } else {
                        NSUserDefaults.standardUserDefaults().setObject(gender, forKey: "gender")
                    }
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }

    }

 
//  Birthday
    @IBAction func birthdayFieldEditing(sender: UITextField) {
        sender.inputView = datePickerView
        doneButton.tag = 5
        sender.inputAccessoryView = doneButton
    }
    
//  Countries field

    @IBAction func countriesFieldEditing(sender: UITextField) {
        sender.inputView = countriesPickerView
        doneButton.tag = 6
        sender.inputAccessoryView = doneButton
    }
    
// About field
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
        doneButton.tag = 3
        aTextView.inputAccessoryView = doneButton
        
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
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
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
            
            let remainingTextLength : Int = MAX_NUMBER_OF_NOTES_CHARS - aboutField.text.characters.count
            aboutFieldLetterCounter.text = String(remainingTextLength)
            if remainingTextLength < 10 {
                if remainingTextLength >= 0 {
                    aboutFieldLetterCounter.textColor = UIColor.orangeColor()
                    aboutField.layer.borderWidth = 0
                } else {
                    aboutFieldLetterCounter.textColor = UIColor.redColor()
                    aboutField.layer.borderColor = UIColor.redColor().CGColor
                    aboutField.layer.borderWidth = 1
                }
            } else {
                aboutField.layer.borderWidth = 0
                aboutFieldLetterCounter.textColor = UIColor.grayColor()
            }
            
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(textView)

            aboutFieldLetterCounter.text = String(MAX_NUMBER_OF_NOTES_CHARS)
            return false
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView == self.aboutField) {
            if self.aboutField.text.characters.count <= MAX_NUMBER_OF_NOTES_CHARS {
                let setting : [String : AnyObject]? = ["about": textView.text!]
                TRFApiHandler.updateLocalUserSettings(setting!)
                    .responseJSON { request, response, result in
                        switch result {
                        case .Success(let data):
                            print("--- Success -> updateLocalUserSettings---", terminator: "")
                            let json = JSON(data)
                            if json["error"].string! != "" {
                                print("Response data: \(data)")
                            } else {
                                NSUserDefaults.standardUserDefaults().setObject(textView.text, forKey: "about")
                            }
                        case .Failure(let data, let error):
                            print("Request failed with error: \(error)")
                            if let data = data {
                                print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                }
                print(textView.text, terminator: "")
            }
        }
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
            return countriesShort.count;
        default:
            return 1;
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case disciplinesPickerView:
            return NSLocalizedString(disciplinesAll[row], comment:"translation of discipline \(row)")
        case countriesPickerView:
            return NSLocalizedString(countriesShort[row], comment:"translation of discipline \(row)")
        default:
            return emptyState[0];
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case disciplinesPickerView:
            print("didSelectRow \(disciplinesAll[row])");
        case countriesPickerView:
            print("didSelectRow \(countriesShort[row])");
        default:
            print("Did select row of uknown picker? wtf?", terminator: "")
        }
    }
    
    // TODO: Handle all uipickerviews
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1: // First Name Keyboard
            self.fnameField.resignFirstResponder()
        case 2: // Last Name Keyboard
            self.lnameField.resignFirstResponder()
        case 3: // About Keyboard
            self.aboutField.resignFirstResponder()
        case 4: // Main discipline picker view
            let setting : [String : AnyObject]? = ["discipline": disciplinesAll[disciplinesPickerView.selectedRowInComponent(0)]]
            TRFApiHandler.updateLocalUserSettings(setting!)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let data):
                        print("--- Success -- updateLocalUserSettings---", terminator: "")
                        let json = JSON(data)
                        if json["error"].string! != "" {
                            print("Response data: \(data)")
                        } else {
                            self.mainDisciplineField.text = NSLocalizedString(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for main discipline")
                            NSUserDefaults.standardUserDefaults().setObject(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], forKey: "mainDiscipline")
                            self.mainDisciplineField.resignFirstResponder()
                        }
                        
                    case .Failure(let data, let error):
                        print("Request failed with error: \(error)")
                        if let data = data {
                            print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
            print("Main discipline pickerview \(countriesPickerView.selectedRowInComponent(0))", terminator: "");
        case 5: // Birthday picker view
            print(datePickerView.date)
            self.dateformatter.dateFormat = "yyyy/MM/dd"
            let date = self.dateformatter.stringFromDate(datePickerView.date).componentsSeparatedByString("/")
            let year: String = date[0]
            let month: String = String(Int(date[1])! - 1) //for some reason months start from '2'
            let day: String = date[2]
            let setting : [String : AnyObject]? = ["birthday": ["day": day, "month": month, "year": year]]
            TRFApiHandler.updateLocalUserSettings(setting!)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let data):
                        print("--- Success -> updateLocalUserSettings---", terminator: "")
                        let json = JSON(data)
                        if json["error"].string! != "" {
                            print("Response data: \(data)")
                        } else {
                            NSUserDefaults.standardUserDefaults().setObject(self.dateformatter.stringFromDate(self.datePickerView.date), forKey: "birthday")
                            self.birthdayInputField.text = self.dateformatter.stringFromDate(self.datePickerView.date)
                            self.birthdayInputField.resignFirstResponder()
                        }
                    case .Failure(let data, let error):
                        print("Request failed with error: \(error)")
                        if let data = data {
                            print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
        case 6: //county picker view
            let setting : [String : AnyObject]? = ["country": countriesShort[countriesPickerView.selectedRowInComponent(0)]]
            TRFApiHandler.updateLocalUserSettings(setting!)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let data):
                        print("--- Success -> updateLocalUserSettings---", terminator: "")
                        let json = JSON(data)
                        if json["error"].string! != "" {
                            print("Response data: \(data)")
                        } else {
                            self.countriesInputField.text = NSLocalizedString(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for countries")
                            NSUserDefaults.standardUserDefaults().setObject(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], forKey: "country")
                            self.countriesInputField.resignFirstResponder()
                        }
                    case .Failure(let data, let error):
                        print("Request failed with error: \(error)")
                        if let data = data {
                            print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        }
                    }
            }
            print("Countries pickerview : \(countriesShort[countriesPickerView.selectedRowInComponent(0)])", terminator: "");
        default:
            print("doneButton default", terminator: "");
        }
    }
    
    //after all values have been set to NSDefault, display them in fields
    func setSettingsValuesFromNSDefaultToViewFields() {
        self.dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        self.fnameField.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as? String
        self.lnameField.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as? String
        self.aboutField.text = NSUserDefaults.standardUserDefaults().objectForKey("about") as! String
        let discipline: String = (NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String)!
        self.mainDisciplineField.text = NSLocalizedString(discipline, comment:"translation of discipline")
        self.genderSegment.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().objectForKey("gender") as! String == "male" ?  0 : 1
        self.birthdayInputField.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        self.countriesInputField.text = NSUserDefaults.standardUserDefaults().objectForKey("country") as? String
    }
    // end general

}
