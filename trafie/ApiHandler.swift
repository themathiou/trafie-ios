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
  /**
   Returns users, filtered by the parameters. If there is a "keywords" parameters,
   a search will be performed based on the words serparated by spaces. Only public users will be returned.
   
   - method: GET

   Examples: '/api/users', '/api/users?firstName=George&lastName=Balasis', '/api/users?keywords=george balasis'
   
   - parameter String: firstName (optional)
   - parameter String: lastName (optional)
   - parameter String: discipline (optional)
   - parameter String: country (optional)
   - parameter String: keywords (optional)
   - returns: Alamofire.request
   */
  class func getUsers(firstName: String?=nil, lastName: String?=nil, discipline: String?=nil, country: String?=nil, keywords: String?=nil) -> DataRequest {
    Utils.log("Called")
    let endPoint: String = trafieURL + "api/users/"
    
    var parameters = [String : AnyObject]()
    if let unwrappedValue = firstName {
      parameters["firstName"] = unwrappedValue as AnyObject?
    }
    if let unwrappedValue = lastName {
      parameters["lastName"] =  unwrappedValue as AnyObject?
    }
    if let unwrappedValue = discipline {
      parameters["discipline"] = unwrappedValue as AnyObject?
    }
    if let unwrappedValue = country {
      parameters["country"] = unwrappedValue as AnyObject?
    }
    if let unwrappedValue = keywords {
      parameters["keywords"] = unwrappedValue as AnyObject?
    }
    
    return Alamofire.request(endPoint,  parameters: parameters)
  }
  
  /**
   Returns the user by id. Only public users will be returned unless a logged in user tries to access themselves.
   
   - method: GET
   
   endPoint: /api/users/:userId/
   
   - parameter String: userId
   - returns: Alamofire.request
   */
  class func getUserById(userId: String) -> DataRequest {
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    Utils.log(accessToken)
    let endPoint: String = trafieURL + "api/users/\(userId)/"
    return Alamofire.request(endPoint, encoding: JSONEncoding.default, headers: headers)
  }
  
  /**
   Updates local user settings
   
   - method: POST
   
   endPoint: /api/users/:userId/
   
   - parameter [String: : AnyObject] settingsObject
   - returns: Alamofire.request
   */
  class func updateLocalUserSettings(userId: String, settingsObject: [String : AnyObject]) -> DataRequest {
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    let endPoint: String = trafieURL + "api/users/\(userId)/"
    return Alamofire.request(endPoint, method: .post, parameters: settingsObject, encoding: JSONEncoding.default, headers: headers)
  }

  /**
   Resend email-verification-code request.
   
   - method: GET

   endPoint: /api/resend-verification-email
   
   - parameter String: email
   - returns: Alamofire.request
   */
  class func resendEmailVerificationCodeRequest() -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "api/resend-verification-email"
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    return Alamofire.request(endPoint, encoding: JSONEncoding.default, headers: headers)
  }
  
  /**
   Change user's password.
   
   
   - method: POST
   
   endPoint: api/users/\(userId)/
   - parameter String: oldPassword
   - parameter String: password
   - returns: Verification for succesful registration (WILL CHANGE)
   */
  class func changePassword(userId: String, oldPassword: String, password: String) -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "api/users/\(userId)/"
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    let parameters: [String : AnyObject]? = ["oldPassword": oldPassword as AnyObject,
                                             "password": password as AnyObject]
    Utils.log(String(describing: parameters))
    return Alamofire.request(endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
  }
  
  //MARK:- Activities
  
  /**
   Returns all the public activities of the user.
   
   - method: GET
   
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
  class func getAllActivitiesByUserId(userId: String, from: String?=nil, to: String?=nil, updatedFrom: String?=nil, updatedTo: String?=nil, discipline: String?=nil, isDeleted: String?=nil) -> DataRequest {
    Utils.log("Called")
    let endPoint: String = trafieURL + "api/users/\(userId)/activities"
    var parameters = [String : AnyObject]()
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    if let unwrappedValue = from {
      if unwrappedValue != "" {
        parameters["from"] = unwrappedValue as AnyObject?
      }
    }
    
    if let unwrappedValue = to {
      parameters["to"] = unwrappedValue as AnyObject?
    }
    
    if let unwrappedValue = updatedFrom {
      parameters["updatedFrom"] = unwrappedValue as AnyObject?
    }
    
    if let unwrappedValue = updatedTo {
      parameters["updatedTo"] = unwrappedValue as AnyObject?
    }
    
    if let unwrappedValue = discipline {
      parameters["discipline"] = unwrappedValue as AnyObject?
    }
    
    if let unwrappedValue = isDeleted {
      parameters["isDeleted"] = unwrappedValue as AnyObject?
    }
    
    Utils.log("\(endPoint) \(parameters)")
    return Alamofire.request(endPoint, parameters: parameters, headers: headers)
  }
  
  /**
   Returns the activity by id.
   Only public activities will be returned unless a logged in user tries to access their activity.
   
   - method: GET
   
   endPoint: /api/users/:userId/activities/:activity_id
   
   - parameter String: userID
   - returns: Alamofire.request
   */
  class func getActivityById(userId: String, activityId: String) -> DataRequest {
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
    return Alamofire.request(endPoint, headers: headers)
  }
  
  /**
   Creates a new activity.
   
   - method: POST
   
   endPoint: /api/users/:userId/activities
   
   - parameter String: userID
   - parameter [String: : AnyObject] activityObject
   - returns: Alamofire.request
   */
  class func postActivity(userId: String, activityObject: [String : AnyObject]) -> DataRequest {
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    let endPoint: String = trafieURL + "api/users/\(userId)/activities"
    return Alamofire.request(endPoint, method: .post, parameters: activityObject, encoding: JSONEncoding.default, headers: headers)
  }
  
  /**
   Edits the data of an existing activity.
   
   - method: PUT
   
   endPoint: /api/users/:userId/activities/:activity_id
   
   - parameter String: userID
   - parameter String: activityID
   - parameter [String: : AnyObject] activityObject
   - returns: Alamofire.request
   */
  class func updateActivityById(userId: String, activityId: String, activityObject: [String : AnyObject]) -> DataRequest{
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
    return Alamofire.request(endPoint, method: .put, parameters: activityObject, encoding: JSONEncoding.default, headers: headers)
  }
  
  /**
   Deletes an existing activity.
   
   - method: DELETE
   
   endPoint: /api/users/:userId/activities/:activity_id
   
   - parameter String: userID
   - parameter String: activityID
   - returns: Alamofire.request
   */
  class func deleteActivityById(userId: String, activityId: String) -> DataRequest{
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(activityId)"
    return Alamofire.request(endPoint, method: .delete, headers: headers)
  }
  
  
  //MARK:- Sans /api/ requests
  
  /**
   Change user's password.
   
   - method: POST
   
   endPoint: /feedback
   - parameter String: platform
   - parameter String: os_version
   - parameter String: app_version
   - parameter FeedbackType: feedback_type
   - returns: Verification for succesful feedback
   */
  class func sendFeedback(feedback: String, platform: String, osVersion: String, appVersion: String, feedbackType: FeedbackType) -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "feedback"
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    
    let parameters: [String : AnyObject]? = ["feedback": feedback as AnyObject,
                                             "platform": platform as AnyObject,
                                             "osVersion": osVersion as AnyObject,
                                             "appVersion": appVersion as AnyObject,
                                             "feedbackType": feedbackType.rawValue as AnyObject ]
    Utils.log(String(describing: parameters))
    return Alamofire.request(endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
  }
  
  /**
   Authorize user no login, using username and password.
   
   - method: POST
   
   endPoint: /authorize
   
   - parameter String: username
   - parameter String: password
   - parameter String: grant_type (always "password")
   - parameter String: client_id
   - parameter String: client_secret
   - returns: Alamofire.request with OAuth Token in it, on success.
   */
  class func authorize(_ username: String, password: String, grant_type: String, client_id: String, client_secret: String) -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "authorize"
    
    let parameters: [String : AnyObject]? = ["username": username as AnyObject,
                                             "password": password as AnyObject,
                                             "grant_type": grant_type as AnyObject,
                                             "client_id": client_id as AnyObject,
                                             "client_secret": client_secret as AnyObject]
    Utils.log(String(describing: parameters))
    Utils.log("Authorize Request Parameters")
    return Alamofire.request(endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
  }
  
  /**
   Authorize user using refresh token
   
   - method: POST

   endpoint: /authorize
   
   - parameter String grant_type = "refresh_token"
   - parameter String refresh_token
   - parameter String client_id = "iphone"
   - parameter String client_secret = "secret"
   */
  class func authorizeWithRefreshToken(refresh_token: String, grant_type: String = "refresh_token", client_id: String = "iphone", client_secret: String = "secret") -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "authorize"
    
    let parameters: [String : AnyObject]? = ["refresh_token": refresh_token as AnyObject,
                                             "grant_type": grant_type as AnyObject,
                                             "client_id": client_id as AnyObject,
                                             "client_secret": client_secret as AnyObject]
    Utils.log(String(describing: parameters))
    Utils.log("Authorize Request Parameters")
    return Alamofire.request(endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
  }
  
  /**
   Register a new user.

   - method: POST
   
   endPoint: /register
   
   - parameter String: firstName
   - parameter String: lastName
   - parameter String: email
   - parameter String: password
   - returns: Verification for succesful registration
   */
  class func register(firstName: String, lastName: String, email: String, password: String) -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "register"
    
    let parameters: [String : AnyObject]? = ["firstName": firstName as AnyObject,
                                             "lastName": lastName as AnyObject,
                                             "email": email as AnyObject,
                                             "password": password as AnyObject]
    Utils.log(String(describing: parameters))
    return Alamofire.request(endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
  }
  
  /**
   Reset password request.
   
   - method: POST

   endPoint: /reset-password-request
   
   - parameter String: email
   - returns: Alamofire.request
   */
  class func resetPasswordRequest(email: String) -> DataRequest{
    Utils.log("Called")
    let endPoint: String = trafieURL + "reset-password-request"
    
    let parameters: [String : AnyObject]? = ["email": email as AnyObject]
    Utils.log(String(describing: parameters))
    return Alamofire.request(endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
  }
  
  /**
   Log out.
   
   - method: GET

   endPoint: /logout
   - returns: Alamofire.request
   */
  class func logout() -> DataRequest {
    Utils.log("Called")
    let accessToken: String = (UserDefaults.standard.object(forKey: "token") as? String)!
    let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)"]
    Utils.log(accessToken)
    let endPoint: String = trafieURL + "logout"
    return Alamofire.request(endPoint, encoding: JSONEncoding.default, headers: headers)
  }
  
}
