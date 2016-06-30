//
//  Utils.swift
//  trafie
//
//  Created by mathiou on 11/02/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit


final class Utils {

    // MARK:- Functions
    // MARK: App General

    /// Initialize the values of local user in NSUserDefaults.
    class func validateInitValuesOfProfile() {
        if NSUserDefaults.standardUserDefaults().objectForKey("token") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "token")
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("refreshToken") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "refreshToken")
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
        
        if NSUserDefaults.standardUserDefaults().objectForKey("email") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "email")
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("isVerified") == nil {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isVerified")
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") == nil {
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "measurementUnitsDistance")
        }

        Utils.log("Completed")
    }

    /// Resets the values stored in NSUserDefaults for local user
    class func resetValuesOfProfile() {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "token")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "refreshToken")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "userId")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "firstname")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "lastname")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "about")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "mainDiscipline")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isPrivate")
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isMale")
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isVerified")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "birthday")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "country")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "email")
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "measurementUnitsDistance")
        Utils.log("Completed")
    }

    /// Clears local user data.
    class func clearLocalUserData() {
        Utils.resetValuesOfProfile()
        lastFetchingActivitiesDate = ""
        try! uiRealm.write {
            uiRealm.deleteAll()
        }
    }
    
    /**
     Validates a string based on a regex
     
     - Parameter regex: The regex to match
     - Parameter text: The string to match with regex.
     
     - Returns: Bool
     */
    class func validateTextWithRegex(regex: String, text: String) -> Bool {
        let validator = NSPredicate(format:"SELF MATCHES %@", regex)
        return validator.evaluateWithObject(text)
    }

    /**
     Converts .25, .5, .75 to fractals for inches
     
     - Parameter percentage: The value to convert

     - Returns: String
     */
    class func convertPercentageToFraction(percentage: Double) -> String {
        switch(percentage){
        case 0.25:
            return Fractions.Quarter.rawValue
        case 0.5:
            return Fractions.Half.rawValue
        case 0.75:
            return Fractions.ThreeFourths.rawValue
        default:
            return ""
        }
    }
    
    /**
     Converts to fractals of inches to Double(.25, .5, .75)
     
     - Parameter fraction: The value to convert
     
     - Returns: String
     */
    class func convertFractionToPercentage(fraction: String) -> Double {
        switch(fraction){
        case Fractions.Quarter.rawValue:
            return 0.25
        case Fractions.Half.rawValue:
            return 0.5
        case Fractions.ThreeFourths.rawValue:
            return 0.75
        default:
            return 0
        }
    }

    /**
     Google Analytics Module for counting view hits.
     
     - Parameter viewName: the name of the specific view
     */
    class func googleViewHitWatcher(viewName: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: viewName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK:- Calculation Functions
    /**
     Converts the performance from a long integer to a human readable format.

     - Parameter performance: The performance in long integer format.
     - Parameter discipline: The discipline in which performance achieved.
     - Parameter measurementUnit: MeasurementUnits

     - Returns: A new string with performance in human-readable format, based on selected measurement unit.
    */
    class func convertPerformanceToReadable(performance: String, discipline: String, measurementUnit: String) -> String {
        var readable : String = ""
        let _performance = String(performance.characters.split(".")[0])
        let performanceInt : Int = Int(_performance)!
        
        //Time
        if disciplinesTime.contains(discipline) {
            let centisecs = (performanceInt % 100)
            let secs = ((performanceInt) % 6000) / 100
            let mins = (performanceInt % 360000) / 6000
            let hours = (performanceInt - secs - mins - centisecs) / 360000
            
            //fill with zeros if needed
            var minsPart : String = "00:"
            var secsPart : String = "00:"
            var centisecsPart : String = "00"

            if mins != 0 {
                minsPart = mins < 10 ? "0\(String(mins)):" : "\(String(mins)):"
            }

            if secs != 0 {
                secsPart = secs < 10 ? "0\(String(secs))." : "\(String(secs))."
            }
            
            if centisecs != 0 {
                centisecsPart = centisecs < 10 ? "0\(String(centisecs))" : "\(String(centisecs))"
            }
            
            readable  = secsPart + "\(String(centisecsPart))"
            
            if hours != 0 {
                readable = "\(String(hours)):" + minsPart + readable
            } else {
                if mins != 0 {
                    readable = minsPart + readable
                }
            }
            
            return readable
        } // Distance
        else if disciplinesDistance.contains(discipline) {
            if measurementUnit == MeasurementUnits.Feet.rawValue {
                var inches = Double(performance)! * 0.0003937007874
                let feet = floor(inches / 12)
                inches = inches - 12 * feet
                var inchesInteger = floor(inches)
                var inchesDecimal = inches - inchesInteger

                if(inchesDecimal >= 0.125 && inchesDecimal < 0.375) {
                    inchesDecimal = 0.25
                }
                else if(inchesDecimal >= 0.375 && inchesDecimal < 0.625) {
                    inchesDecimal = 0.5
                }
                else if(inchesDecimal >= 0.625 && inchesDecimal < 0.875) {
                    inchesDecimal = 0.75
                }
                else if(inchesDecimal >= 0.875) {
                    inchesInteger += 1
                    inchesDecimal = 0
                }
                else {
                    inchesDecimal = 0
                }

                readable = "\(Int(feet))' \(Int(inchesInteger))\(Utils.convertPercentageToFraction(inchesDecimal))\""

            } else { // default : Meters
                let centimeters = (performanceInt % 100000) / 1000
                let meters = (performanceInt - centimeters) / 100000
                
                readable = centimeters < 10 ? "\(String(meters)).0\(String(centimeters))" : "\(String(meters)).\(String(centimeters))"
            }
            
            return readable
        } // Points
        else if disciplinesPoints.contains(discipline){
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


    // MARK: Pickers and Ranges

    /**
     Creates an array of number values. Adds zero if necessary in front

     - Parameter from: First number
     - Parameter to: Last number
     - Parameter addZeros: Boolean value that indicates if zeros will be added in front of the Integer. Optional with default 'true'

     - Returns: String Array
    */
    class func createIntRangeArray(from: Int, to: Int, addZeros: Bool?=true) -> [String] {
        var array: [String] = []
        for _ in 1...3 {
            for index in from..<to {
                // add zero in front of one-digit numbers
                let value : String = ((addZeros! == true)  && (index < 10)) ? String(format: "%02d", index) : String(index)
                array.append(value)
            }
        }
        return array
    }

    /**
     Creates number arrays with specific limitations. They are needed in performance picker
     Reference: http://www.iaaf.org/records/toplists
     
     - Parameter discipline: the discipline which we want to apply the limitations
     - Parameter measurementUnit: String that should match MeasurementUnits
     
     - Returns: A String array with accepted values.
    */
    class func getPerformanceLimitationsPerDiscipline(discipline: String, measurementUnit: String) -> [[String]] {
        var array: [[String]] = [[]]
        var fractionsArray: [String] = []
        for _ in 1...3 {
            fractionsArray.append("0")
            fractionsArray.append(Fractions.Quarter.rawValue)
            fractionsArray.append(Fractions.Half.rawValue)
            fractionsArray.append(Fractions.ThreeFourths.rawValue)
        }

        switch discipline {
        //distance disciplines
        case "high_jump":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 9, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default: //meters
                array = [createIntRangeArray(1, to: 3, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }

            return array
        case "long_jump":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 99, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 10, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
        case "triple_jump":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 99, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 19, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
        case "pole_vault":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 99, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 7, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
        case "shot_put":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 80, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 24, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
        case "discus":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 250, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 75, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
        case "hammer":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 290, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 88, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
        case "javelin":
            switch(measurementUnit) {
            case MeasurementUnits.Feet.rawValue:
                array = [createIntRangeArray(0, to: 235, addZeros: false), ["'"], createIntRangeArray(0, to: 12), fractionsArray, ["\""]]
            default:
                array = [createIntRangeArray(0, to: 99, addZeros: false), ["."], createIntRangeArray(0, to: 100)]
            }
            return array
            //time disciplines
        case "50m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(5, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "60m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(6, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "100m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(9, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "200m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(19, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "400m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 2), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "800m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 4), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "1000m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 5), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "1500m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 6), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "one_mile":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 6), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "2000m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 10), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "3000m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "5000m":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "10000m":
            return [createIntRangeArray(0, to: 2), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "50m_hurdles":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(6, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "60m_hurdles":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(7, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "100m_hurdles":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(12, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "110m_hurdles":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 1), [":"], createIntRangeArray(12, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "400m_hurdles":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(46, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "3000m_steeplechase":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "4x100m_relay":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
        case "4x400m_relay":
            return [createIntRangeArray(0, to: 1), [":"], createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 100)]
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
    
    // MARK:- Text fields
    /// Causes the view (or one of its embedded text fields) to resign the first responder status.
    class func dismissFirstResponder(view: UIView) {
        view.endEditing(true)
    }

    /// Update UI for a UITextField based on his error-state
    class func textFieldHasError(textField: UITextField, hasError: Bool) {
        if hasError == true {
            textField.textColor = CLR_NOTIFICATION_RED
        } else {
            textField.textColor = CLR_DARK_GRAY
        }
    }

    /// Update UI for a UITextField based on his error-state, adding a red border if error.
    class func highlightErrorTextField (textField: UITextField, hasError: Bool) {
        if hasError {
            textField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 0.8 ).CGColor
            textField.layer.borderWidth = 1
        } else {
            textField.layer.borderWidth = 0
        }
    }
    
    /// Verify a specific text field based on a given regex
    class func isTextFieldValid(field: UITextField, regex: String) -> Bool {
        if field.text!.rangeOfString(regex, options: .RegularExpressionSearch) != nil {
            Utils.log("\(field.text) is OK")
            Utils.textFieldHasError(field, hasError: false)
            return false
        } else {
            Utils.log("\(field.text) is screwed")
            Utils.textFieldHasError(field, hasError: true)
            return true
        }
    }
    
    /**
     Validates the given email.
     
     - Parameter email: the email : String we want to validate.
     
     - Returns : ErrorMessage > .NoError or .InvalidEmail
     */
    class func validateEmail(email: String) -> ErrorMessage {
        return emailValidator.evaluateWithObject(email) == true ? .NoError : .InvalidEmail
    }

    // MARK:- Connections related
    /**
     Show in status bar an indication of the connection status
    */
    @objc class func showConnectionStatusChange() {
        let status = Reach().connectionStatus()
        let animationDuration: NSTimeInterval = 2.0

        switch status {
        case .Unknown, .Offline:
            Utils.log("Not connected")
            setNotificationState(.Warning , notification: statusBarNotification, style:.StatusBarNotification)
            statusBarNotification.displayNotificationWithMessage("You are offline", forDuration: animationDuration)
        case .Online(.WWAN):
            Utils.log("Connected via WWAN")
            setNotificationState(.Success , notification: statusBarNotification, style:.StatusBarNotification)
            statusBarNotification.displayNotificationWithMessage("You are online", forDuration: animationDuration)
        case .Online(.WiFi):
            Utils.log("Connected via WiFi")
            setNotificationState(.Success , notification: statusBarNotification, style:.StatusBarNotification)
            statusBarNotification.displayNotificationWithMessage("You are online", forDuration: animationDuration)
        }
    }

    /**
     Clears the text for connectivity status from navigation
     
     - Parameter discipline: the discipline which we want to apply the limitations
    */
    class func clearInformMessageForConnection(navigationItem: UINavigationItem) {
        navigationItem.prompt = nil
    }
    
    class func showNetworkActivityIndicatorVisible(setVisible: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = setVisible
    }

    // MARK:- Dates
    /**
     Converts a date to unix timestamp

     - Parameter date: the date we want to convert to unix timestamp. Date must be "yyyy-MM-dd'T'HH:mm:ss" i.e: "2016-01-24T22:40:39"

     - Returns: The unix timestamp value.
    */
    class func dateToTimestamp(date: String?="") -> Double {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        Utils.log("date \(date)")
        return date != "" ? dateFormatter.dateFromString(date!)!.timeIntervalSince1970 : 0
    }

    /**
     Converts a unix timestamp to date object
     - Parameter timestamp: timestamp should be a String representation of a Double(10digit) i.e: 1454431800

     - Returns: The NSDate object
    */
    class func timestampToDate(timestamp: String?="") -> NSDate {
        Utils.log("timestamp \(timestamp)")
        return timestamp != "" ? NSDate(timeIntervalSince1970: NSTimeInterval(timestamp!)!) : NSDate()
    }

    // MARK:- Logging
    /**
     Prints message with some important information
     - Parameter message: timestamp should be a String representation of a Double(10digit) i.e: 1454431800
     - Parameter functionName: name of function that hosts this
     - Parameter line: line in function that hosts this

    */
    class func log(message: String, functionName: String = #function, line: Int = #line) {
        print("\(NSDate()) : [\(functionName)] \(message) : \(line)")
    }
}