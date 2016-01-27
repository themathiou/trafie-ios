//
//  ApiHandler.swift
//  trafie
//
//  Created by mathiou on 9/2/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON



final class ApiHandler {
    
    //MARK:- Users
    
    /**
        Returns users, filtered by the parameters. If there is a "keywords" parameters, 
        a search will be performed based on the words serparated by spaces. Only public users will be returned.
        
        Examples: '/users', '/users?firstName=George&last_name=Balasis', '/users?keywords=george balasis'

        - parameter String: firstName (optional)
        - parameter String: lastName (optional)
        - parameter String: discipline (optional)
        - parameter String: country (optional)
        - parameter String: keywords (optional)
        - returns: Alamofire.request
    */
    class func getUsers(firstName: String?=nil, lastName: String?=nil, discipline: String?=nil, country: String?=nil, keywords: String?=nil) -> Request {
        let endPoint: String = trafieURL + "api/users/"
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
        
        - parameter String: userId
        - returns: Alamofire.request
    */
    class func getUserById(userId: String) -> Request{
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        let endPoint: String = trafieURL + "api/users/\(userId)/"
        return Alamofire.request(.GET, endPoint, headers: headers, encoding: .JSON)
    }

    /**
     Updates local user settings
     
     endPoint: /users/:userId/
     
     - parameter [String: : AnyObject] settingsObject
     - returns: Alamofire.request
     */
    class func updateLocalUserSettings(userId: String, settingsObject: [String : AnyObject]) -> Request {
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        let endPoint: String = trafieURL + "api/users/\(userId)/"
        return Alamofire.request(.POST, endPoint, parameters: settingsObject, encoding: .JSON, headers: headers)
    }
    

    //MARK:- Activities

    /**
        Returns all the public activities of the user.
    
        endPoint: /users/:userId/activities/
    
        - parameter String: userId.
        - parameter Date: from (optional) yyyy-mm-dd
        - parameter Date: to (optional) yyyy-mm-dd
        - parameter String: discipline (optional)
        - returns: Alamofire.request
    */
    class func getAllActivitiesByUserId(userId: String, from: String?=nil, to: String?=nil, discipline: String?=nil) -> Request {
        let endPoint: String = trafieURL + "api/users/\(userId)/activities"
        
        var parameters: [String : AnyObject]? = ["from": "", "to": "", "discipline": ""]
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        if let unwrapped = from {
            parameters?.updateValue(unwrapped, forKey: "from")
        }
        if let unwrapped = to {
            parameters?.updateValue(unwrapped, forKey: "to")
        }
        if let unwrapped = discipline {
            parameters?.updateValue(unwrapped, forKey: "discipline")
        }
        
        log("\(endPoint) \(parameters)")
        return Alamofire.request(.GET, endPoint, parameters: parameters, headers: headers)
    }

    /**
        Returns the activity by id. 
        Only public activities will be returned unless a logged in user tries to access their activity.
        
        endPoint: /users/:userId/activities/:activity_id
        
        - parameter String: userID
        - returns: Alamofire.request
    */
    class func getActivityById(userId: String, activityId: String) -> Request {
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.GET, endPoint, headers: headers)
    }

    /**
        Creates a new activity.

        endPoint: /users/:userId/activities
        
        - parameter String: userID
        - parameter [String: : AnyObject] activityObject
        - returns: Alamofire.request
    */
    class func postActivity(userId: String, activityObject: [String : AnyObject]) -> Request{
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let endPoint: String = trafieURL + "api/users/\(userId)/activities"
        return Alamofire.request(.POST, endPoint, parameters: activityObject, encoding: .JSON, headers: headers)
    }

