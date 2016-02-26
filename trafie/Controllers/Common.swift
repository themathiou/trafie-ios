//
//  Common.swift
//  trafie
//
//  Created by mathiou on 5/17/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import PromiseKit

// MARK: trafie base url
// let trafieURL = "https://www.trafie.com/" //heroku SHOULD MOVE TO .PLIST
 let trafieURL = "http://localhost:3000/" //local
// let trafieURL = "http://192.168.10.38:3000/" //local from mobile

// MARK: Constants
let EMPTY_STATE = "Please select discipline first"

// MARK: Variables for specific SESSION
/// Indicates if user is currently editing an activity
var isEditingActivity : Bool = false
/// ID of activity that is currently edited.
/// SHOULD BE cleared when dismiss edit activity view
var editingActivityID : String = ""
/// ID of activity that is curently viewed.
/// SHOULD BE cleared when dismiss edit activity view
var viewingActivityID : String = ""

/// Stores the IDs of all our activities
var activitiesIdTable : [String] = []
/// Sections in activities view : Dictionary<String, Array<Activity>>()
var sectionsOfActivities = Dictionary<String, Array<Activity>>()
/// The sorted sections
var sortedSections = [String]()
/// The last time app fetched activities. Must follow YYYY-MM-DD format in order to conform with API
var lastFetchingActivitiesDate: String = ""
/// The logical calendar for current user.
let currentCalendar = NSCalendar.currentCalendar()
/// Date formatter object
let dateFormatter = NSDateFormatter()
/// Time formatter object
let timeFormatter = NSDateFormatter()



