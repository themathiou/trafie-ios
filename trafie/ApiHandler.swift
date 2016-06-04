//
//  ApiHandler.swift
//  trafie
//
//  Created by mathiou on 9/2/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import Alamofire



final class ApiHandler {
    
    //MARK:- Users
    
    // TODO: add authorization when needed
    /**
        Returns users, filtered by the parameters. If there is a "keywords" parameters, 
        a search will be performed based on the words serparated by spaces. Only public users will be returned.
        
        Examples: '/api/users', '/api/users?firstName=George&lastName=Balasis', '/api/users?keywords=george balasis'

        - parameter String: firstName (optional)
        - parameter String: lastName (optional)
        - parameter String: discipline (optional)
        - parameter String: country (optional)
        - parameter String: keywords (optional)
        - returns: Alamofire.request
    */
    class func getUsers(firstName: String?=nil, lastName: String?=nil, discipline: String?=nil, country: String?=nil, keywords: String?=nil) -> Request {
        Utils.log("Called")
        let endPoint: String = trafieURL + "api/users/"

        var parameters = [String : AnyObject]()
        if let unwrappedValue = firstName {
            parameters["firstName"] = unwrappedValue
        }
        if let unwrappedValue = lastName {
            parameters["lastName"] =  unwrappedValue
        }
        if let unwrappedValue = discipline {
            parameters["discipline"] = unwrappedValue
        }
        if let unwrappedValue = country {
            parameters["country"] = unwrappedValue
        }
        if let unwrappedValue = keywords {
            parameters["keywords"] = unwrappedValue
        }

        return Alamofire.request(.GET, endPoint,  parameters: parameters)
    }
    
    /**
        Returns the user by id. Only public users will be returned unless a logged in user tries to access themselves.
        
        endPoint: /api/users/:userId/
        
        - parameter String: userId
        - returns: Alamofire.request
    */
    class func getUserById(userId: String) -> Request{
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        Utils.log(accessToken)
        let endPoint: String = trafieURL + "api/users/\(userId)/"
        return Alamofire.request(.GET, endPoint, headers: headers, encoding: .JSON)
    }

    /**
     Updates local user settings
     
     endPoint: /api/users/:userId/
     
     - parameter [String: : AnyObject] settingsObject
     - returns: Alamofire.request
     */
    class func updateLocalUserSettings(userId: String, settingsObject: [String : AnyObject]) -> Request {
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        let endPoint: String = trafieURL + "api/users/\(userId)/"
        return Alamofire.request(.POST, endPoint, parameters: settingsObject, encoding: .JSON, headers: headers)
    }
    
