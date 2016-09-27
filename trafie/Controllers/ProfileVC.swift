//
//  ProfileViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher
import Alamofire

class ProfileVC: UITableViewController {
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var fullName: UILabel!
  @IBOutlet weak var disciplineCountryCombo: UILabel!
  @IBOutlet weak var email: UILabel!
  @IBOutlet weak var about: UITextView!
  @IBOutlet weak var isMale: UILabel!
  @IBOutlet weak var birthday: UILabel!
  @IBOutlet weak var profilePrivacy: UILabel!
  @IBOutlet weak var measurementUnitsDistance: UILabel!
  @IBOutlet weak var userEmail: UITableViewCell!
  @IBOutlet weak var emailStatusIndication: UIImageView!
  @IBOutlet weak var emailStatusRefreshSpinner: UIActivityIndicatorView!
  
  @IBOutlet weak var refreshBarButton: UIBarButtonItem!
  @IBOutlet weak var versionIndication: UILabel!
  
  @IBOutlet weak var legalAbout: UIButton!
  @IBOutlet weak var legalTerms: UIButton!
  @IBOutlet weak var legalPrivacy: UIButton!
  
  let tapEmailIndication = UITapGestureRecognizer()
  
  @IBOutlet var reportProblemButton: UIButton!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : Profile ViewController"
    Utils.googleViewHitWatcher(name)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.reloadProfile(_:)), name:NSNotification.Name(rawValue: "reloadProfile"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.showConnectionStatusChange(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    
    
    tapEmailIndication.addTarget(self, action: #selector(ProfileVC.showEmailIndicationView))
    self.emailStatusIsUpdating(false)
    self.userEmail.addGestureRecognizer(tapEmailIndication)
    self.versionIndication.text = "trafie v.\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)"
    self.setSettingsValuesFromNSDefaultToViewFields()
    
    //style profile pic
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
    self.profilePicture.clipsToBounds = true
    
  }
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(_ notification: Notification) {
    Utils.showConnectionStatusChange()
  }
  
  /**
   Prompt a logout dialog for loging out.
   If user accepts, logs out the user and clean all data related to him.
   If cancel closes the prompt window.
   
   - Parameter sender: the object that activates the logout action.
   */
  @IBAction func logout(_ sender: AnyObject) {
    SweetAlert().showAlert("Logout", subTitle: "Are you sure?", style: AlertStyle.none, buttonTitle:"Stay here", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Logout", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
      if isOtherButton == true {
        Utils.log("Logout Cancelled")
      }
      else {
        ApiHandler.logout()
          .responseJSON { response in
            if response.result.isSuccess {
              Utils.log(String(describing: response))
              
              if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                Utils.log("Succesfully logout")
              } else {
                Utils.log("Log user out but something went wrong.")
              }
            }
            else if response.result.isFailure {
              Utils.log("Request failed with error: \(response.result.error)")
              if let data = response.data {
                Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
              }
            }
            
            // We MUST logout the user in any case
            Utils.clearLocalUserData()
            let loginVC = self.storyboard!.instantiateViewController(withIdentifier: "loginPage")
            self.present(loginVC, animated: true, completion: nil)
            
        }
      }
    }
    
  }
  
  @IBAction func refreshProfile(_ sender: AnyObject) {
    let userId = UserDefaults.standard.object(forKey: "userId") as! String
    
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
      SweetAlert().showAlert("You are offline!", subTitle: "Try again when internet is available!", style: AlertStyle.warning)
    case .online(.wwan), .online(.wiFi):
//      setNotificationState(.Info, notification: statusBarNotification, style:.StatusBarNotification)
//      statusBarNotification.displayNotificationWithMessage("Syncing...", completion: {})
      Utils.showNetworkActivityIndicatorVisible(true)
      getLocalUserSettings(userId)
        .then { promise -> Void in
          if promise == .Success {
            self.setSettingsValuesFromNSDefaultToViewFields()
          }
//          statusBarNotification.dismissNotification()
          Utils.showNetworkActivityIndicatorVisible(false)
      }
    }
  }
  
  @objc fileprivate func reloadProfile(_ notification: Notification){
    self.setSettingsValuesFromNSDefaultToViewFields()
  }
  
  /// Reads values from NSUserDefaults and applies them into fields of UI.
  func setSettingsValuesFromNSDefaultToViewFields() {
    let disciplineKey: String = (UserDefaults.standard.object(forKey: "mainDiscipline") as? String)!
    let countryKey: String = (UserDefaults.standard.object(forKey: "country") as? String)!
    let fname: String = (UserDefaults.standard.object(forKey: "firstname") as? String)!
    let lname: String = (UserDefaults.standard.object(forKey: "lastname") as? String)!
    let discipline: String = (disciplineKey != "") ? NSLocalizedString(disciplineKey, comment:"translation of discipline") : "Discipline"
    let country: String = (countryKey != "") ? NSLocalizedString(countryKey, comment:"translation of country") : "Country"
    
    let profilePicUrl:String = (UserDefaults.standard.object(forKey: "profilePicture") as? String)!
    self.profilePicture.kf.setImage(with: URL(string: profilePicUrl)!)
    
    self.fullName.text = "\(fname) \(lname)"

    self.disciplineCountryCombo.text = "\(discipline) | \(country)"
    
    self.about.text = UserDefaults.standard.object(forKey: "about") as? String
    setTextViewTextStyle(self.about, placeholderText: ABOUT_PLACEHOLDER_TEXT )
    self.isMale.text = UserDefaults.standard.bool(forKey: "isMale") ? "Male" : "Female"
    setInputFieldTextStyle(self.isMale, placeholderText: "Gender")
    self.birthday.text = UserDefaults.standard.object(forKey: "birthday") as? String
    setInputFieldTextStyle(self.birthday, placeholderText: "Birthday")
    self.email.text = UserDefaults.standard.object(forKey: "email") as? String
    self.measurementUnitsDistance.text = UserDefaults.standard.object(forKey: "measurementUnitsDistance") as? String
    
    let isPrivateProfile: String = UserDefaults.standard.bool(forKey: "isPrivate") ? "Only you can see your profile." : "Your profile is visible to everyone."
    self.profilePrivacy.text = isPrivateProfile
    
    //emailIndication
    let isUserVerified: Bool = UserDefaults.standard.bool(forKey: "isVerified")
    if isUserVerified {
      setIconWithColor(self.emailStatusIndication, iconName: "ic_check", color: CLR_NOTIFICATION_GREEN)
    } else {
      setIconWithColor(self.emailStatusIndication, iconName: "ic_error_outline", color: CLR_NOTIFICATION_ORANGE)
    }
  }
  
  /// Shows edit profile View
  @IBAction func showEditProfileView(_ sender: AnyObject) {
    let editProfileVC = self.storyboard!.instantiateViewController(withIdentifier: "EditProfileViewController")
    
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
      SweetAlert().showAlert("You are offline!", subTitle: "Try again when internet is available!", style: AlertStyle.warning)
    case .online(.wwan), .online(.wiFi):
      self.present(editProfileVC, animated: true, completion: nil)
    }
  }
  
  
  /// Fetch local user's settings in order to check if email address is validated. Updates indication icon accordingly and push the proper ui-view for user-email-indication
  func showEmailIndicationView() {
    let userEmailVC = self.storyboard!.instantiateViewController(withIdentifier: "UserEmailNavigationController")
    self.emailStatusIsUpdating(true)
    let userId = UserDefaults.standard.object(forKey: "userId") as! String
    
    getLocalUserSettings(userId)
      .then { promise -> Void in
        
        self.emailStatusIsUpdating(false)
        if promise == .Success {
          self.present(userEmailVC, animated: true, completion: nil)
        } else if promise == .Unauthorised {
          // SHOULD NEVER HAPPEN.
          // LOGOUT USER
          Utils.clearLocalUserData()
          let loginVC = self.storyboard!.instantiateViewController(withIdentifier: "loginPage")
          self.present(loginVC, animated: true, completion: nil)
        }
    }
  }
  
  /**
   Defines the ui of texts in fields regarding the values that passed. Handles empty and filled state.
   
   - Parameter label: label text
   - Parameter placeholderText: placeholder text
   
   */
  // FIXME: checkout how this and next function are used.
  func setInputFieldTextStyle(_ label: UILabel, placeholderText: String) {
    if label.text == "" {
      label.text = placeholderText
      label.font = IF_PLACEHOLDER_FONT
      label.textColor = CLR_MEDIUM_GRAY
    } else {
      label.font = IF_STANDARD_FONT
      label.textColor = CLR_DARK_GRAY
    }
  }
  
  /**
   Defines the ui of text views regarding the values that passed. Handles empty and filled state.
   
   - Parameter textView: label text
   - Parameter placeholderText: placeholder text
   
   */
  func setTextViewTextStyle(_ textView: UITextView, placeholderText: String) {
    if textView.text == "" {
      textView.text = placeholderText
      textView.font = IF_PLACEHOLDER_FONT
      textView.textColor = CLR_MEDIUM_GRAY
    } else {
      textView.font = IF_STANDARD_FONT
      textView.textColor = CLR_DARK_GRAY
    }
  }
  
  /**
   Hides email status icon and show spinner
   
   - Parameter isLoading: boolean that indicates if localUserSettings are loaded
   */
  func emailStatusIsUpdating(_ isUpdating: Bool) {
    self.emailStatusRefreshSpinner.isHidden = !isUpdating
    self.emailStatusIndication.isHidden = isUpdating
  }
  
  @IBAction func setLegalView(_ sender: UIButton) {
    switch sender {
    case legalTerms:
      legalPageToBeViewed = LegalPages.Terms
    case legalPrivacy:
      legalPageToBeViewed = LegalPages.Privacy
    default:
      legalPageToBeViewed = LegalPages.About
    }
  }
  
  /**
   Navigates user to rate this app
   */
  @IBAction func rateThisApp(_ sender: AnyObject) {
    UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id1055761534")!)
    
  }
  
  
}