// MARK: Enumerations
/**
 Enumeration for common error messages

 - EmailAndPasswordAreRequired: Both Email and Password are required
 - AllFieldsAreRequired: All fields are required
 - InvalidEmail: Invalid email
 - InvalidCredentials: Invalid Credentials
 - RegistrationGeneralError: General Error in registration
 - PasswordAndRepeatPasswordShouldMatch: Password and Repeat Should match
 - NoError: No error
*/
enum ErrorMessage: String {
    case EmailAndPasswordAreRequired = "Email and password are required."
    case AllFieldsAreRequired = "All fields are required."
    case InvalidEmail = "The email doesn't seem valid."
    case InvalidCredentials = "Invalid email or password."
    case RegistrationGeneralError = "Ooops! Error! Please try again."
    case PasswordAndRepeatPasswordShouldMatch = "Passwords should match."
    case NoError = "NoError"
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
let countries = ["Aghanistan","Aland Islands","Albania","Algeria","American Samoa","Andorra","Angola","Anguilla","Antarctica","Antigua and Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia, Plurinational State of","Bonaire, Sint Eustatius and Saba","Bosnia and Herzegovina","Botswana","Bouvet Island","Brazil","British Indian Ocean Territory","Brunei Darussalam","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Cayman Islands","Central African Republic","Chad","Chile","China","Christmas Island","Cocos (Keeling) Islands","Colombia","Comoros","Congo","Congo, The Democratic Republic of the","Cook Islands","Costa Rica","Cote d\'Ivoire","Croatia","Cuba","Curacao","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Falkland Islands (Malvinas)","Faroe Islands","Fiji","Finland","France","French Guiana","French Polynesia","French Southern Territories","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guadeloupe","Guam","Guatemala","Guernsey","Guinea","Guinea-Bissau","Guyana","Haiti","Heard Island and McDonald Islands","Holy See (Vatican City State)","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran, Islamic Republic of","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kiribati","Korea, Democratic People\'s Republic of","Korea, Republic of","Kuwait","Kyrgyzstan","Lao People\'s Democratic Republic","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macao","Macedonia, The Former Yugoslav Republic of","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Martinique","Mauritania","Mauritius","Mayotte","Mexico","Micronesia, Federated States of","Moldova, Republic of","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Myanmar","Namibia","Nauru","Nepal","Netherlands","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Niue","Norfolk Island","Northern Mariana Islands","Norway","Oman","Pakistan","Palau","Palestine, State of","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Pitcairn","Poland","Portugal","Puerto rico","Qatar","Reunion","Romania","Russian Federation","Rwanda","Saint Barthelemy","Saint Helena, Ascension and Tristan da Cunha","Saint Kitts and Nevis","Saint Lucia","Saint Martin (French Part)","Saint Pierre and Miquelon","Saint Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Sint Maarten (Dutch Part)","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Georgia and the South Sandwich Islands","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Svalbard and Jan Mayen","Swaziland","Sweden","Switzerland","Syrian Arab Republic","Taiwan, Province of China","Tajikistan","Tanzania, United Republic of","Thailand","Timor-Leste","Togo","Tokelau","Tonga","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Turks and Caicos Islands","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States","United States Minor Outlying Islands","Uruguay","Uzbekistan","Vanuatu","Venezuela, Bolivarian Republic of","Vietnam","Virgin Islands, British","Virgin Islands, U.S.","Wallis and Futuna","Western Sahara","Yemen","Zambia","Zimbabwe"]
/// Array contains all available country codes.
let countriesShort = ["af", "ax", "al", "dz", "as", "ad", "ao", "ai", "aq", "ag", "ar", "am", "aw", "au", "at", "az", "bs", "bh", "bd", "bb", "by", "be", "bz", "bj", "bm", "bt", "bo", "bq", "ba", "bw", "bv", "br", "io", "bn", "bg", "bf", "bi", "kh", "cm", "ca", "cv", "ky", "cf", "td", "cl", "cn", "cx", "cc", "co", "km", "cg", "cd", "ck", "cr", "ci", "hr", "cu", "cw", "cy", "cz", "dk", "dj", "dm", "do", "ec", "eg", "sv", "gq", "er", "ee", "et", "fk", "fo", "fj", "fi", "fr", "gf", "pf", "tf", "ga", "gm", "ge", "de", "gh", "gi", "gr", "gl", "gd", "gp", "gu", "gt", "gg", "gn", "gw", "gy", "ht", "hm", "va", "hn", "hk", "hu", "is", "in", "id", "ir", "iq", "ie", "im", "il", "it", "jm", "jp", "je", "jo", "kz", "ke", "ki", "kp", "kr", "kw", "kg", "la", "lv", "lb", "ls", "lr", "ly", "li", "lt", "lu", "mo", "mk", "mg", "mw", "my", "mv", "ml", "mt", "mh", "mq", "mr", "mu", "yt", "mx", "fm", "md", "mc", "mn", "me", "ms", "ma", "mz", "mm", "na", "nr", "np", "nl", "nc", "nz", "ni", "ne", "ng", "nu", "nf", "mp", "no", "om", "pk", "pw", "ps", "pa", "pg", "py", "pe", "ph", "pn", "pl", "pt", "pr", "qa", "re", "ro", "ru", "rw", "bl", "sh", "kn", "lc", "mf", "pm", "vc", "ws", "sm", "st", "sa", "sn", "rs", "sc", "sl", "sg", "sx", "sk", "si", "sb", "so", "za", "gs", "ss", "es", "lk", "sd", "sr", "sj", "sz", "se", "ch", "sy", "tw", "tj", "tz", "th", "tl", "tg", "tk", "to", "tt", "tn", "tr", "tm", "tc", "tv", "ug", "ua", "ae", "gb", "us", "um", "uy", "uz", "vu", "ve", "vn", "vg", "vi", "wf", "eh", "ye", "zm", "zw"]

/**
 Promise-wrappper for getLocalUserSettings (see: APIHandler)

 - Parameter userId: The id of local user

 - Returns: Promise Object
*/
func getLocalUserSettings(userId: String) -> Promise<ResponseMessage> {
    return Promise { fulfill, reject in
        ApiHandler.getUserById(userId)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let JSONResponse):
                    if statusCode200.evaluateWithObject(String((response?.statusCode)!)) {
                        Utils.log("\(JSONResponse)")
                        let user = JSON(JSONResponse)
                        NSUserDefaults.standardUserDefaults().setObject(user["_id"].stringValue, forKey: "userId")
                        NSUserDefaults.standardUserDefaults().setObject(user["firstName"].stringValue, forKey: "firstname")
                        NSUserDefaults.standardUserDefaults().setObject(user["lastName"].stringValue, forKey: "lastname")
                        NSUserDefaults.standardUserDefaults().setObject(user["about"].stringValue, forKey: "about")
                        NSUserDefaults.standardUserDefaults().setObject(user["discipline"].stringValue, forKey: "mainDiscipline")
                        NSUserDefaults.standardUserDefaults().setObject(user["isMale"].bool, forKey: "isMale")
                        NSUserDefaults.standardUserDefaults().setObject(user["isValid"].bool, forKey: "isValid")
                        NSUserDefaults.standardUserDefaults().setObject(user["birthday"].stringValue, forKey: "birthday")
                        NSUserDefaults.standardUserDefaults().setObject(user["country"].stringValue, forKey: "country")
                        NSUserDefaults.standardUserDefaults().setObject(user["email"].stringValue, forKey: "email")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                        fulfill(.Success)
                    }
                case .Failure(let data, let error):
                    Utils.log("Request failed with error: \(error)")

                    if let data = data {
                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                    fulfill(.Unauthorised)
                }
        }

    }
}