    /**
        Edits the data of an existing activity.
        
        endPoint: /users/:userId/activities/:activity_id
        
        - parameter String: userID
        - parameter String: activityID
        - parameter [String: : AnyObject] activityObject
        - returns: Alamofire.request
    */
    class func updateActivityById(userId: String, activityId: String, activityObject: [String : AnyObject]) -> Request{
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.PUT, endPoint, parameters: activityObject, encoding: .JSON, headers: headers)
    }

    /**
        Deletes an existing activity.
        
        endPoint: /users/:userId/activities/:activity_id
        
        - parameter String: userID
        - parameter String: activityID
        - returns: Alamofire.request
    */
    class func deleteActivityById(userId: String, activityId: String) -> Request{
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.DELETE, endPoint, headers: headers)
    }
    
    //MARK:- Disciplines
    /**
    Returns all the disciplines that the user has recorded.
    
    endPoint: /users/:userId/disciplines/
    
    - parameter String: userID
    - returns: Alamofire.request
    */
    class func getDisciplinesOfUserById(userId: String) -> Request {
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let endPoint: String = trafieURL + "api/users/\(userId)/disciplines/"
        return Alamofire.request(.GET, endPoint, headers: headers)
    }
    
    
    //MARK:- Login / Register
    /**
    Authorize user no login, using username and password.
    
    endPoint: /authorize
    
    - parameter String: username
    - parameter String: password
    - parameter String: grant_type (always "password")
    - parameter String: client_id
    - parameter String: client_secret
    - returns: Alamofire.request with OAuth Token in it, on success.
    */
    class func authorize(username: String?=nil, password: String?=nil, grant_type: String?=nil, client_id: String?=nil, client_secret: String?=nil) -> Request{
        let endPoint: String = trafieURL + "authorize"
        var parameters: [String : AnyObject]? = ["username": "", "password": "", "grant_type": "", "client_id": "", "client_secret": ""]
        
        if let unwrapped = username {
            parameters?.updateValue(unwrapped, forKey: "username")
        }
        if let unwrapped = password {
            parameters?.updateValue(unwrapped, forKey: "password")
        }
        if let unwrapped = grant_type {
          parameters?.updateValue(unwrapped, forKey: "grant_type")
        }
        if let unwrapped = client_id {
            parameters?.updateValue(unwrapped, forKey: "client_id")
        }
        if let unwrapped = client_secret {
            parameters?.updateValue(unwrapped, forKey: "client_secret")
        }
        log("Authorize Request Parameters")
        print(parameters)
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }
    
    // TODO: blocked by backend implementation
    /**
     Register a new user.
     
     endPoint: /register
     
     - parameter String: firstName
     - parameter String: lastName
     - parameter String: email
     - parameter String: password
     - returns: Verification for succesful registration (WILL CHANGE)
     */
    class func register(firstName: String?=nil, lastName: String?=nil, email: String?=nil, password: String?=nil, repeatPassword: String?=nil) -> Request{
        let endPoint: String = trafieURL + "register"
        var parameters: [String : AnyObject]? = ["firstName": "", "lastName": "", "email": "", "password": ""]
        
        if let unwrapped = firstName {
            parameters?.updateValue(unwrapped, forKey: "firstName")
        }
        if let unwrapped = lastName {
            parameters?.updateValue(unwrapped, forKey: "lastName")
        }
        if let unwrapped = email {
            parameters?.updateValue(unwrapped, forKey: "email")
        }
        if let unwrapped = password {
            parameters?.updateValue(unwrapped, forKey: "password")
        }

        print(parameters)
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }
    

    /**
     Change user's password.

     endPoint: /settings
     - parameter String: oldPassword
     - parameter String: password
     - returns: Verification for succesful registration (WILL CHANGE)
     */
    class func changePassword(oldPassword: String?=nil, password: String?=nil) -> Request{
        let endPoint: String = trafieURL + "settings"
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        var parameters: [String : AnyObject]? = ["oldPassword": "", "password": ""]
        
        if let unwrapped = oldPassword {
            parameters?.updateValue(unwrapped, forKey: "oldPassword")
        }
        if let unwrapped = password {
            parameters?.updateValue(unwrapped, forKey: "password")
        }
        
        print(parameters)
        return Alamofire.request(.POST, endPoint, parameters: parameters, headers: headers, encoding: .JSON)
    }
    
    /**
     Reset password request.
     
     endPoint: /reset-password-request
     
     - parameter String: email
     - returns: Alamofire.request
     */
    class func resetPasswordRequest(email: String) -> Request{
        let endPoint: String = trafieURL + "reset-password-request"
        let parameters: [String : AnyObject]? = ["email": email]
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }
    
}