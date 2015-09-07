//
//  TRFApiHandler.swift
//  trafie
//
//  Created by mathiou on 9/2/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON



final class TRFApiHandler {
    
    //MARK:- Users
    //TODO: Adding API Calls for Users
    
    /**
        Returns users, filtered by the parameters. If there is a "keywords" parameters, 
        a search will be performed based on the words serparated by spaces. Only public users will be returned.
        
        Examples: '/users', '/users?firstName=George&last_name=Balasis', '/users?keywords=george balasis'

        :param: String firstName (optional)
        :param: String lastName (optional)
        :param: String discipline (optional)
        :param: String country (optional)
        :param: String keywords (optional)
        :returns: Alamofire.request
    */
    class func getUsers(firstName: String?=nil, lastName: String?=nil, discipline: String?=nil, country: String?=nil, keywords: String?=nil) -> Request {
        var endPoint: String = trafieURL + "users/"
        var parameters: [String : AnyObject]? = ["firstName": "", "lastName": "", "discipline": "", "country": "", "keywords": ""]
        if let unwrapped = firstName {
            parameters?.updateValue(unwrapped, forKey: "firstName")
        }
        if let unwrapped = lastName {
            parameters?.updateValue(unwrapped, forKey: "lastName")
        }
        if let unwrapped = discipline {
            parameters?.updateValue(unwrapped, forKey: "discipline")
        }
        if let unwrapped = country {
            parameters?.updateValue(unwrapped, forKey: "country")
        }
        if let unwrapped = keywords {
            parameters?.updateValue(unwrapped, forKey: "keywords")
        }
        return Alamofire.request(.GET, endPoint,  parameters: parameters)
    }
    
    /**
        Returns the user by id. Only public users will be returned unless a logged in user tries to access themselves.
        
        endPoint: /users/:userId/
        
        :param: String userID
        :returns: Alamofire.request
    */
    class func getUserById(userId: String, activityObject: JSON) -> Request{
        var endPoint: String = trafieURL + "users/\(userId)"
        return Alamofire.request(.GET, endPoint)
    }
    

    //MARK:- Activities
    //TODO: Adding API Calls for Activities
    
    /**
        Returns all the public activities of the user.
    
        endPoint: /users/:userId/activities/
    
        :param: String userId.
        :param: Date from (optional)
        :param: Date to (optional)
        :param: String discipline (optional)
        :returns: Alamofire.request
    */
    class func getAllActivitiesByUserId(userId: String, from: String?=nil, to: String?=nil, discipline: String?=nil) -> Request {
        var endPoint: String = trafieURL + "users/\(userId)/activities"
        
        var parameters: [String : AnyObject]? = ["from": "", "to": "", "discipline": ""]
        
        if let unwrapped = from {
            parameters?.updateValue(unwrapped, forKey: "from")
        }
        if let unwrapped = to {
            parameters?.updateValue(unwrapped, forKey: "to")
        }
        if let unwrapped = discipline {
            parameters?.updateValue(unwrapped, forKey: "discipline")
        }
        
        return Alamofire.request(.GET, endPoint, parameters: parameters)
    }

    /**
        Returns the activity by id. 
        Only public activities will be returned unless a logged in user tries to access their activity.
        
        endPoint: /users/:userId/activities/:activity_id
        
        :param: String userID
        :returns: Alamofire.request
    */
    class func getActivityById(userId: String, activityId: String) -> Request {
        var endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.GET, endPoint)
    }

    /**
        Creates a new activity.

        endPoint: /users/:userId/activities
        
        :param: String userID
        :param: [String : AnyObject] activityObject
        :returns: Alamofire.request
    */
    class func postActivity(userId: String, activityObject: [String : AnyObject]) -> Request{
        var endPoint: String = trafieURL + "users/\(userId)/activities/"
        return Alamofire.request(.POST, endPoint, parameters: activityObject, encoding: .JSON)
    }

    /**
        Edits the data of an existing activity.
        
        endPoint: /users/:userId/activities/:activity_id
        
        :param: String userID
        :param: String activityID
        :param: [String : AnyObject] activityObject
        :returns: Alamofire.request
    */
    class func updateActivityById(userId: String, activityId: String, activityObject: [String : AnyObject]) -> Request{
        var endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.PUT, endPoint, parameters: activityObject, encoding: .JSON)
    }

    /**
        Deletes an existing activity.
        
        endPoint: /users/:userId/activities/:activity_id
        
        :param: String userID
        :param: String activityID
        :returns: Alamofire.request
    */
    class func deleteActivityById(userId: String, activityId: String) -> Request{
        var endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.DELETE, endPoint)
    }
    
    //MARK:- Disciplines
    /**
    Returns all the disciplines that the user has recorded.
    
    endPoint: /users/:userId/disciplines/
    
    :param: String userID
    :returns: Alamofire.request
    */
    class func getDisciplinesOfUserById(userId: String) -> Request {
        var endPoint: String = trafieURL + "users/\(userId)/disciplines/"
        return Alamofire.request(.GET, endPoint)
    }
}