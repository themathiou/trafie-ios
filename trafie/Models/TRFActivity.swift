//
//  TRFActivityModel.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire

class TRFActivity {
    // MARK: Properties 
    let userId		: String
    let discipline	: String
    let performance	: String //ENUM
    let date 		: String //DATE
    let place 		: String
    let location 	: String
    let competition : String
    let notes 		: String
    let isPrivate 	: Bool

    init() {
        self.userId = ""
        self.discipline = ""
        self.performance = ""
        self.date = ""
        self.place = ""
        self.location = ""
        self.competition = ""
        self.notes = ""
        self.isPrivate = false
    }
    
    init(userId: String, discipline: String, performance: String, date: String, place: String, location: String, competition: String, notes: String, isPrivate: Bool) {
        self.userId = userId
        self.discipline = discipline
        self.performance = performance
        self.date = date
        self.place = place
        self.location = location
        self.competition = competition
        self.notes = notes
        self.isPrivate = isPrivate
    }
}