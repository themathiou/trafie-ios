//
//  TRFProfileViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

class TRFProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let emptyState = ["Nothing to select"]
    
//  fields
    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    @IBOutlet weak var aboutFieldLetterCounter: UILabel!
    
    
    @IBOutlet weak var mainDisciplineField: UITextField!
    @IBOutlet weak var birthdayInputField: UITextField!
    @IBOutlet weak var countriesInputField: UITextField!
    @IBOutlet weak var privacyToggle: UISwitch!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
//  pickers
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var countriesPickerView:UIPickerView = UIPickerView()
    var doneButton:UIButton = UIButton (frame: CGRectMake(100, 100, 100, 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.countriesPickerView.dataSource = self;
        self.countriesPickerView.delegate = self;
    }
    
//  Firstname
    @IBAction func fnameFieldEdit(sender: UITextField) {
        println(sender.text)
    }
    
//  Lastname
    @IBAction func lnameFieldEdit(sender: UITextField) {
        println(sender.text)
    }

// About
    @IBAction func aboutFieldTyping(sender: UITextField) {
        var textLength : Int = 400 - count(aboutField.text)
        aboutFieldLetterCounter.text = String(textLength)
    }
    
    
//  Main Discipline
    @IBAction func mainDisciplineEditing(sender: UITextField) {
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.tag = 1
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
        
        sender.inputView = disciplinesPickerView
        
        sender.inputAccessoryView = doneButton
    }
    
//  Privacy
    @IBAction func privacyEditing(sender: UISwitch) {
        if sender.on {
            println("The gig is up")
        } else {
            println("Nope")
        }
        
    }

//  Gender
    @IBAction func genderSegmentEdit(sender: UISegmentedControl) {
        println(sender.selectedSegmentIndex)
    }

 
//  Birthday
    @IBAction func birthdayFieldEditing(sender: UITextField) {
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.tag = 2
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
        
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)

        sender.inputAccessoryView = doneButton
    }

    func datePickerValueChanged(sender: UIDatePicker) {
        var dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        birthdayInputField.text = dateformatter.stringFromDate(sender.date)
    }
    
//  Countries field

    @IBAction func countriesFieldEditing(sender: UITextField) {
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.tag = 3
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
        
        sender.inputView = countriesPickerView
        
        sender.inputAccessoryView = doneButton
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
            return disciplines[row]
        case countriesPickerView:
            countriesInputField.text = countries[row]
            return countries[row]
        default:
            return emptyState[0];
        }
    }
    
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1:
            mainDisciplineField.resignFirstResponder()
        case 2:
            birthdayInputField.resignFirstResponder()
        case 3:
            countriesInputField.resignFirstResponder()
        default:
            mainDisciplineField.resignFirstResponder()
        }
    }

}
