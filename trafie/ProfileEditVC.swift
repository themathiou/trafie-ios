//
//  ProfileEditViewController.swift
//  trafie
//
//  Created by mathiou on 28/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import ALCameraViewController

class ProfileEditVC: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {

    // MARK: Constants
    let emptyState = ["Nothing to select"]
    
    var _isFormDirty: Bool = false
    var _firstNameError: Bool = false
    var _lastNameError: Bool = false
    var _aboutError: Bool = false
    
    var _aboutEdited: Bool = false
    var _disciplineEdited: Bool = false
    var _birthdayEdited: Bool = false
    var _countryEdited: Bool = false

    // MARK: Header Elements
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Profile Form Elements
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var aboutField: UITextView!
    @IBOutlet weak var aboutCharsCounter: UILabel!
    @IBOutlet weak var mainDisciplineField: UITextField!
    @IBOutlet weak var isMaleSegmentation: UISegmentedControl!
    @IBOutlet weak var isPrivateSegmentation: UISegmentedControl!
    @IBOutlet weak var measurementUnitsSegmentation: UISegmentedControl!
    @IBOutlet weak var measurementUnitsDistanceSegmentation: UISegmentedControl!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    
    // MARK: Pickers
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var countriesPickerView:UIPickerView = UIPickerView()
    var doneButton: UIButton = keyboardButtonCentered
    
    /// Local variable that stores the settings that changed
    var _settings = [String : AnyObject]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        let name = "iOS : ProfileEdit ViewController"
        Utils.googleViewHitWatcher(name);
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.countriesPickerView.dataSource = self;
        self.countriesPickerView.delegate = self;
        self.aboutField.delegate = self
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self

