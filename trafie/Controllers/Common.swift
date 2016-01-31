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
//let trafieURL = "http://trafie.herokuapp.com/" //heroku SHOULD MOVE TO .PLIST
let trafieURL = "http://localhost:3000/" //local
//let trafieURL = "http://192.168.10.11:3000/" //local from mobile

// MARK: Constants
let EMPTY_STATE = "Please select discipline first"

// MARK: Variables for specific SESSION
var isEditingActivity : Bool = false
var editingActivityID : String = "" // TODO: clear this value when dismiss edit activity view
var viewingActivityID : String = "" // TODO: clear this value when dismiss activity view

// Stores the IDs of all our activities
var activitiesIdTable : [String] = []
//sections in activities view related
var sectionsOfActivities = Dictionary<String, Array<Activity>>()
var sortedSections = [String]()
var lastFetchingActivitiesDate: String = "" // must follow YYYY-MM-DD format in order to conform with API


// MARK: Enumerations
enum ErrorMessage: String {
    case EmailAndPasswordAreRequired = "Email and password are required."
    case AllFieldsAreRequired = "All fields are required."
    case InvalidEmail = "The email doesn't seem valid."
    case InvalidCredentials = "Invalid email or password."
    case RegistrationGeneralError = "Ooops! Error! Please try again."
    case PasswordAndRepeatPasswordShouldMatch = "Passwords should match."
    case NoError = "NoError"
}

enum ResponseMessage: String {
    case Success = "Success"
    case Unauthorised = "Unauthorised"
    case InitialState = "InitialState"
}

// MARK: Arrays
// all disciplines
let disciplinesAll = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running", "high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin", "pentathlon", "heptathlon", "decathlon"]

// categories of disciplines
let disciplinesTime = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running"]
let disciplinesDistance = ["high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin"]
let disciplinesPoints = ["pentathlon", "heptathlon", "decathlon"]