// MARK: Activities Array Helper Functions
/**
 Gets an activity from activities array, based on its id.

 - Parameter activityId: The id of activity

 - Returns: Activity object
*/
func getActivityFromActivitiesArrayById(activityId: String) -> Activity {
    for (_, activities) in sectionsOfActivities {
        for activity in activities{
            if let tempActivity : Activity = activity {
                if tempActivity.getActivityId() == activityId {
                    return tempActivity
                }
            }
        }
    }
    return Activity() //empty activity
}

/**
 Adds an activity in actitities array
 
 - Parameter activity: The activity
 - Parameter section: The section in which we want to add the activity. Section defined by year of activity.
*/
func addActivity(activity: Activity, section: String) {
    if activitiesIdTable.contains(activity.getActivityId()) {
        for section in sectionsOfActivities.keys {
            removeActivity(activity, section: section)
        }
    }
    
    // sections doesn't exist
    if sectionsOfActivities.indexForKey(section) == nil {
        sectionsOfActivities[section] = [activity]
        //sort activities
        sectionsOfActivities[section]!.sortInPlace({$0.date.compare($1.date) == .OrderedDescending})
    }
    else {
        sectionsOfActivities[section]!.append(activity)
        //sort activities
        sectionsOfActivities[section]!.sortInPlace({$0.date.compare($1.date) == .OrderedDescending})
    }
    activitiesIdTable.append(activity.getActivityId())
    //sort sections
    sortedSections = sectionsOfActivities.keys.sort(>)
}

/**
 Removes an activity from actitities array
 
 - Parameter activity: The activity
 - Parameter section: The section from which we want to remove the activity. Section defined by year of activity.
*/
func removeActivity(activity: Activity, section: String) {
    for var i = 0; i < sectionsOfActivities[section]?.count; i++ {
        if sectionsOfActivities[section]![i].getActivityId() == activity.getActivityId() {
            sectionsOfActivities[section]!.removeAtIndex(i)
            break
        }
    }
    if sectionsOfActivities[section]?.count == 0 {
        sectionsOfActivities.removeValueForKey(section)
    }
    //sort sections
    sortedSections = sectionsOfActivities.keys.sort(>)
}

/**
 Clean up the activities arrays.
*/
func cleanSectionsOfActivities() {
    sectionsOfActivities = Dictionary<String, Array<Activity>>()
    sortedSections = [String]()
}

// MARK: Regular Expressions and Validators
/// Regex for Character A-Z, 2 to 20 characters
let REGEX_AZ_2TO20_CHARS = "^[a-zA-Z]{2,20}$"
/// Regex for Character A-Z, 2 to 35 characters
let REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS = "^[a-zA-Z\' -]{2,35}$"
/// Regex for email
let REGEX_EMAIL = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" //email
/// Regex for Status Code 2XX
let REGEX_STATUS_CODE_200 = "2[0-9]{2}"
/// Regex for Status Code 422
let REGEX_STATUS_CODE_422 = "422"
/// Regex for Status Code 404
let REGEX_STATUS_CODE_404 = "404"
/// Validator for email
let emailValidator = NSPredicate(format:"SELF MATCHES %@", REGEX_EMAIL)
/// Validator for status code 200
let statusCode200 = NSPredicate(format:"SELF MATCHES %@", REGEX_STATUS_CODE_200)
/// Validator for status code 404
let statusCode404 = NSPredicate(format:"SELF MATCHES %@", REGEX_STATUS_CODE_404)
/// Validator for status code 422
let statusCode422 = NSPredicate(format:"SELF MATCHES %@", REGEX_STATUS_CODE_422)
