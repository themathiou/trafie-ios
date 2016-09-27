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
import Alamofire
import Photos
import Kingfisher

class ProfileEditVC: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {
  
  // MARK: Constants
  let emptyState = ["Nothing to select"]
  
  var _isFormDirty: Bool = false
  var _firstNameError: Bool = false
  var _lastNameError: Bool = false
  var _aboutError: Bool = false
  var _profileImageEdited: Bool = false
  var _aboutEdited: Bool = false
  var _disciplineEdited: Bool = false
  var _birthdayEdited: Bool = false
  var _countryEdited: Bool = false
  
  let tapViewRecognizer = UITapGestureRecognizer()
  
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
  @IBOutlet weak var selectPictureButton: UIButton!
  
  // MARK: Pickers
  var disciplinesPickerView:UIPickerView = UIPickerView()
  var datePickerView:UIDatePicker = UIDatePicker()
  var countriesPickerView:UIPickerView = UIPickerView()
  
  /// Local variable that stores the settings that changed
  var _settings = [String : AnyObject]()
  
  override func viewWillAppear(_ animated: Bool) {
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(ProfileEditVC.showConnectionStatusChange(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    tapViewRecognizer.addTarget(self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tapViewRecognizer)
    
    //progress indicator
    self.navigationController?.progressTintColor = CLR_TRAFIE_RED
    self.navigationController?.progressHeight = 3.0

    //about text counter
    let initialAboutTextCharLength : Int = MAX_CHARS_NUMBER_IN_ABOUT - aboutField.text.characters.count
    aboutCharsCounter.text = String(initialAboutTextCharLength)
    
    //datePickerView
    datePickerView.datePickerMode = UIDatePickerMode.date
    // limit birthday to 10 years back
    datePickerView.maximumDate = Date().addingTimeInterval(-315360000)
    
    setSettingsValuesFromNSDefaultToViewFields()
    
    // SHOULD be called AFTER values have been set from NSDefault.
    toggleSaveButton()
    
    // Initialize Discipline picker
    let userPreselectedDiscipline : String = UserDefaults.standard.object(forKey: "mainDiscipline") as! String
    if userPreselectedDiscipline != "" {
      for i in 0 ..< disciplinesAll.count  {
        if userPreselectedDiscipline == disciplinesAll[i] {
          self.disciplinesPickerView.selectRow(i, inComponent: 0, animated: true)
          break
        }
      }
    }
    
    // Initialize Country picker
    let userPreselectedCountry : String = UserDefaults.standard.object(forKey: "country") as! String
    if userPreselectedCountry != "" {
      for i in 0 ..< countriesShort.count  {
        if userPreselectedCountry == countriesShort[i] {
          self.countriesPickerView.selectRow(i, inComponent: 0, animated: true)
          break
        }
      }
    }
    
    //style profile pic
    self.selectPictureButton.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.selectPictureButton.clipsToBounds = true
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = true
    
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(_ notification: Notification) {
    Utils.showConnectionStatusChange()
  }
  
  // MARK:- Fields' functions
  // MARK: firstname
  @IBAction func firsnameValueChanged(_ sender: AnyObject) {
    _firstNameError = Utils.isTextFieldValid(self.firstNameField, regex: REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS)
    toggleSaveButton()
    _settings["firstName"] = self.firstNameField.text! as AnyObject?
  }
  
  // MARK: lastname
  @IBAction func lastnameValueChanged(_ sender: AnyObject) {
    _lastNameError = Utils.isTextFieldValid(self.lastNameField, regex: REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS)
    toggleSaveButton()
    _settings["lastName"] = self.lastNameField.text! as AnyObject?
  }
  
  // MARK: About
  /**
   Remove the placeholder text when they start typing
   first, see if the field is empty. IF it's not empty, then the text should be black and not italic
   BUT, we also need to remove the placeholder text if that's the only text
   if it is empty, then the text should be the placeholder
   */
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
    
    _settings["about"] = aboutField.text! as AnyObject?
    self._aboutEdited = true
    
    toggleSaveButton()
    return true
  }
  
  // MARK: main discipline
  @IBAction func mainDisciplineEditing(_ sender: UITextField) {
    sender.inputView = disciplinesPickerView
  }
  
  @IBAction func mainDisciplineChanged(_ sender: AnyObject) {
    _settings["discipline"] = disciplinesAll[disciplinesPickerView.selectedRow(inComponent: 0)] as AnyObject?
    self.mainDisciplineField.text = NSLocalizedString(disciplinesAll[self.disciplinesPickerView.selectedRow(inComponent: 0)], comment:"text shown in text field for main discipline")
    self._disciplineEdited = true
  }

  // MARK: birthday
  @IBAction func birthdayFieldEditing(_ sender: UITextField) {
    sender.inputView = datePickerView
  }
  
  @IBAction func birthdayFieldChanged(_ sender: AnyObject) {
    dateFormatter.dateFormat = "dd-MM-YYYY"
    self.birthdayField.text = dateFormatter.string(from: self.datePickerView.date)
    dateFormatter.dateFormat = "YYYY-MM-dd"
    _settings["birthday"] = dateFormatter.string(from: datePickerView.date) as AnyObject?
    self._birthdayEdited = true
  }

  // MARK: countries
  @IBAction func countriesFieldEditing(_ sender: UITextField) {
    sender.inputView = countriesPickerView
  }
  
  @IBAction func countriesFieldChanged(_ sender: AnyObject) {
    self.countryField.text = NSLocalizedString(countriesShort[self.countriesPickerView.selectedRow(inComponent: 0)], comment:"text shown in text field for countries")
    _settings["country"] = countriesShort[countriesPickerView.selectedRow(inComponent: 0)] as AnyObject?
    self._countryEdited = true
  }

  // MARK:- Image upload
  @IBAction func selectPicture(_ sender: AnyObject) {
    let cameraViewController = CameraViewController(croppingEnabled: true) { [weak self] image, asset in
      if image != nil {
        self!.profileImage.image = image?.resizeToTargetSize(CGSize(width: 600.0, height: 600.0))
        self!._profileImageEdited = true
      }
      self?.dismiss(animated: true, completion: nil)
    }
    
    present(cameraViewController, animated: true, completion: nil)
  }
  
  
  // MARK:- Pickers' functions
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    Utils.dismissFirstResponder(view)
    return true;
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView {
    case disciplinesPickerView:
      return disciplinesAll.count;
    case countriesPickerView:
      return countriesShort.count;
    default:
      return 1;
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView {
    case disciplinesPickerView:
      return NSLocalizedString(disciplinesAll[row], comment:"translation of discipline \(row)")
    case countriesPickerView:
      return NSLocalizedString(countriesShort[row], comment:"translation of discipline \(row)")
    default:
      return emptyState[0];
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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

  // MARK:- General Functions
  @IBAction func saveProfile(_ sender: AnyObject) {
    self.enableAllViewElements(false)
    Utils.dismissFirstResponder(view)
    Utils.showNetworkActivityIndicatorVisible(true)
    self.navigationItem.title = "Saving..."
    
    /// date format for birthday should be YYYY-MM-dd
    dateFormatter.dateFormat = "YYYY-MM-dd"
    
    let userId = (UserDefaults.standard.object(forKey: "userId") as? String)!
    _settings["isMale"] = self.isMaleSegmentation.selectedSegmentIndex == 0 ? "true" as AnyObject? : "false" as AnyObject? //male = true
    _settings["isPrivate"] = self.isPrivateSegmentation.selectedSegmentIndex == 0 ? "true" as AnyObject? : "false" as AnyObject?
    let selectedMeasurementUnit: String = self.measurementUnitsSegmentation.selectedSegmentIndex == 0 ? MeasurementUnits.Meters.rawValue : MeasurementUnits.Feet.rawValue
    
    _settings["units"] = ["distance": selectedMeasurementUnit] as AnyObject?
    
    Utils.log(String(describing: _settings))

    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)",  "Content-Type": "application/json"]
    Utils.log("TOKEN >>> \(String(accessToken))")
    let endPoint: String = trafieURL + "api/users/\(userId)/"
    
//    Alamofire.upload(
//      multipartFormData: { mfd in
//        if self._profileImageEdited, let imageData: NSMutableData = Data(data: UIImageJPEGRepresentation(self.profileImage.image!, 1)!) as Data {
//          mfd.appendBodyPart(data: imageData, name: "picture", fileName: "profile-picture.jpeg", mimeType: "image/jpeg")
//        }
//        
//        for (key, value) in self._settings {
//          if value is NSString {
//            print(type(of: value).description())
//            print(value)
//            
//            mfd.appendBodyPart(data: value.data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
//          }
//
//          if value is NSDictionary {
//            let options = JSONSerialization.WritingOptions()
//            do {
//              try mfd.appendBodyPart(data: JSONSerialization.data(withJSONObject: value, options: options), name: key)
//              print(value)
//            } catch let error as NSError {
//              Utils.log(error.description)
//            }
//          }
//        }
//        print(mfd.boundary)
//        print(mfd.contentType)
//      },
//      to: endPoint,
//      method: .post,
//      encodingCompletion: { encodingResult in
//        switch encodingResult {
//        case .success(let upload, _, _):
//          upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//            DispatchQueue.main.async(execute: {
//              /**
//               *  Update UI Thread about the progress
//               */
//              let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
//              self.navigationController?.setProgress(Float(progress), animated: true)
//            })
//          }
//          upload.responseJSON { response in
//            self.navigationItem.title = "Edit Profile"
//
//            Utils.showNetworkActivityIndicatorVisible(false)
//            self.navigationController?.finishProgress()
//            self.enableAllViewElements(true)
//            
//            let json = JSON(response.result.value!)
//            if response.result.isSuccess {
//              if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
//                let isMale = self.isMaleSegmentation.selectedSegmentIndex == 0 ? true : false
//                UserDefaults.standard.set(isMale, forKey: "isMale")
//                
//                let isPrivate = self.isPrivateSegmentation.selectedSegmentIndex == 0 ? true : false
//                UserDefaults.standard.set(isPrivate, forKey: "isPrivate")
//                if selectedMeasurementUnit != (UserDefaults.standard.object(forKey: "measurementUnitsDistance") as? String)! {
//                  UserDefaults.standard.set(selectedMeasurementUnit, forKey: "measurementUnitsDistance")
//                  NotificationCenter.default.post(name: Notification.Name(rawValue: "recalculateActivities"), object: nil)
//                }
//                
//                UserDefaults.standard.set(self.firstNameField.text, forKey: "firstname")
//                UserDefaults.standard.set(self.lastNameField.text, forKey: "lastname")
//                if self._aboutEdited {
//                  UserDefaults.standard.set(self.aboutField.text, forKey: "about")
//                }
//                if self._disciplineEdited {
//                  UserDefaults.standard.set(disciplinesAll[self.disciplinesPickerView.selectedRow(inComponent: 0)], forKey: "mainDiscipline")
//                }
//                if self._birthdayEdited {
//                  UserDefaults.standard.set(dateFormatter.string(from: self.datePickerView.date), forKey: "birthday")
//                }
//                if self._countryEdited {
//                  UserDefaults.standard.set(countriesShort[self.countriesPickerView.selectedRow(inComponent: 0)], forKey: "country")
//                }
//                
//                if self._profileImageEdited && json["picture"] != nil {
//                  UserDefaults.standard.set(json["picture"].string!, forKey: "profilePicture")
//                }
//                
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadProfile"), object: nil)
//                SweetAlert().showAlert("Profile Updated", subTitle: "", style: AlertStyle.success)
//                self.dismiss(animated: true, completion: {})
//              } else if Utils.validateTextWithRegex(StatusCodesRegex._422.rawValue, text: String((response.response!.statusCode))) {
//                Utils.log(json["message"].string!)
//                Utils.log("\(json["errors"][0]["field"].string!) : \(json["errors"][0]["code"].string!)")
//                SweetAlert().showAlert("Invalid data", subTitle: "It seems that \(json["errors"][0]["field"].string!) is \(json["errors"][0]["code"].string!)", style: AlertStyle.error)
//              } else {
//                Utils.log(json["message"].string!)
//                SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
//              }
//            } else if response.result.isFailure {
//              Utils.log("Request failed with error: \(response.result.error)")
//              Utils.log(json["message"].string!)
//              SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
//            }
//          }
//        case .failure(let encodingError):
//          Utils.log("FAIL: " +  String(encodingError))
//          self.navigationItem.title = "Edit Profile"
//          self.enableAllViewElements(true)
//          SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
//        }
//    },
//    headers: headers)
  }
  
  /// Dismiss the view
  @IBAction func dismissView(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: {})
  }
  
  /// Displays all required fields from NSUserDefaults in fields
  func setSettingsValuesFromNSDefaultToViewFields() {
    dateFormatter.dateStyle = DateFormatter.Style.medium
    
    let profilePicUrl:String = (UserDefaults.standard.object(forKey: "profilePicture") as? String)!
    self.profileImage.kf.setImage(with: URL(string: profilePicUrl)!)
    
    self.firstNameField.text = UserDefaults.standard.object(forKey: "firstname") as? String
    self.lastNameField.text = UserDefaults.standard.object(forKey: "lastname") as? String
    let _about: String = UserDefaults.standard.object(forKey: "about") as! String
    self.aboutField.text = (_about != ABOUT_PLACEHOLDER_TEXT) ? _about : ""
    let _disciplineReadable: String = (UserDefaults.standard.object(forKey: "mainDiscipline") as? String)!
    self.mainDisciplineField.text = NSLocalizedString(_disciplineReadable, comment:"translation of discipline")
    self.isMaleSegmentation.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "isMale") == true ?  0 : 1
    self.isPrivateSegmentation.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "isPrivate") == true ?  0 : 1
    self.measurementUnitsSegmentation.selectedSegmentIndex = (UserDefaults.standard.object(forKey: "measurementUnitsDistance") as? String)! == MeasurementUnits.Meters.rawValue ?  0 : 1
    self.birthdayField.text = UserDefaults.standard.object(forKey: "birthday") as? String
    dateFormatter.dateFormat = "yyyy-MM-dd"
    if self.birthdayField.text! != "" {
      let _birthday: Date = dateFormatter.date(from: self.birthdayField.text!)!
      datePickerView.setDate(_birthday, animated: true)
    }
    let _countryReadable: String = (UserDefaults.standard.object(forKey: "country") as? String)!
    self.countryField.text = NSLocalizedString(_countryReadable, comment:"translation of country")
  }
  
