//
//  TRFCommon.swift
//  trafie
//
//  Created by mathiou on 5/17/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation

// MARK: trafie base url
//let trafieURL = "http://trafie.herokuapp.com/" //heroku
let trafieURL = "http://localhost:3000/" //local

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
    case female
    case male
}

// MARK: Arrays
// all disciplines
let disciplinesAll = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running", "high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin", "pentathlon", "heptathlon", "decathlon"]

// categories of disciplines
let disciplinesTime = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running"]
let disciplinesDistance = ["high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin"]
let disciplinesPoints = ["pentathlon", "heptathlon", "decathlon"]

// countries
let countries = ["Greece", "United States of America", "Russia"]

// MARK:- Functions
// MARK: App Initialization
func validateInitValuesOfProfile() {
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
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "firstname")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "lastname")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "about")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "mainDiscipline")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isPrivate")
    NSUserDefaults.standardUserDefaults().setObject("male", forKey: "gender")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "birthday")
    NSUserDefaults.standardUserDefaults().setObject("", forKey: "country")
}

// MARK: Pickers and Ranges
func createIntRangeArray(from: Int, to: Int) -> [String] {
    var array: [String] = []
    for index in from..<to {
        array.append(String(index))
    }
    return array
}


