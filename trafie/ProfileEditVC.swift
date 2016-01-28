//
//  ProfileEditViewController.swift
//  trafie
//
//  Created by mathiou on 28/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class ProfileEditVC: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {

    // MARK: Constants
    let emptyState = ["Nothing to select"]
    let MAX_NUMBER_OF_NOTES_CHARS = 200
    
    var _isFormDirty: Bool = false
    var _firstNameError: Bool = false
    var _lastNameError: Bool = false
    var _aboutError: Bool = false

    // MARK: Header Elements
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Profile Form Elements
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var aboutCharsCounter: UILabel!
    @IBOutlet weak var mainDiscipline: UITextField!
    @IBOutlet weak var isMale: UISegmentedControl!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var country: UITextField!
    
    // MARK: Pickers
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var countriesPickerView:UIPickerView = UIPickerView()
    var doneButton: UIButton = keyboardButtonCentered
    
    let dateformatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.countriesPickerView.dataSource = self;
        self.countriesPickerView.delegate = self;
        self.about.delegate = self
        self.firstName.delegate = self
        self.lastName.delegate = self
        
        // initialize error flags
        _isFormDirty = false
        _firstNameError = false
        _lastNameError = false
        _aboutError = false
        toggleSaveButton()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        
        initConnectionMsgInNavigationPrompt(self.navigationItem)

        //about text counter
        let initialAboutTextCharLength : Int = MAX_NUMBER_OF_NOTES_CHARS - about.text.characters.count
        aboutCharsCounter.text = String(initialAboutTextCharLength)
        
        //datePickerView
        datePickerView.datePickerMode = UIDatePickerMode.Date
        // limit birthday to 10 years back
        datePickerView.maximumDate = NSDate().dateByAddingTimeInterval(-315360000)
        
        //donebutton
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
        
        setSettingsValuesFromNSDefaultToViewFields()
        applyPlaceholderStyle(about!, placeholderText: ABOUT_PLACEHOLDER_TEXT)
        
    }
    
    // MARK:- Network Connection
    func networkStatusChanged(notification: NSNotification) {
        log("networkStatusChanged to \(notification.userInfo)")
        //let status = Reach().connectionStatus()
        initConnectionMsgInNavigationPrompt(self.navigationItem)
    }
    
    // MARK:- Fields' functions
    // MARK: firstname
    @IBAction func fnameFieldFocused(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }

    @IBAction func firsnameValueChanged(sender: AnyObject) {
        _firstNameError = isTextFieldValid(self.firstName, isFormDirty: true, regex: REGEX_AZ_2TO20_CHARS)
        toggleSaveButton()
    }

    // MARK: lastname
    @IBAction func lnameFieldFocused(sender: UITextField) {
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton
    }
    
    @IBAction func lastnameValueChanged(sender: AnyObject) {
        _lastNameError = isTextFieldValid(self.lastName, isFormDirty: true, regex: REGEX_AZ_2TO20_CHARS)
        toggleSaveButton()
    }

    // MARK: about
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        if aTextview.text.characters.count == 0 {
            aTextview.text = placeholderText
            aTextview.textColor = CLR_MEDIUM_GRAY
            aTextview.font = IF_PLACEHOLDER_FONT
        }
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = CLR_DARK_GRAY
        aTextview.font = IF_STANDARD_FONT
    }
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        doneButton.tag = 3
        aTextView.inputAccessoryView = doneButton
        
        if aTextView == about && aTextView.text == ABOUT_PLACEHOLDER_TEXT
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
            if textView == about && textView.text == ABOUT_PLACEHOLDER_TEXT
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            
            let remainingTextLength : Int = MAX_NUMBER_OF_NOTES_CHARS - about.text.characters.count
            aboutCharsCounter.text = String(remainingTextLength)
            if remainingTextLength < 10 {
                if remainingTextLength >= 0 {
                    aboutCharsCounter.textColor = CLR_NOTIFICATION_ORANGE
                    about.textColor = CLR_DARK_GRAY
                    _aboutError = false
                } else {
                    aboutCharsCounter.textColor = CLR_NOTIFICATION_RED
                    about.textColor = CLR_NOTIFICATION_RED
                    _aboutError = true
                }
            } else {
                about.layer.borderWidth = 0
                aboutCharsCounter.textColor = CLR_DARK_GRAY
                _aboutError = false
            }
            
            toggleSaveButton()
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: ABOUT_PLACEHOLDER_TEXT)
            moveCursorToStart(textView)
            
            aboutCharsCounter.text = String(MAX_NUMBER_OF_NOTES_CHARS)
            
            toggleSaveButton()
            return false
        }
    }
    
    // MARK: main discipline
    @IBAction func mainDisciplineEditing(sender: UITextField) {
        sender.inputView = disciplinesPickerView
        doneButton.tag = 4
        sender.inputAccessoryView = doneButton
        
        let userPreselectedDiscipline : String = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as! String
        if self.mainDiscipline.text == "" {
            self.disciplinesPickerView.selectRow(5, inComponent: 0, animated: true)
        } else {
            for var i = 0; i < disciplinesAll.count ; i++ {
                if userPreselectedDiscipline == disciplinesAll[i] {
                    self.disciplinesPickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
        }
    }
    
    // MARK: gender

    // MARK: birthday
    @IBAction func birthdayFieldEditing(sender: UITextField) {
        sender.inputView = datePickerView
        doneButton.tag = 5
        sender.inputAccessoryView = doneButton
    }
    
    // MARK: countries
    @IBAction func countriesFieldEditing(sender: UITextField) {
        sender.inputView = countriesPickerView
        doneButton.tag = 6
        sender.inputAccessoryView = doneButton
        
        let userPreselectedCountry : String = NSUserDefaults.standardUserDefaults().objectForKey("country") as! String
        if self.country.text == "" {
            self.countriesPickerView.selectRow(5, inComponent: 0, animated: true)
        } else {
            for var i = 0; i < countriesShort.count ; i++ {
                if userPreselectedCountry == countriesShort[i] {
                    self.countriesPickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
        }
    }

    // MARK:- Pickers' functions
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
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
            log(disciplinesAll[row]);
        case countriesPickerView:
            log(countriesShort[row]);
        default:
            log("Did select row of uknown picker? wtf?")
        }
        
        toggleSaveButton()
    }
    
    // TODO: Handle all uipickerviews
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1: // First Name Keyboard
            self.firstName.resignFirstResponder()
        case 2: // Last Name Keyboard
            self.lastName.resignFirstResponder()
        case 3: // About Keyboard
            self.about.resignFirstResponder()
        case 4: // Main discipline picker view
            self.mainDiscipline.text = NSLocalizedString(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for main discipline")
            self.mainDiscipline.resignFirstResponder()
        case 5: // Birthday picker view
            self.dateformatter.dateFormat = "dd-MM-YYYY"
            self.birthday.text = self.dateformatter.stringFromDate(self.datePickerView.date)
            self.birthday.resignFirstResponder()
        case 6: //county picker view
            self.country.text = NSLocalizedString(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for countries")
            self.country.resignFirstResponder()
        default:
            log("doneButton default");
        }
    }

    
    
    // MARK:- General Functions
    @IBAction func saveProfile(sender: AnyObject) {
        let isMale = self.isMale.selectedSegmentIndex == 0 ? true : false //male = true
        // TODO: fix date format to be compliant with YYYY-MM-dd
        self.dateformatter.dateFormat = "YYYY-MM-dd"
        
        let _about: String = about.text != ABOUT_PLACEHOLDER_TEXT ? about.text! : ""
        let userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        let settings : [String : AnyObject]? = ["firstName": firstName.text!,
            "lastName": lastName.text!,
            "about": _about,
            "discipline": disciplinesAll[disciplinesPickerView.selectedRowInComponent(0)],
            "isMale": isMale,
            "birthday": self.dateformatter.stringFromDate(datePickerView.date),
            "country": countriesShort[countriesPickerView.selectedRowInComponent(0)]]
        log(String(settings))

        ApiHandler.updateLocalUserSettings(userId, settingsObject: settings!)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                        let isMale = self.isMale.selectedSegmentIndex == 0 ? true : false
                        NSUserDefaults.standardUserDefaults().setObject(self.firstName.text, forKey: "firstname")
                        NSUserDefaults.standardUserDefaults().setObject(self.lastName.text, forKey: "lastname")
                        NSUserDefaults.standardUserDefaults().setObject(self.about.text, forKey: "about")
                        NSUserDefaults.standardUserDefaults().setObject(isMale, forKey: "isMale")
                        NSUserDefaults.standardUserDefaults().setObject(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], forKey: "mainDiscipline")
                        NSUserDefaults.standardUserDefaults().setObject(self.dateformatter.stringFromDate(self.datePickerView.date), forKey: "birthday")
                        NSUserDefaults.standardUserDefaults().setObject(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], forKey: "country")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                        self.dismissViewControllerAnimated(true, completion: {})
                    } else {
                        // TODO: API UPDATE
                        switch json["messages"].string! {
                        case "SETTINGS.INVALID_FIRST_NAME":
                            log("Error Message: Invalid first name")
                        case "SETTINGS.INVALID_LAST_NAME":
                            log("Error Message: Invalid last name")
                        case "SETTINGS.INVALID_BIRTHDAY":
                            log("Error Message: Invalid birthday")
                        case "SETTINGS.INVALID_GENDER":
                            log("Error Message: Invalid gender")
                        case "SETTINGS.INVALID_COUNTRY":
                            log("Error Message: Please Select a proper country")
                        case "SETTINGS.INVALID_LANGUAGE":
                            log("Error Message: Invalid language")
                        default:
                            log(json["messages"].string!)
                        }
                    }

                case .Failure(let data, let error):
                    log("Request failed with error: \(error)")
                    if let data = data {
                        log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                        let alert = UIAlertController(title: "Ooops!", message: "Something went wrong! Please try again later.", preferredStyle: .Alert) // 1
                        let firstAction = UIAlertAction(title: "Ok dude!", style: .Default) { (alert: UIAlertAction!) -> Void in
                            NSLog("You pressed button one")
                        } // 2
                        alert.addAction(firstAction) // 4
                        
                        self.presentViewController(alert, animated: true, completion:nil) // 6
                    }
                }
        }
        
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    //after all values have been set to NSDefault, display them in fields
    func setSettingsValuesFromNSDefaultToViewFields() {
        self.dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        self.firstName.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as? String
        self.lastName.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as? String
        let _about: String = NSUserDefaults.standardUserDefaults().objectForKey("about") as! String
        self.about.text = (_about != ABOUT_PLACEHOLDER_TEXT) ? _about : ""
        let _disciplineReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String)!
        self.mainDiscipline.text = NSLocalizedString(_disciplineReadable, comment:"translation of discipline")
        self.isMale.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().boolForKey("isMale") == true ?  0 : 1
        self.birthday.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        self.dateformatter.dateFormat = "yyyy-MM-dd"
        let _birthday: NSDate = self.dateformatter.dateFromString(self.birthday.text!)!
        datePickerView.setDate(_birthday, animated: true)
        let _countryReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("country") as? String)!
        self.country.text = NSLocalizedString(_countryReadable, comment:"translation of country")
    }
    
    // update UI for a UITextField based on his error-state
    func textFieldHasError(textField: UITextField, hasError: Bool, existedValue: String?="") {
        if hasError == true {
            textField.textColor = CLR_NOTIFICATION_RED
        } else {
            textField.textColor = CLR_DARK_GRAY
        }
    }

    // verify a specific text field based on a given regex
    func isTextFieldValid(field: UITextField, isFormDirty: Bool, regex: String) -> Bool {
            if field.text!.rangeOfString(regex, options: .RegularExpressionSearch) != nil {
                log("\(field.text) is OK")
                textFieldHasError(field, hasError: false)
                return false
            } else {
                log("\(field.text) is screwed")
                textFieldHasError(field, hasError: true)
                return true
            }
    }
    
    
    // toggles Save Button based on form errors
    func toggleSaveButton() {
        let isValid = isFormValid()
        let status = Reach().connectionStatus()
        
        if(isValid && status.description != ReachabilityStatus.Unknown.description && status.description != ReachabilityStatus.Offline.description ) {
            self.saveButton.enabled = true
            self.saveButton.tintColor = UIColor.blueColor()
        } else {
            self.saveButton.enabled = false
            self.saveButton.tintColor = CLR_MEDIUM_GRAY
        }
    }
    
    // returns true if required fields are completed
    func isFormValid() -> Bool {
        return !_isFormDirty && !_firstNameError && !_lastNameError && !_aboutError
    }
    
}



