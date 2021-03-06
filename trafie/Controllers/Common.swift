//
//  Common.swift
//  trafie
//
//  Created by mathiou on 5/17/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import RealmSwift
import SwiftyJSON

// MARK: trafie base url
let dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "config", ofType: "plist")!) as? [String: AnyObject]

//let trafieURL = String(dict!["StagingUrl"]!)
let trafieURL = String(describing: dict!["ProductionUrl"]!)
//let trafieURL = "http://localhost:3000/"
//let trafieURL = "http://192.168.10.25:3000/"

// MARK: Constants
let EMPTY_STATE = "Nothing Here"
let MAX_NUMBER_OF_ACTIVITIES_BEFORE_VERIFIED = 5
let MAX_CHARS_NUMBER_IN_ABOUT = 400

// MARK: Variables for specific SESSION
/// Indicates if user is currently editing an activity
var isEditingActivity : Bool = false
/// ID of activity that is currently edited.
/// SHOULD BE cleared when dismiss edit activity view
var editingActivityID = ""
/// ID of activity that is curently viewed.
/// SHOULD BE cleared when dismiss edit activity view
var viewingActivityID = ""

/// The last time app fetched activities. Must follow YYYY-MM-DD format in order to conform with API
var lastFetchingActivitiesDate = ""
/// The logical calendar for current user.
let currentCalendar = Calendar.current
/// Date formatter object
let dateFormatter = DateFormatter()
/// Time formatter object
let timeFormatter = DateFormatter()

/// The name of the legal page that will be viewed. SHOULD BE cleared when dismiss web-view.
var legalPageToBeViewed : LegalPages = LegalPages.About

// MARK: Enumerations
/**
 Enumeration for common error messages
 
 - EmailAndPasswordAreRequired: Both Email and Password are required
 - AllFieldsAreRequired: All fields are required
 - InvalidEmail: Invalid email
 - InvalidCredentials: Invalid Credentials
 - RegistrationGeneralError: General Error in registration
 - PasswordAndRepeatPasswordShouldMatch: Password and Repeat Should match
 - FieldShouldBeLongerThanOneCharacter: Field should be longer than one character
 - ShortPassword: Password should at least 6 characters long
 - NoError: No error
 */
enum ErrorMessage: String {
  case EmailAndPasswordAreRequired = "Email and password are required."
  case AllFieldsAreRequired = "All fields are required."
  case InvalidEmail = "The email doesn't seem valid."
  case InvalidCredentials = "Invalid email or password."
  case GeneralError = "Something went wrong! Please try again."
  case EmailAlreadyExists = "This email already exists."
  case PasswordAndRepeatPasswordShouldMatch = "Passwords should match."
  case FieldLengthShouldBe2To35 = "Field should have 2 to 35 characters."
  case FieldShouldContainsOnlyAZDashQuotSpace = "Field should contains only characters A-Z \' -"
  case ShortPassword = "Password should at least 6 characters long."
  case YouAreNotConnectedToTheInternet = "You are not connected to the internet."
  case NoError = "NoError"
}

/**
 Enumeration for feedback types. Enum to String.
 
 - Bug: "bug"
 - FeatureRequest: "feature"
 - Comment: "comment"
 */
enum FeedbackType: String {
  case Bug = "bug"
  case FeatureRequest = "feature"
  case Comment = "comment"
}

/**
 Enumeration for measurement Units. Enum to String.
 
 - Meters: "meters"
 - Inches: "inches"
 */
enum MeasurementUnits: String {
  case Meters = "meters"
  case Feet = "feet"
}

/**
 Enumeration response messages. Enum to String.
 
 - Success: "Success"
 - Unauthorised: "Unauthorised"
 - InitialState: "InitialState"
 */
enum ResponseMessage: String {
  case Success = "Success"
  case Unauthorised = "Unauthorised"
  case InitialState = "InitialState"
}

/**
 Enumeration for response status codes. Enum to String.
 
 - _200: "2[0-9]{2}"
 - _422: "422"
 - _404: "404"
 */
enum StatusCodesRegex: String {
  case _200 = "2[0-9]{2}"
  case _422 = "422"
  case _404 = "404"
}

/**
 Enumeration of legal pages. Enum to String.
 
 - About = "about"
 - Terms = "terms-of-service"
 - Privacy = "privacy"
 */
enum LegalPages: String {
  case About = "about"
  case Terms = "terms-of-service"
  case Privacy = "privacy"
}

