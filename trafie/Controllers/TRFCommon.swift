//
//  TRFCommon.swift
//  trafie
//
//  Created by mathiou on 5/17/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: trafie base url
let trafieURL = "http://trafie.herokuapp.com/" //heroku
//let trafieURL = "http://localhost:3000/" //local
//let trafieURL = "http://192.168.10.11:3000/" //local from mobile


// MARK: Constants
let EMPTY_STATE = "Please select discipline first"

// MARK: Variables
var isEditingActivity : Bool = false
var editingActivityID : String = ""
//section related
var sectionsOfActivities = Dictionary<String, Array<TRFActivity>>()
var sortedSections = [String]()


// MARK: Enumerations
enum ErrorType {
    case OnlyDigitsErrorType
    case IncorrectLengthErrorType
    case NoErrorErrorType
    case NoSuchAppErrorType
    case NoInternetErrorType
    case NoResponseErrorType
}

enum gender {
    case Male
    case Female
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
let countriesShort = ["AF", "AX", "AL", "DZ", "AS", "AD", "AO", "AI", "AQ", "AG", "AR", "AM", "AW", "AU", "AT", "AZ", "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM", "BT", "BO", "BQ", "BA", "BW", "BV", "BR", "IO", "BN", "BG", "BF", "BI", "KH", "CM", "CA", "CV", "KY", "CF", "TD", "CL", "CN", "CX", "CC", "CO", "KM", "CG", "CD", "CK", "CR", "CI", "HR", "CU", "CW", "CY", "CZ", "DK", "DJ", "DM", "DO", "EC", "EG", "SV", "GQ", "ER", "EE", "ET", "FK", "FO", "FJ", "FI", "FR", "GF", "PF", "TF", "GA", "GM", "GE", "DE", "GH", "GI", "GR", "GL", "GD", "GP", "GU", "GT", "GG", "GN", "GW", "GY", "HT", "HM", "VA", "HN", "HK", "HU", "IS", "IN", "ID", "IR", "IQ", "IE", "IM", "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KP", "KR", "KW", "KG", "LA", "LV", "LB", "LS", "LR", "LY", "LI", "LT", "LU", "MO", "MK", "MG", "MW", "MY", "MV", "ML", "MT", "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MD", "MC", "MN", "ME", "MS", "MA", "MZ", "MM", "NA", "NR", "NP", "NL", "NC", "NZ", "NI", "NE", "NG", "NU", "NF", "MP", "NO", "OM", "PK", "PW", "PS", "PA", "PG", "PY", "PE", "PH", "PN", "PL", "PT", "PR", "QA", "RE", "RO", "RU", "RW", "BL", "SH", "KN", "LC", "MF", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SL", "SG", "SX", "SK", "SI", "SB", "SO", "ZA", "GS", "SS", "ES", "LK", "SD", "SR", "SJ", "SZ", "SE", "CH", "SY", "TW", "TJ", "TZ", "TH", "TL", "TG", "TK", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UG", "UA", "AE", "GB", "US", "UM", "UY", "UZ", "VU", "VE", "VN", "VG", "VI", "WF", "EH", "YE", "ZM", "ZW"]

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
    
    if NSUserDefaults.standardUserDefaults().objectForKey("gender") == nil {
        NSUserDefaults.standardUserDefaults().setObject("male", forKey: "gender")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("birthday") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "birthday")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("country") == nil {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "country")
    }
}

func resetValuesOfProfile() {
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "token")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "userId")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "firstname")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "lastname")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "about")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "mainDiscipline")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isPrivate")
    NSUserDefaults.standardUserDefaults().setObject("male", forKey: "gender")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "birthday")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "country")
}

// get user settings and set allNSDefaultValues based on these
func getLocalUserSettings() {
    TRFApiHandler.getLocalUserSettings()
        .responseJSON { request, response, result in
            print("--- getUserById() ---")
            switch result {
            case .Success(let JSONResponse):
                print(JSONResponse, terminator: "")
                let jsonRes = JSON(JSONResponse)
                let user = jsonRes["user"]
                NSUserDefaults.standardUserDefaults().setObject(user["firstName"].stringValue, forKey: "firstname")
                NSUserDefaults.standardUserDefaults().setObject(user["lastName"].stringValue, forKey: "lastname")
                NSUserDefaults.standardUserDefaults().setObject(user["about"].stringValue, forKey: "about")
                NSUserDefaults.standardUserDefaults().setObject(user["discipline"].stringValue, forKey: "mainDiscipline")
                NSUserDefaults.standardUserDefaults().setObject(user["gender"].stringValue, forKey: "gender")
                NSUserDefaults.standardUserDefaults().setObject("\(user["birthday"]["year"].stringValue)/\(user["birthday"]["month"].stringValue)/\(user["birthday"]["day"].stringValue)", forKey: "birthday")
                let country = NSLocalizedString(user["country"].stringValue, comment:"translation of discipline \(user["country"].stringValue)")
                NSUserDefaults.standardUserDefaults().setObject(country, forKey: "country")
                
            case .Failure(let data, let error):
                print("Request failed with error: \(error)")
                if let data = data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
    }
}

// MARK: Helpers
func getActivityFromActivitiesArrayById(activityId: String) -> TRFActivity {
    for (_, activities) in sectionsOfActivities {
        for activity in activities{
            if let tempActivity : TRFActivity = activity {
                if tempActivity.getActivityId() == activityId {
                    return tempActivity
                }
            }
        }
    }
    return TRFActivity() //empty activity
}

// MARK: Pickers and Ranges
func createIntRangeArray(from: Int, to: Int, addZeros: Bool?=false) -> [String] {
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
        return [createIntRangeArray(1, to: 3), ["."], createIntRangeArray(0, to: 100)]
    case "long_jump":
        return [createIntRangeArray(0, to: 10), ["."], createIntRangeArray(0, to: 100)]
    case "triple_jump":
        return [createIntRangeArray(0, to: 19), ["."], createIntRangeArray(0, to: 100)]
    case "pole_vault":
        return [createIntRangeArray(0, to: 7), ["."], createIntRangeArray(0, to: 100)]
    case "shot_put":
        return [createIntRangeArray(0, to: 24), ["."], createIntRangeArray(0, to: 100)]
    case "discus":
        return [createIntRangeArray(0, to: 75), ["."], createIntRangeArray(0, to: 100)]
    case "hammer":
        return [createIntRangeArray(0, to: 88), ["."], createIntRangeArray(0, to: 100)]
    case "javelin":
        return [createIntRangeArray(0, to: 100), ["."], createIntRangeArray(0, to: 100)]
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
        return [createIntRangeArray(0, to: 7), ["."], createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10)]
    case "heptathlon":
        return [createIntRangeArray(0, to: 7), ["."], createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10)]
    case "decathlon":
        return [createIntRangeArray(0, to: 10), ["."], createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10)]
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
        
        readable  = "\(String(hours)):\(String(mins)):\(String(secs)).\(String(centisecs))"
        return readable
    // Distance
    } else if disciplinesDistance.contains(discipline) {
        let centimeters = (performanceInt % 10000) / 100
        let meters = (performanceInt - centimeters) / 10000
        
        if centimeters < 10 {
            readable = "\(String(meters)).0\(String(centimeters))"
        } else {
            readable = "\(String(meters)).\(String(centimeters))"
        }
        
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



