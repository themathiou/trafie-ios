//
//  TRFProfileEditViewController.swift
//  trafie
//
//  Created by mathiou on 28/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class TRFProfileEditViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {

    // MARK: Constants
    let emptyState = ["Nothing to select"]
    let PLACEHOLDER_TEXT = "About you (up to 200 characters)"
    let MAX_NUMBER_OF_NOTES_CHARS = 200
    
    // MARK: Header Elements
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Profile Form Elements
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var about: UITextView!
    @IBOutlet weak var aboutCharsCounter: UILabel!
    @IBOutlet weak var mainDiscipline: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
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
        applyPlaceholderStyle(about!, placeholderText: PLACEHOLDER_TEXT)
        
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
        
    }
    
    // MARK:- Fields' functions
    
    // MARK: firstname
    @IBAction func fnameFieldFocused(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }
    
    // MARK: lastname
    @IBAction func lnameFieldFocused(sender: UITextField) {
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton
    }
    
    // MARK: about
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = CLR_MEDIUM_GRAY
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
        
        if aTextView == about && aTextView.text == PLACEHOLDER_TEXT
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
            if textView == about && textView.text == PLACEHOLDER_TEXT
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
                    about.layer.borderWidth = 0
                } else {
                    aboutCharsCounter.textColor = CLR_NOTIFICATION_RED
                    about.layer.borderColor = CLR_NOTIFICATION_RED.CGColor
                    about.layer.borderWidth = 1
                }
            } else {
                about.layer.borderWidth = 0
                aboutCharsCounter.textColor = CLR_DARK_GRAY
            }
            
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(textView)
            
            aboutCharsCounter.text = String(MAX_NUMBER_OF_NOTES_CHARS)
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
            self.firstName.resignFirstResponder()
        case 2: // Last Name Keyboard
            self.lastName.resignFirstResponder()
        case 3: // About Keyboard
            self.about.resignFirstResponder()
        case 4: // Main discipline picker view
            self.mainDiscipline.text = NSLocalizedString(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for main discipline")
            self.mainDiscipline.resignFirstResponder()
        case 5: // Birthday picker view
            self.dateformatter.dateFormat = "yyyy/MM/dd"
            self.birthday.text = self.dateformatter.stringFromDate(self.datePickerView.date)
            self.birthday.resignFirstResponder()
        case 6: //county picker view
            self.country.text = NSLocalizedString(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for countries")
            self.country.resignFirstResponder()
        default:
            print("doneButton default", terminator: "");
        }
    }

    
    
    // MARK:- General Functions
    
    @IBAction func saveProfile(sender: AnyObject) {
        let genderReadable = self.gender.selectedSegmentIndex == 0 ? "male" : "female" // 0: male, 1: female
        self.dateformatter.dateFormat = "yyyy/MM/dd"
        let date = self.dateformatter.stringFromDate(datePickerView.date).componentsSeparatedByString("/")
        let year: String = date[0]
        let month: String = String(Int(date[1])! - 1) //for some reason months start from '2'
        let day: String = date[2]
        
        let setting : [String : AnyObject]? = ["firstName": firstName.text!,
            "lastName": lastName.text!, "about": about.text!,
            "discipline": disciplinesAll[disciplinesPickerView.selectedRowInComponent(0)],
            "gender": genderReadable,
            "birthday": ["day": day, "month": month, "year": year],
            "country": countriesShort[countriesPickerView.selectedRowInComponent(0)]]

        TRFApiHandler.updateLocalUserSettings(setting!)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let data):
                    print("--- Success -> updateLocalUserSettings---", terminator: "")
                    print("----- \(data)")
                    let json = JSON(data)
                    if json["error"].string! != "" {
                        print("Response data: \(data)")
//                        self.textFieldHasError(self.firstName, hasError: true, existedValue: existedValue)
                    } else {
                        print("-------------------- SAVED ------------ \(data)")
                        print("-----------------------------------------------")
                        let gender = self.gender.selectedSegmentIndex == 0 ? "male" : "female" // 0: male, 1: female
                        NSUserDefaults.standardUserDefaults().setObject(self.firstName.text, forKey: "firstname")
                        NSUserDefaults.standardUserDefaults().setObject(self.lastName.text, forKey: "lastname")
                        NSUserDefaults.standardUserDefaults().setObject(self.about.text, forKey: "about")
                        NSUserDefaults.standardUserDefaults().setObject(gender, forKey: "gender")
                        NSUserDefaults.standardUserDefaults().setObject(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], forKey: "mainDiscipline")
                        NSUserDefaults.standardUserDefaults().setObject(self.dateformatter.stringFromDate(self.datePickerView.date), forKey: "birthday")
                        NSUserDefaults.standardUserDefaults().setObject(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], forKey: "country")

                        NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                        self.dismissViewControllerAnimated(true, completion: {})
                    }
                case .Failure(let data, let error):
                    print("Request failed with error: \(error)")
                    if let data = data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
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
        self.about.text = NSUserDefaults.standardUserDefaults().objectForKey("about") as! String
        let disciplineReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String)!
        self.mainDiscipline.text = NSLocalizedString(disciplineReadable, comment:"translation of discipline")
        self.gender.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().objectForKey("gender") as! String == "male" ?  0 : 1
        self.birthday.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        let countryReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("country") as? String)!
        self.country.text = NSLocalizedString(countryReadable, comment:"translation of country")
    }
    
    // update UI for a UITextField based on his error-state
    func textFieldHasError(textField: UITextField, hasError: Bool, existedValue: String?="") {
        if hasError == true {
            textField.layer.borderColor = CLR_NOTIFICATION_RED.CGColor
            textField.layer.borderWidth = 1
            textField.text = existedValue
        } else {
            textField.layer.borderColor = CLR_NOTIFICATION_GREEN.CGColor
            textField.layer.borderWidth = 1
        }
    }
    
    
}