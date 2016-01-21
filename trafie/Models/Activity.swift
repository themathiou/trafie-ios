//
//  ActivityModel.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire

class Activity {
    // MARK: Properties 
    let userId              : String
    let activityId          : String
    let discipline          : String
    let performance         : String
    let readablePerformance	: String
    let date                : NSDate //String //DATE
    let rank                : String
    let location            : String
    let competition         : String
    let notes               : String
    let isPrivate           : String //BOOL
    
    // MARK: Constructors
    init() {
        self.activityId = ""
        self.userId = ""
        self.discipline = ""
        self.performance = ""
        self.readablePerformance = ""
        self.date = NSDate()
        self.rank = ""
        self.location = ""
        self.competition = ""
        self.notes = ""
        self.isPrivate = "false"
    }

    // without activity id
    init(userId: String, discipline: String, performance: String, readablePerformance: String, date: NSDate, rank: String, location: String, competition: String, notes: String, isPrivate: String) {
        self.userId = userId
        self.activityId = ""
        self.discipline = discipline
        self.performance = performance
        self.readablePerformance = readablePerformance
        self.date = date
        self.rank = rank
        self.location = location
        self.competition = competition
        self.notes = notes
        self.isPrivate = isPrivate
    }
    
    // with activity id
    init(userId: String, activityId: String, discipline: String, performance: String, readablePerformance: String, date: NSDate, rank: String, location: String, competition: String, notes: String, isPrivate: String) {
        self.userId = userId
        self.activityId = activityId
        self.discipline = discipline
        self.performance = performance
        self.readablePerformance = readablePerformance
        self.date = date
        self.rank = rank
        self.location = location
        self.competition = competition
        self.notes = notes
        self.isPrivate = isPrivate
    }
    
    // MARK: Getters
    func getUserId() -> String {
        return self.userId
    }
    
    func getActivityId() -> String {
        return self.activityId
    }
    
    func getDiscipline() -> String {
        return self.discipline
    }
    
    func getPerformance() -> String {
        return self.performance
    }
    
    func getReadablePerformance() -> String {
        return self.readablePerformance
    }
    
    func getDate() -> NSDate {
        return self.date
    }
    
    func getRank() -> String {
        return self.rank
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func getCompetition() -> String {
        return self.competition
    }
    
    func getNotes() -> String {
        return self.notes
    }
    
    func getPrivate() -> String {
        return self.isPrivate
    }
}