/**
 Enumeration for unit fractions. Enum to String.
 
 - Quarter = "??"
 - Half = "??"
 - ThreeFourths = "??"
 */
enum Fractions: String {
  case Quarter = "??"
  case Half = "??"
  case ThreeFourths = "??"
}

/**
 Enumeration for StatusBarNotification States. Enum to String.
 
 - Warning = "warning"
 - Error = "error"
 - Success = "success"
 - Info = "info"
 */
enum StatusBarNotificationState: String {
  case Warning = "warning"
  case Error = "error"
  case Success = "success"
  case Info = "info"
}

// MARK: Arrays
/// Array contains all available disciplines
let disciplinesAll = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running", "high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin", "pentathlon", "heptathlon", "decathlon"]

/// Array contains only disciplines that measured in time
let disciplinesTime = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running"]
/// Array contains only disciplines that measured in meters
let disciplinesDistance = ["high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin"]
/// Array contains only disciplines that measured in points
let disciplinesPoints = ["pentathlon", "heptathlon", "decathlon"]

/// Array contains all available countries (We need a map here for translations)
let countries = ["Afghanistan","Aland Islands","Albania","Algeria","American Samoa","Andorra","Angola","Anguilla","Antarctica","Antigua and Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia, Plurinational State of","Bonaire, Sint Eustatius and Saba","Bosnia and Herzegovina","Botswana","Bouvet Island","Brazil","British Indian Ocean Territory","Brunei Darussalam","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Cayman Islands","Central African Republic","Chad","Chile","China","Christmas Island","Cocos (Keeling) Islands","Colombia","Comoros","Congo","Congo, The Democratic Republic of the","Cook Islands","Costa Rica","Cote d\'Ivoire","Croatia","Cuba","Curacao","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Falkland Islands (Malvinas)","Faroe Islands","Fiji","Finland","France","French Guiana","French Polynesia","French Southern Territories","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guadeloupe","Guam","Guatemala","Guernsey","Guinea","Guinea-Bissau","Guyana","Haiti","Heard Island and McDonald Islands","Holy See (Vatican City State)","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran, Islamic Republic of","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kiribati","Korea, Democratic People\'s Republic of","Korea, Republic of","Kuwait","Kyrgyzstan","Lao People\'s Democratic Republic","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macao","Macedonia, The Former Yugoslav Republic of","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Martinique","Mauritania","Mauritius","Mayotte","Mexico","Micronesia, Federated States of","Moldova, Republic of","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Myanmar","Namibia","Nauru","Nepal","Netherlands","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Niue","Norfolk Island","Northern Mariana Islands","Norway","Oman","Pakistan","Palau","Palestine, State of","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Pitcairn","Poland","Portugal","Puerto rico","Qatar","Reunion","Romania","Russian Federation","Rwanda","Saint Barthelemy","Saint Helena, Ascension and Tristan da Cunha","Saint Kitts and Nevis","Saint Lucia","Saint Martin (French Part)","Saint Pierre and Miquelon","Saint Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Sint Maarten (Dutch Part)","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Georgia and the South Sandwich Islands","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Svalbard and Jan Mayen","Swaziland","Sweden","Switzerland","Syrian Arab Republic","Taiwan, Province of China","Tajikistan","Tanzania, United Republic of","Thailand","Timor-Leste","Togo","Tokelau","Tonga","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Turks and Caicos Islands","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States","United States Minor Outlying Islands","Uruguay","Uzbekistan","Vanuatu","Venezuela, Bolivarian Republic of","Vietnam","Virgin Islands, British","Virgin Islands, U.S.","Wallis and Futuna","Western Sahara","Yemen","Zambia","Zimbabwe"]
/// Array contains all available country codes.
let countriesShort = ["af", "ax", "al", "dz", "as", "ad", "ao", "ai", "aq", "ag", "ar", "am", "aw", "au", "at", "az", "bs", "bh", "bd", "bb", "by", "be", "bz", "bj", "bm", "bt", "bo", "bq", "ba", "bw", "bv", "br", "io", "bn", "bg", "bf", "bi", "kh", "cm", "ca", "cv", "ky", "cf", "td", "cl", "cn", "cx", "cc", "co", "km", "cg", "cd", "ck", "cr", "ci", "hr", "cu", "cw", "cy", "cz", "dk", "dj", "dm", "do", "ec", "eg", "sv", "gq", "er", "ee", "et", "fk", "fo", "fj", "fi", "fr", "gf", "pf", "tf", "ga", "gm", "ge", "de", "gh", "gi", "gr", "gl", "gd", "gp", "gu", "gt", "gg", "gn", "gw", "gy", "ht", "hm", "va", "hn", "hk", "hu", "is", "in", "id", "ir", "iq", "ie", "im", "il", "it", "jm", "jp", "je", "jo", "kz", "ke", "ki", "kp", "kr", "kw", "kg", "la", "lv", "lb", "ls", "lr", "ly", "li", "lt", "lu", "mo", "mk", "mg", "mw", "my", "mv", "ml", "mt", "mh", "mq", "mr", "mu", "yt", "mx", "fm", "md", "mc", "mn", "me", "ms", "ma", "mz", "mm", "na", "nr", "np", "nl", "nc", "nz", "ni", "ne", "ng", "nu", "nf", "mp", "no", "om", "pk", "pw", "ps", "pa", "pg", "py", "pe", "ph", "pn", "pl", "pt", "pr", "qa", "re", "ro", "ru", "rw", "bl", "sh", "kn", "lc", "mf", "pm", "vc", "ws", "sm", "st", "sa", "sn", "rs", "sc", "sl", "sg", "sx", "sk", "si", "sb", "so", "za", "gs", "ss", "es", "lk", "sd", "sr", "sj", "sz", "se", "ch", "sy", "tw", "tj", "tz", "th", "tl", "tg", "tk", "to", "tt", "tn", "tr", "tm", "tc", "tv", "ug", "ua", "ae", "gb", "us", "um", "uy", "uz", "vu", "ve", "vn", "vg", "vi", "wf", "eh", "ye", "zm", "zw"]