        // initialize error flags
        _isFormDirty = false
        _firstNameError = false
        _lastNameError = false
        _aboutError = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileEditVC.showConnectionStatusChange(_:)), name: ReachabilityStatusChangedNotification, object: nil)

        //about text counter
        let initialAboutTextCharLength : Int = MAX_CHARS_NUMBER_IN_ABOUT - aboutField.text.characters.count
        aboutCharsCounter.text = String(initialAboutTextCharLength)

        //datePickerView
        datePickerView.datePickerMode = UIDatePickerMode.Date
        // limit birthday to 10 years back
        datePickerView.maximumDate = NSDate().dateByAddingTimeInterval(-315360000)

        // Done button for keyboard and pickers
        doneButton.addTarget(self, action: #selector(ProfileEditVC.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
        
        setSettingsValuesFromNSDefaultToViewFields()

        // SHOULD be called AFTER values have been set from NSDefault.
        toggleSaveButton()
        
        // Initialize Discipline picker
        let userPreselectedDiscipline : String = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as! String
        if userPreselectedDiscipline != "" {
            for i in 0 ..< disciplinesAll.count  {
                if userPreselectedDiscipline == disciplinesAll[i] {
                    self.disciplinesPickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
        }
        
        // Initialize Country picker
        let userPreselectedCountry : String = NSUserDefaults.standardUserDefaults().objectForKey("country") as! String
        if userPreselectedCountry != "" {
            for i in 0 ..< countriesShort.count  {
                if userPreselectedCountry == countriesShort[i] {
                    self.countriesPickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
        }
        
        //style profile pic
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true
    
    }

    // MARK:- Network Connection
    /**
     Calls Utils function for network change indication
     
     - Parameter notification : notification event
     */
    @objc func showConnectionStatusChange(notification: NSNotification) {
        Utils.showConnectionStatusChange()
    }
    
    // MARK:- Fields' functions
    // MARK: firstname
    @IBAction func fnameFieldFocused(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }

    @IBAction func firsnameValueChanged(sender: AnyObject) {
        _firstNameError = Utils.isTextFieldValid(self.firstNameField, regex: REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS)
        toggleSaveButton()
        _settings["firstName"] = self.firstNameField.text!
    }

    // MARK: lastname
    @IBAction func lnameFieldFocused(sender: UITextField) {
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton
    }
    
    @IBAction func lastnameValueChanged(sender: AnyObject) {
        _lastNameError = Utils.isTextFieldValid(self.lastNameField, regex: REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS)
        toggleSaveButton()
        _settings["lastName"] = self.lastNameField.text!
    }

    // MARK: About
    /**
      Remove the placeholder text when they start typing
      first, see if the field is empty. IF it's not empty, then the text should be black and not italic
      BUT, we also need to remove the placeholder text if that's the only text
      if it is empty, then the text should be the placeholder
     */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let remainingTextLength : Int = MAX_CHARS_NUMBER_IN_ABOUT - aboutField.text.characters.count
        aboutCharsCounter.text = String(remainingTextLength)
        if remainingTextLength < 10 {
            if remainingTextLength >= 0 {
                aboutCharsCounter.textColor = CLR_NOTIFICATION_ORANGE
                aboutField.textColor = CLR_DARK_GRAY
                _aboutError = false
            } else {
                aboutCharsCounter.textColor = CLR_NOTIFICATION_RED
                aboutField.textColor = CLR_NOTIFICATION_RED
                _aboutError = true
            }
        } else {
            aboutField.layer.borderWidth = 0
            aboutCharsCounter.textColor = CLR_DARK_GRAY
            _aboutError = false
        }
        
        _settings["about"] = aboutField.text!
        self._aboutEdited = true
        
        toggleSaveButton()
        return true
    }
    
    // MARK: main discipline
    @IBAction func mainDisciplineEditing(sender: UITextField) {
        sender.inputView = disciplinesPickerView
        doneButton.tag = 4
        sender.inputAccessoryView = doneButton
    }

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
    }

    // MARK:- Image upload
    @IBAction func selectPicture(sender: AnyObject) {
        let cameraViewController = CameraViewController(croppingEnabled: true) { [weak self] image, asset in
            self!.profileImage.image = image
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }

    
    // MARK:- Pickers' functions
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        Utils.dismissFirstResponder(view)
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
            Utils.log(disciplinesAll[row]);
        case countriesPickerView:
            Utils.log(countriesShort[row]);
        default:
            Utils.log("Did select row of uknown picker? wtf?")
        }
        
        toggleSaveButton()
    }

    /// Function called from all "done" buttons of keyboards and pickers.
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1: // First Name Keyboard
            Utils.dismissFirstResponder(view)
        case 2: // Last Name Keyboard
            Utils.dismissFirstResponder(view)
        case 3: // About Keyboard
            Utils.dismissFirstResponder(view)
        case 4: // Main discipline picker view
            _settings["discipline"] = disciplinesAll[disciplinesPickerView.selectedRowInComponent(0)]
            self.mainDisciplineField.text = NSLocalizedString(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for main discipline")
            self._disciplineEdited = true
            Utils.dismissFirstResponder(view)
        case 5: // Birthday picker view
            dateFormatter.dateFormat = "dd-MM-YYYY"
            self.birthdayField.text = dateFormatter.stringFromDate(self.datePickerView.date)
            dateFormatter.dateFormat = "YYYY-MM-dd"
            _settings["birthday"] = dateFormatter.stringFromDate(datePickerView.date)
            self._birthdayEdited = true
            Utils.dismissFirstResponder(view)
        case 6: //county picker view
            self.countryField.text = NSLocalizedString(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], comment:"text shown in text field for countries")
            _settings["country"] = countriesShort[countriesPickerView.selectedRowInComponent(0)]
            self._countryEdited = true
            Utils.dismissFirstResponder(view)
        default:
            Utils.log("doneButton default");
        }
    }
    
    // MARK:- General Functions
    @IBAction func saveProfile(sender: AnyObject) {
        Utils.dismissFirstResponder(view)

        /// date format for birthday should be YYYY-MM-dd
        dateFormatter.dateFormat = "YYYY-MM-dd"

        let userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
        _settings["isMale"] = self.isMaleSegmentation.selectedSegmentIndex == 0 ? true : false //male = true
        _settings["isPrivate"] = self.isPrivateSegmentation.selectedSegmentIndex == 0 ? true : false
        let selectedMeasurementUnit: String = self.measurementUnitsSegmentation.selectedSegmentIndex == 0 ? MeasurementUnits.Meters.rawValue : MeasurementUnits.Feet.rawValue

        _settings["units"] = ["distance": selectedMeasurementUnit]

        Utils.log(String(_settings))
        
        Utils.showNetworkActivityIndicatorVisible(true)
        setNotificationState(.Info, notification: statusBarNotification, style:.StatusBarNotification)
        statusBarNotification.displayNotificationWithMessage("Saving...", completion: {})
        
        ApiHandler.updateLocalUserSettings(userId, settingsObject: _settings)
            .responseJSON { request, response, result in

                Utils.showNetworkActivityIndicatorVisible(false)
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                        let isMale = self.isMaleSegmentation.selectedSegmentIndex == 0 ? true : false
                        NSUserDefaults.standardUserDefaults().setObject(isMale, forKey: "isMale")
                        
                        let isPrivate = self.isPrivateSegmentation.selectedSegmentIndex == 0 ? true : false
                        NSUserDefaults.standardUserDefaults().setObject(isPrivate, forKey: "isPrivate")
                        if selectedMeasurementUnit != (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)! {
                            NSUserDefaults.standardUserDefaults().setObject(selectedMeasurementUnit, forKey: "measurementUnitsDistance")
                            NSNotificationCenter.defaultCenter().postNotificationName("recalculateActivities", object: nil)
                        }

                        NSUserDefaults.standardUserDefaults().setObject(self.firstNameField.text, forKey: "firstname")
                        NSUserDefaults.standardUserDefaults().setObject(self.lastNameField.text, forKey: "lastname")
                        if (self._aboutEdited) {
                            NSUserDefaults.standardUserDefaults().setObject(self.aboutField.text, forKey: "about")
                        }
                        if (self._disciplineEdited) {
                            NSUserDefaults.standardUserDefaults().setObject(disciplinesAll[self.disciplinesPickerView.selectedRowInComponent(0)], forKey: "mainDiscipline")
                        }
                        if (self._birthdayEdited) {
                            NSUserDefaults.standardUserDefaults().setObject(dateFormatter.stringFromDate(self.datePickerView.date), forKey: "birthday")
                        }
                        if (self._countryEdited) {
                            NSUserDefaults.standardUserDefaults().setObject(countriesShort[self.countriesPickerView.selectedRowInComponent(0)], forKey: "country")
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                        SweetAlert().showAlert("Profile Updated", subTitle: "", style: AlertStyle.Success)
                        self.dismissViewControllerAnimated(true, completion: {})
                    } else if Utils.validateTextWithRegex(StatusCodesRegex._422.rawValue, text: String((response?.statusCode)!)) {
                        Utils.log(json["message"].string!)
                        Utils.log("\(json["errors"][0]["field"].string!) : \(json["errors"][0]["code"].string!)")
                        SweetAlert().showAlert("Invalid data", subTitle: "It seems that \(json["errors"][0]["field"].string!) is \(json["errors"][0]["code"].string!)", style: AlertStyle.Error)
                    } else {
                        Utils.log(json["message"].string!)
                        SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                    }

                case .Failure(let data, let error):
                    Utils.log("Request failed with error: \(error)")
                    Utils.log("Response data: \(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                    SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                }

                // Dismissing status bar notification
                statusBarNotification.dismissNotification()
        }
        
    }
    
    /// Dismiss the view
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    /// Displays all required fields from NSUserDefaults in fields
    func setSettingsValuesFromNSDefaultToViewFields() {
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        let profilePicUrl:String = (NSUserDefaults.standardUserDefaults().objectForKey("profilePicture") as? String)!
        self.profileImage.kf_setImageWithURL(NSURL(string: profilePicUrl)!)

        self.firstNameField.text = NSUserDefaults.standardUserDefaults().objectForKey("firstname") as? String
        self.lastNameField.text = NSUserDefaults.standardUserDefaults().objectForKey("lastname") as? String
        let _about: String = NSUserDefaults.standardUserDefaults().objectForKey("about") as! String
        self.aboutField.text = (_about != ABOUT_PLACEHOLDER_TEXT) ? _about : ""
        let _disciplineReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as? String)!
        self.mainDisciplineField.text = NSLocalizedString(_disciplineReadable, comment:"translation of discipline")
        self.isMaleSegmentation.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().boolForKey("isMale") == true ?  0 : 1
        self.isPrivateSegmentation.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().boolForKey("isPrivate") == true ?  0 : 1
        self.measurementUnitsSegmentation.selectedSegmentIndex = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)! == MeasurementUnits.Meters.rawValue ?  0 : 1
        self.birthdayField.text = NSUserDefaults.standardUserDefaults().objectForKey("birthday") as? String
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if self.birthdayField.text! != "" {
            let _birthday: NSDate = dateFormatter.dateFromString(self.birthdayField.text!)!
            datePickerView.setDate(_birthday, animated: true)
        }
        let _countryReadable: String = (NSUserDefaults.standardUserDefaults().objectForKey("country") as? String)!
        self.countryField.text = NSLocalizedString(_countryReadable, comment:"translation of country")
    }
    
    /// Toggles Save Button based on form errors
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
    
    /// Verifies that form is valid
    func isFormValid() -> Bool {
        return !_isFormDirty && !_firstNameError && !_lastNameError && !_aboutError
    }
    
}



