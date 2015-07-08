//
//  TRFCommon.swift
//  trafie
//
//  Created by mathiou on 5/17/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation


/**
Types of fuckin errors in our app -- NEED TO CHANGE

- OnlyDigitsErrorType: There should be only digits.
- IncorrectLengthErrorType: The length of input is incorrect.
- NoErrorErrorType: There is no error.
*/
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




// all disciplines
let disciplines = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running", "high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin", "pentathlon", "heptathlon", "decathlon"]

// categories of disciplines
let time = ["60m", "100m", "200m", "400m", "800m", "1500m", "3000m", "5000m", "10000m", "60m_hurdles", "100m_hurdles", "110m_hurdles", "400m_hurdles", "3000m_steeplechase", "4x100m_relay", "4x400m_relay", "half_marathon", "marathon", "20km_race_walk", "50km_race_walk", "cross_country_running"]
let distance = ["high_jump", "long_jump", "triple_jump", "pole_vault", "shot_put", "discus", "hammer", "javelin"]
let points = ["pentathlon", "heptathlon", "decathlon"]

// countries
let countries = ["Greece", "Italy", "United States of America", "Columbia", "Persia", "France", "Portugal"]