// countries (We need a map here for translations)
let countries = ["Aghanistan","Aland Islands","Albania","Algeria","American Samoa","Andorra","Angola","Anguilla","Antarctica","Antigua and Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia, Plurinational State of","Bonaire, Sint Eustatius and Saba","Bosnia and Herzegovina","Botswana","Bouvet Island","Brazil","British Indian Ocean Territory","Brunei Darussalam","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Cayman Islands","Central African Republic","Chad","Chile","China","Christmas Island","Cocos (Keeling) Islands","Colombia","Comoros","Congo","Congo, The Democratic Republic of the","Cook Islands","Costa Rica","Cote d\'Ivoire","Croatia","Cuba","Curacao","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Falkland Islands (Malvinas)","Faroe Islands","Fiji","Finland","France","French Guiana","French Polynesia","French Southern Territories","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guadeloupe","Guam","Guatemala","Guernsey","Guinea","Guinea-Bissau","Guyana","Haiti","Heard Island and McDonald Islands","Holy See (Vatican City State)","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran, Islamic Republic of","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kiribati","Korea, Democratic People\'s Republic of","Korea, Republic of","Kuwait","Kyrgyzstan","Lao People\'s Democratic Republic","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macao","Macedonia, The Former Yugoslav Republic of","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Martinique","Mauritania","Mauritius","Mayotte","Mexico","Micronesia, Federated States of","Moldova, Republic of","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Myanmar","Namibia","Nauru","Nepal","Netherlands","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Niue","Norfolk Island","Northern Mariana Islands","Norway","Oman","Pakistan","Palau","Palestine, State of","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Pitcairn","Poland","Portugal","Puerto rico","Qatar","Reunion","Romania","Russian Federation","Rwanda","Saint Barthelemy","Saint Helena, Ascension and Tristan da Cunha","Saint Kitts and Nevis","Saint Lucia","Saint Martin (French Part)","Saint Pierre and Miquelon","Saint Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Sint Maarten (Dutch Part)","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Georgia and the South Sandwich Islands","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Svalbard and Jan Mayen","Swaziland","Sweden","Switzerland","Syrian Arab Republic","Taiwan, Province of China","Tajikistan","Tanzania, United Republic of","Thailand","Timor-Leste","Togo","Tokelau","Tonga","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Turks and Caicos Islands","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States","United States Minor Outlying Islands","Uruguay","Uzbekistan","Vanuatu","Venezuela, Bolivarian Republic of","Vietnam","Virgin Islands, British","Virgin Islands, U.S.","Wallis and Futuna","Western Sahara","Yemen","Zambia","Zimbabwe"]
let countriesShort = ["af", "ax", "al", "dz", "as", "ad", "ao", "ai", "aq", "ag", "ar", "am", "aw", "au", "at", "az", "bs", "bh", "bd", "bb", "by", "be", "bz", "bj", "bm", "bt", "bo", "bq", "ba", "bw", "bv", "br", "io", "bn", "bg", "bf", "bi", "kh", "cm", "ca", "cv", "ky", "cf", "td", "cl", "cn", "cx", "cc", "co", "km", "cg", "cd", "ck", "cr", "ci", "hr", "cu", "cw", "cy", "cz", "dk", "dj", "dm", "do", "ec", "eg", "sv", "gq", "er", "ee", "et", "fk", "fo", "fj", "fi", "fr", "gf", "pf", "tf", "ga", "gm", "ge", "de", "gh", "gi", "gr", "gl", "gd", "gp", "gu", "gt", "gg", "gn", "gw", "gy", "ht", "hm", "va", "hn", "hk", "hu", "is", "in", "id", "ir", "iq", "ie", "im", "il", "it", "jm", "jp", "je", "jo", "kz", "ke", "ki", "kp", "kr", "kw", "kg", "la", "lv", "lb", "ls", "lr", "ly", "li", "lt", "lu", "mo", "mk", "mg", "mw", "my", "mv", "ml", "mt", "mh", "mq", "mr", "mu", "yt", "mx", "fm", "md", "mc", "mn", "me", "ms", "ma", "mz", "mm", "na", "nr", "np", "nl", "nc", "nz", "ni", "ne", "ng", "nu", "nf", "mp", "no", "om", "pk", "pw", "ps", "pa", "pg", "py", "pe", "ph", "pn", "pl", "pt", "pr", "qa", "re", "ro", "ru", "rw", "bl", "sh", "kn", "lc", "mf", "pm", "vc", "ws", "sm", "st", "sa", "sn", "rs", "sc", "sl", "sg", "sx", "sk", "si", "sb", "so", "za", "gs", "ss", "es", "lk", "sd", "sr", "sj", "sz", "se", "ch", "sy", "tw", "tj", "tz", "th", "tl", "tg", "tk", "to", "tt", "tn", "tr", "tm", "tc", "tv", "ug", "ua", "ae", "gb", "us", "um", "uy", "uz", "vu", "ve", "vn", "vg", "vi", "wf", "eh", "ye", "zm", "zw"]

// MARK:- Functions
// MARK: App Initialization
func validateInitValuesOfProfile() {
    if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "token")
    }

    if NSUserDefaults.standardUserDefaults().objectForKey("userId") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "userId")
    }

    if NSUserDefaults.standardUserDefaults().objectForKey("firstname") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "firstname")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("lastname") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "lastname")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("about") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "about")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "mainDiscipline")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("isPrivate") == nil {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isPrivate")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("isMale") == nil {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isMale")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("birthday") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "birthday")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("country") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "country")
    }
    log("Completed")
}

func resetValuesOfProfile() {
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "token")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "userId")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "firstname")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "lastname")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "about")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "mainDiscipline")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isPrivate")
    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isMale")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "birthday")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "country")
    log("Completed")
}