  /// Toggles Save Button based on form errors
  func toggleSaveButton() {
    let isValid = isFormValid()
    let status = Reach().connectionStatus()
    
    if(isValid && status.description != ReachabilityStatus.unknown.description && status.description != ReachabilityStatus.offline.description ) {
      self.saveButton.isEnabled = true
      self.saveButton.tintColor = UIColor.blue
    } else {
      self.saveButton.isEnabled = false
      self.saveButton.tintColor = CLR_MEDIUM_GRAY
    }
  }
  
  /// Verifies that form is valid
  func isFormValid() -> Bool {
    return !_isFormDirty && !_firstNameError && !_lastNameError && !_aboutError
  }
  
  func dismissKeyboard() {
    Utils.dismissFirstResponder(view)
  }
  
  /// Disables all view elements. Used while loading.
  func enableAllViewElements(_ isEnabled: Bool) {
    self.closeButton.isEnabled = isEnabled
    self.saveButton.isEnabled = isEnabled
    self.firstNameField.isEnabled = isEnabled
    self.lastNameField.isEnabled = isEnabled
    self.mainDisciplineField.isEnabled = isEnabled
    self.isMaleSegmentation.isEnabled = isEnabled
    self.birthdayField.isEnabled = isEnabled
    self.countryField.isEnabled = isEnabled
    self.aboutField.isUserInteractionEnabled = isEnabled
    self.measurementUnitsSegmentation.isEnabled = isEnabled
    self.isPrivateSegmentation.isEnabled = isEnabled
    self.selectPictureButton.isEnabled = isEnabled
  }
  
}