/**
 Promise-wrappper for getLocalUserSettings (see: APIHandler)
 
 - Parameter userId: The id of local user
 
 - Returns: Promise Object
 */
func getLocalUserSettings(_ userId: String) -> Promise<ResponseMessage> {
  return Promise { fulfill, reject in
    
    Utils.showNetworkActivityIndicatorVisible(true)
    ApiHandler.getUserById(userId: userId)
      .responseJSON { response in
        
        Utils.showNetworkActivityIndicatorVisible(false)
        if response.result.isSuccess {
          if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
            let user = JSON(response.result.value)
            Utils.log("\(user)")
            UserDefaults.standard.set(user["_id"].stringValue, forKey: "userId")
            UserDefaults.standard.set(user["firstName"].stringValue, forKey: "firstname")
            UserDefaults.standard.set(user["lastName"].stringValue, forKey: "lastname")
            UserDefaults.standard.set(user["about"].stringValue, forKey: "about")
            UserDefaults.standard.set(user["discipline"].stringValue, forKey: "mainDiscipline")
            UserDefaults.standard.set(user["isMale"].boolValue, forKey: "isMale")
            UserDefaults.standard.set(user["isVerified"].boolValue, forKey: "isVerified")
            UserDefaults.standard.set(user["isPrivate"].boolValue, forKey: "isPrivate")
            UserDefaults.standard.set(user["birthday"].stringValue, forKey: "birthday")
            UserDefaults.standard.set(user["country"].stringValue, forKey: "country")
            UserDefaults.standard.set(user["email"].stringValue, forKey: "email")
            UserDefaults.standard.set(user["picture"].stringValue, forKey: "profilePicture")
            UserDefaults.standard.set(user["units"]["distance"].stringValue, forKey: "measurementUnitsDistance")
            
            
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "reloadProfile"), object: nil)
            fulfill(.Success)
          }
        } else if response.result.isFailure {
          Utils.log("Request failed with error: \(response.result.error)")
          
          if let data = response.data {
            Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
          }
          fulfill(.Unauthorised)
        }
        
    }
    
  }
}

// MARK: Regular Expressions and Validators
/// Regex for Character A-Z, 2 to 20 characters
let REGEX_AZ_2TO20_CHARS = "^[a-zA-Z]{2,20}$"
/// Regex for Character A-Z' -, 2 to 35 characters
let REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS = "^[a-zA-Z\' -]{2,35}$"
/// Regex for email
let REGEX_EMAIL = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" //email
/// Validator for email
let emailValidator = NSPredicate(format:"SELF MATCHES %@", REGEX_EMAIL)
