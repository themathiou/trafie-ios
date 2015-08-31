//
//  TRFActivityModel.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let trafieURL = "http://trafie.herokuapp.com/"
//let trafieURL = "http://localhost:3000/"

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
    
    //TODO: ALL REQUESTS TO BE HANDLED HERE
    
    ///Get All Activities for a specific user.
    ///
    ///:param: String userId.
    ///:returns: JSON
    func getAllActivitiesByUserId(userId: String) -> JSON {
        var endPoint = trafieURL + "users/\(userId)/activities"
        println("request url : \(endPoint)")
        //TO-DO update to activitiesObject
        var activities : JSON  = ""
        
        Alamofire.request(.GET, endPoint)
        //.authenticate(user: "user@trafie.com", password: "123123")
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            println(totalBytesRead)
        }
        .responseJSON { (request, response, JSONObject, error) in
            println(JSONObject)
            
            activities = JSON(JSONObject!)
            
            //Getting a double from a JSON Array
            let activity_1 = activities[0]["competition"]
            println(activity_1)
        }
        
        return activities
    }
    
    ///Posts a new activity.
    ///
    ///:param: JSONObject with all required fields of a new activity.
    ///:returns: Bool
    func postActivity(activityObject: JSON) -> Bool {
        
        return false
    }
    
    ///Updates an existing activity.
    ///
    ///:param: JSONObject with all required fields of a new activity.
    ///:returns: Bool
    func updateActivity(activityObject: JSON) -> Bool {
        return false
    }

    ///Deletes an activity based on its and user's ID.
    ///
    ///:param: String activityId
    ///:param: String userId
    ///:returns: Bool
    func deleteActivityById(activityId: String, userId: String) -> Bool {
        var endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
        Alamofire.request(.DELETE, endPoint)
        .responseJSON { (request, response, data, error) in
            if let anError = error
            {
                // got an error while deleting, need to handle it
                println("error calling DELETE on /posts/1")
                println(anError)
            }
        }
        
        return true
    }

}