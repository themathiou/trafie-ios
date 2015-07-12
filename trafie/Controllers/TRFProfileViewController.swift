//
//  TRFProfileViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation

class TRFProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

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
    
//  pickers
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var countriesPickerView:UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.countriesPickerView.dataSource = self;
        self.countriesPickerView.delegate = self;
        self.aboutField.delegate = self
        
        applyPlaceholderStyle(aboutField!, placeholderText: PLACEHOLDER_TEXT)

        //TO-DO the rest of user's settings
        self.fnameField.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as! String
        self.lnameField.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as! String
        self.aboutField.text = NSUserDefaults.standardUserDefaults().objectForKey("about") as! String
        self.mainDisciplineField.text = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as! String
        self.privacyToggle.setOn(NSUserDefaults.standardUserDefaults().objectForKey("isPrivate") as! Bool, animated: false)
        self.genderSegment.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().objectForKey("gender") as! String == "male" ?  1 : 2
        self.birthdayInputField.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as! String
        self.countriesInputField.text = NSUserDefaults.standardUserDefaults().objectForKey("country") as! String
    }
    
//  Firstname
    @IBAction func fnameFieldEdit(sender: UITextField) {
        NSUserDefaults.standardUserDefaults().setObject(sender.text, forKey: "firstname")
        println(sender.text)
    }
    
//  Lastname
    @IBAction func lnameFieldEdit(sender: UITextField) {
        NSUserDefaults.standardUserDefaults().setObject(sender.text, forKey: "lastname")
        println(sender.text)
    }

//  Main Discipline
    @IBAction func mainDisciplineEditing(sender: UITextField) {
        sender.inputView = disciplinesPickerView
    }
    
//  Privacy
    @IBAction func privacyEditing(sender: UISwitch) {
        if sender.on {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isPrivate")
            println("The gig is up")
        } else {
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isPrivate")
            println("Nope")
        }
        
    }

//  Gender
    @IBAction func genderSegmentEdit(sender: UISegmentedControl) {
        println(sender.selectedSegmentIndex)
    }

 
//  Birthday
    @IBAction func birthdayFieldEditing(sender: UITextField) {
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    func datePickerValueChanged(sender: UIDatePicker) {
        var dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        NSUserDefaults.standardUserDefaults().setObject(dateformatter.stringFromDate(sender.date), forKey: "birthday")
        birthdayInputField.text = dateformatter.stringFromDate(sender.date)
    }
    
//  Countries field

    @IBAction func countriesFieldEditing(sender: UITextField) {
        sender.inputView = countriesPickerView
    }
    
//  General functions
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case disciplinesPickerView:
            return disciplines.count;
        case countriesPickerView:
            return countries.count;
        default:
            return 1;
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch pickerView {
        case disciplinesPickerView:
            mainDisciplineField.text = disciplines[row]
            NSUserDefaults.standardUserDefaults().setObject(disciplines[row], forKey: "mainDiscipline")
            return disciplines[row]
        case countriesPickerView:
            countriesInputField.text = countries[row]
            NSUserDefaults.standardUserDefaults().setObject(countries[row], forKey: "country")
            return countries[row]
        default:
            return emptyState[0];
        }
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
        let newLength = count("textView.text".utf16) + count(text.utf16) - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == aboutField && textView.text == PLACEHOLDER_TEXT
            {
                if count(text.utf16) == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            
            var textLength : Int = MAX_NUMBER_OF_NOTES_CHARS - count(aboutField.text)
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

}