// Promise for getLocalUserSettings
func getLocalUserSettings(userId: String) -> Promise<ResponseMessage> {
    return Promise { fulfill, reject in
        ApiHandler.getUserById(userId)
            .responseJSON { request, response, result in
                switch result {
                case .Success(let JSONResponse):
                    log("\(JSONResponse)")
                    let user = JSON(JSONResponse)
                    NSUserDefaults.standardUserDefaults().setObject(user["_id"].stringValue, forKey: "userId")
                    NSUserDefaults.standardUserDefaults().setObject(user["firstName"].stringValue, forKey: "firstname")
                    NSUserDefaults.standardUserDefaults().setObject(user["lastName"].stringValue, forKey: "lastname")
                    NSUserDefaults.standardUserDefaults().setObject(user["about"].stringValue, forKey: "about")
                    NSUserDefaults.standardUserDefaults().setObject(user["discipline"].stringValue, forKey: "mainDiscipline")
                    NSUserDefaults.standardUserDefaults().setObject(user["isMale"].bool, forKey: "isMale")
                    NSUserDefaults.standardUserDefaults().setObject(user["birthday"].stringValue, forKey: "birthday")
                    NSUserDefaults.standardUserDefaults().setObject(user["country"].stringValue, forKey: "country")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                    fulfill(.Success)
                case .Failure(let data, let error):
                    log("Request failed with error: \(error)")
                    if let data = data {
                        log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                    fulfill(.Unauthorised)
                }
        }

    }
}

// MARK: Activities Array Helper Functions
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


func addActivity(activity: Activity, section: String) {
    if activitiesIdTable.contains(activity.getActivityId()) {
        // TODO: Optimize to break the loop when the item found
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

func removeActivity(activity: Activity, section: String) {
    for var i = 0; i < sectionsOfActivities[section]?.count; i++ {
        if sectionsOfActivities[section]![i].getActivityId() == activity.getActivityId() {
            sectionsOfActivities[section]!.removeAtIndex(i)
        }
    }
    if sectionsOfActivities[section]?.count == 0 {
        sectionsOfActivities.removeValueForKey(section)
    }
    //sort sections
    sortedSections = sectionsOfActivities.keys.sort(>)
}


func cleanSectionsOfActivities() {
    sectionsOfActivities = Dictionary<String, Array<Activity>>()
    sortedSections = [String]()
}

// MARK: Pickers and Ranges
func createIntRangeArray(from: Int, to: Int, addZeros: Bool?=true) -> [String] {
    var array: [String] = []
    for index in from..<to {
        // add zero in front of one-digit numbers
        let value : String = ((addZeros! == true)  && (index < 10)) ? String(format: "%02d", index) : String(index)
        array.append(value)
    }
    return array
}

func getPerformanceLimitationsPerDiscipline(discipline: String) -> [[String]] {
    switch discipline {
        //distance disciplines
    case "high_jump":
        return [createIntRangeArray(1, to: 3, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "long_jump":
        return [createIntRangeArray(0, to: 10, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "triple_jump":
        return [createIntRangeArray(0, to: 19, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "pole_vault":
        return [createIntRangeArray(0, to: 7, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "shot_put":
        return [createIntRangeArray(0, to: 24, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "discus":
        return [createIntRangeArray(0, to: 75, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "hammer":
        return [createIntRangeArray(0, to: 88, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
    case "javelin":
        return [createIntRangeArray(0, to: 99, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
        //time disciplines
    case "60m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "100m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "200m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "400m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "800m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "1500m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "3000m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "5000m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "10000m":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "60m_hurdles":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "100m_hurdles":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "110m_hurdles":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "400m_hurdles":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "3000m_steeplechase":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "4x100m_relay":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "4x400m_relay":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "half_marathon":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "marathon":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "20km_race_walk":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "50km_race_walk":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
    case "cross_country_running":
        return [createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        //points disciplines
    case "pentathlon":
        return [createIntRangeArray(0, to: 7, addZeros: false), ["."], createIntRangeArray(0, to: 10, addZeros: false), createIntRangeArray(0, to: 10, addZeros: false), createIntRangeArray(0, to: 10, addZeros: false)]
    case "heptathlon":
        return [createIntRangeArray(0, to: 7, addZeros: false), ["."], createIntRangeArray(0, to: 10, addZeros: false), createIntRangeArray(0, to: 10, addZeros: false), createIntRangeArray(0, to: 10, addZeros: false)]
    case "decathlon":
        return [createIntRangeArray(0, to: 10, addZeros: false), ["."], createIntRangeArray(0, to: 10, addZeros: false), createIntRangeArray(0, to: 10, addZeros: false), createIntRangeArray(0, to: 10, addZeros: false)]
    default:
         return [[EMPTY_STATE]]
    }

}

// MARK: Calculation Functions
func convertPerformanceToReadable(performance: String, discipline: String) -> String {
    var readable : String = ""
    let performanceInt : Int = Int(performance)!
    
    //Time
    if disciplinesTime.contains(discipline) {
        let centisecs = (performanceInt % 100)
        let secs = ((performanceInt) % 6000) / 100
        let mins = (performanceInt % 360000) / 6000
        let hours = (performanceInt - secs - mins - centisecs) / 360000
        
        //fill with zeros if needed
        var  minsPart : String = "00:"
        var  secsPart : String = "00:"
        if mins != 0 {
            minsPart = mins < 10 ? "0\(String(mins)):" : "\(String(mins)):"
        }
        if secs != 0 {
            secsPart = secs < 10 ? "0\(String(secs))." : "\(String(secs))."
        }
        
        readable  = secsPart + "\(String(centisecs))"
        
        if hours != 0 {
            readable = "\(String(hours)):" + minsPart + readable
        } else {
            if mins != 0 {
                readable = minsPart + readable
            }
        }

        return readable
    // Distance
    } else if disciplinesDistance.contains(discipline) {
        let centimeters = (performanceInt % 10000) / 100
        let meters = (performanceInt - centimeters) / 10000
        
        readable = centimeters < 10 ? "\(String(meters)).0\(String(centimeters))" : "\(String(meters)).\(String(centimeters))"
        
        return readable
    // Points
    } else if disciplinesPoints.contains(discipline){
        let hundreds = (performanceInt % 1000)
        let thousand = (performanceInt - hundreds) / 1000
        var readable : String = ""
        var zerosForHundred = ""

        if hundreds < 100 && hundreds > 10 {
            zerosForHundred = "0"
        } else if hundreds < 10 {
            zerosForHundred = "00"
        }
        
        readable = "\(String(thousand)).\(zerosForHundred+String(hundreds))" //10.045
        return readable
    }
    
    return performance
}

// MARK: Connections related
func initConnectionMsgInNavigationPrompt(navigationItem: UINavigationItem) {
    let status = Reach().connectionStatus()
    switch status {
    case .Unknown, .Offline:
        log("Not connected")
        navigationItem.prompt = "You are offline"
    case .Online(.WWAN):
        log("Connected via WWAN")
        clearInformMessageForConnection(navigationItem)
    case .Online(.WiFi):
        log("Connected via WiFi")
        clearInformMessageForConnection(navigationItem)
    }
}

func clearInformMessageForConnection(navigationItem: UINavigationItem) {
    navigationItem.prompt = nil
}

// MARK: Regular Expressions and Validators
let REGEX_AZ_2TO20_CHARS = "^[a-zA-Z]{2,20}$"    // Character A-Z, 2 to 20 characters
let REGEX_AZ_2TO35_DASH_QUOT_SPACE_CHARS = "^[a-zA-Z\' -]{2,35}$"    // Character A-Z, 2 to 35 characters
let REGEX_EMAIL = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" //email
let REGEX_STATUS_CODE_200 = "2[0-9]{2}"
let REGEX_STATUS_CODE_422 = "422"

let emailValidator = NSPredicate(format:"SELF MATCHES %@", REGEX_EMAIL)
let statusCode200 = NSPredicate(format:"SELF MATCHES %@", REGEX_STATUS_CODE_200)
let statusCode422 = NSPredicate(format:"SELF MATCHES %@", REGEX_STATUS_CODE_422)

// MARK: Logging
func log(logMessage: String, functionName: String = __FUNCTION__, lineNum: Int = __LINE__) {
    print("\(NSDate()) : [\(functionName)] \(logMessage) : \(lineNum)")
}