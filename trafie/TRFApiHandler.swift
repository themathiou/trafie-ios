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
        let endPoint: String = trafieURL + "users/"
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
        let endPoint: String = trafieURL + "users/\(userId)"
        return Alamofire.request(.GET, endPoint)
    }
    

    //MARK:- Activities

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
        let endPoint: String = trafieURL + "users/\(userId)/activities"
        
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
        let endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
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
        let endPoint: String = trafieURL + "users/\(userId)/activities/"
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
        let endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
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
        let endPoint: String = trafieURL + "users/\(userId)/activities/\(activityId)"
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
        let endPoint: String = trafieURL + "users/\(userId)/disciplines/"
        return Alamofire.request(.GET, endPoint)
    }
    
    
    //MARK:- Login
    /**
    Authorize user no login, using username and password.
    
    endPoint: /authorize
    
    :param: String username
    :param: String password
    :param: String grant_type (always "password")
    :param: String clientId
    :param: String client_secret
    :returns: Alamofire.request with OAuth Token in it, on success.
    */
    class func authorize(username: String?=nil, password: String?=nil, grant_type: String?=nil, clientId: String?=nil, client_secret: String?=nil) -> Request{
        let endPoint: String = trafieURL + "authorize"
        var parameters: [String : AnyObject]? = ["username": "", "password": "", "grant_type": "password", "clientId": "", "client_secret": ""]
        if let unwrapped = username {
            parameters?.updateValue(unwrapped, forKey: "username")
        }
        if let unwrapped = password {
            parameters?.updateValue(unwrapped, forKey: "password")
        }
        if let unwrapped = grant_type {
          parameters?.updateValue(unwrapped, forKey: "grant_type")
        }
        if let unwrapped = clientId {
            parameters?.updateValue(unwrapped, forKey: "clientId")
        }
        if let unwrapped = client_secret {
            parameters?.updateValue(unwrapped, forKey: "client_secret")
        }
        return Alamofire.request(.POST, endPoint, parameters: parameters)
    }

    
}