    /**
     Resend email-verification-code request.
     endPoint: /api/resend-verification-email
     
     - parameter String: email
     - returns: Alamofire.request
     */
    class func resendEmailVerificationCodeRequest() -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "api/resend-verification-email"
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        return Alamofire.request(.GET, endPoint, headers: headers, encoding: .JSON)
    }
    
    /**
     Change user's password.
     
     endPoint: api/users/\(userId)/
     - parameter String: oldPassword
     - parameter String: password
     - returns: Verification for succesful registration (WILL CHANGE)
     */
    class func changePassword(userId: String, oldPassword: String, password: String) -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "api/users/\(userId)/"
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let parameters: [String : AnyObject]? = ["oldPassword": oldPassword, "password": password]
        Utils.log(String(parameters))
        return Alamofire.request(.POST, endPoint, parameters: parameters, headers: headers, encoding: .JSON)
    }

    //MARK:- Activities

    /**
        Returns all the public activities of the user.
    
        endPoint: /api/users/:userId/activities/
    
        - parameter String: userId.
        - parameter Date: from timestamp (date of event)
        - parameter Date: to timestamp (date of event)
        - parameter Date: updatedFrom timestamp (date of event)
        - parameter Date: updatedTo timestamp (date of event)
        - parameter String: discipline
        - parameter String: isDeleted
        - returns: Alamofire.request
    */
    class func getAllActivitiesByUserId(userId: String, from: String?=nil, to: String?=nil, updatedFrom: String?=nil, updatedTo: String?=nil, discipline: String?=nil, isDeleted: String?=nil) -> Request {
        Utils.log("Called")
        let endPoint: String = trafieURL + "api/users/\(userId)/activities"
        var parameters = [String : AnyObject]()
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        if let unwrappedValue = from {
            if unwrappedValue != "" {
                parameters["from"] = unwrappedValue
            }
        }

        if let unwrappedValue = to {
            parameters["to"] = unwrappedValue
        }
        
        if let unwrappedValue = updatedFrom {
                parameters["updatedFrom"] = unwrappedValue
        }
        
        if let unwrappedValue = updatedTo {
            parameters["updatedTo"] = unwrappedValue
        }

        if let unwrappedValue = discipline {
            parameters["discipline"] = unwrappedValue
        }
        
        if let unwrappedValue = isDeleted {
            parameters["isDeleted"] = unwrappedValue
        }
        
        Utils.log("\(endPoint) \(parameters)")
        return Alamofire.request(.GET, endPoint, parameters: parameters, headers: headers)
    }

    /**
        Returns the activity by id. 
        Only public activities will be returned unless a logged in user tries to access their activity.
        
        endPoint: /api/users/:userId/activities/:activity_id
        
        - parameter String: userID
        - returns: Alamofire.request
    */
    class func getActivityById(userId: String, activityId: String) -> Request {
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.GET, endPoint, headers: headers)
    }

    /**
        Creates a new activity.

        endPoint: /api/users/:userId/activities
        
        - parameter String: userID
        - parameter [String: : AnyObject] activityObject
        - returns: Alamofire.request
    */
    class func postActivity(userId: String, activityObject: [String : AnyObject]) -> Request{
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let endPoint: String = trafieURL + "api/users/\(userId)/activities"
        return Alamofire.request(.POST, endPoint, parameters: activityObject, encoding: .JSON, headers: headers)
    }

    /**
        Edits the data of an existing activity.
        
        endPoint: /api/users/:userId/activities/:activity_id
        
        - parameter String: userID
        - parameter String: activityID
        - parameter [String: : AnyObject] activityObject
        - returns: Alamofire.request
    */
    class func updateActivityById(userId: String, activityId: String, activityObject: [String : AnyObject]) -> Request{
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]

        let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.PUT, endPoint, parameters: activityObject, encoding: .JSON, headers: headers)
    }

    /**
        Deletes an existing activity.
        
        endPoint: /api/users/:userId/activities/:activity_id
        
        - parameter String: userID
        - parameter String: activityID
        - returns: Alamofire.request
    */
    class func deleteActivityById(userId: String, activityId: String) -> Request{
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
        return Alamofire.request(.DELETE, endPoint, headers: headers)
    }
    
    //MARK:- Disciplines
    //TODO: UNUSED. REMOVE IT
    /**
    Returns all the disciplines that the user has recorded.
    
    endPoint: /api/users/:userId/disciplines/
    
    - parameter String: userID
    - returns: Alamofire.request
    */
    class func getDisciplinesOfUserById(userId: String) -> Request {
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let endPoint: String = trafieURL + "api/users/\(userId)/disciplines/"
        return Alamofire.request(.GET, endPoint, headers: headers)
    }
    

    
    
    //MARK:- Sans /api/ requests

    /**
    Change user's password.
    
    endPoint: /feedback
    - parameter String: platform
    - parameter String: os_version
    - parameter String: app_version
    - parameter FeedbackType: feedback_type
    - returns: Verification for succesful feedback
    */
    class func sendFeedback(feedback: String, platform: String, osVersion: String, appVersion: String, feedbackType: FeedbackType) -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "feedback"
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        
        let parameters: [String : AnyObject]? = ["feedback": feedback, "platform": platform, "osVersion": osVersion, "appVersion": appVersion, "feedbackType": feedbackType.rawValue ]
        Utils.log(String(parameters))
        return Alamofire.request(.POST, endPoint, parameters: parameters, headers: headers, encoding: .JSON)
    }
    
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
    class func authorize(username: String, password: String, grant_type: String, client_id: String, client_secret: String) -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "authorize"

        let parameters: [String : AnyObject]? = ["username": username, "password": password, "grant_type": grant_type, "client_id": client_id, "client_secret": client_secret]
        Utils.log(String(parameters))
        Utils.log("Authorize Request Parameters")
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }
    
    /**
     Authorize user using refresh token
     endpoint: /authorize
     
     - parameter String grant_type = "refresh_token"
     - parameter String refresh_token
     - parameter String client_id = "iphone"
     - parameter String client_secret = "secret"
    */
    class func authorizeWithRefreshToken(refresh_token: String, grant_type: String = "refresh_token", client_id: String = "iphone", client_secret: String = "secret") -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "authorize"
        
        let parameters: [String : AnyObject]? = ["refresh_token": refresh_token, "grant_type": grant_type, "client_id": client_id, "client_secret": client_secret]
        Utils.log(String(parameters))
        Utils.log("Authorize Request Parameters")
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }

    /**
     Register a new user.
     
     endPoint: /register
     
     - parameter String: firstName
     - parameter String: lastName
     - parameter String: email
     - parameter String: password
     - returns: Verification for succesful registration
     */
    class func register(firstName: String, lastName: String, email: String, password: String) -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "register"

        let parameters: [String : AnyObject]? = ["firstName": firstName, "lastName": lastName, "email": email, "password": password]
        Utils.log(String(parameters))
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }

    /**
     Reset password request.
     endPoint: /reset-password-request
     
     - parameter String: email
     - returns: Alamofire.request
     */
    class func resetPasswordRequest(email: String) -> Request{
        Utils.log("Called")
        let endPoint: String = trafieURL + "reset-password-request"

        let parameters: [String : AnyObject]? = ["email": email]
        Utils.log(String(parameters))
        return Alamofire.request(.POST, endPoint, parameters: parameters, encoding: .JSON)
    }
    
    /**
     Log out.
     endPoint: /logout
     - returns: Alamofire.request
     */
    class func logout() -> Request{
        Utils.log("Called")
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
        let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
        Utils.log(accessToken)
        let endPoint: String = trafieURL + "logout"
        return Alamofire.request(.GET, endPoint, headers: headers, encoding: .JSON)
    }

}