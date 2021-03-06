//
//  DBInterfaceHandler.swift
//  trafie
//
//  Created by mathiou on 10/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import SwiftyJSON

final class DBInterfaceHandler {
  //MARK:- Activities
  
  /**
   Requests user's activities from server after a specific date and updates the DB accordingly.
   
   - parameter String: userId.
   - parameter Date: from timestamp (date of event)
   - parameter Date: to timestamp (date of event)
   - parameter Date: updatedFrom timestamp (date of event)
   - parameter Date: updatedTo timestamp (date of event)
   - parameter String: discipline
   - parameter String: isDeleted
   */
  class func fetchUserActivitiesFromServer(_ userId: String, from: String?=nil, to: String?=nil, updatedFrom: String?=nil, updatedTo: String?=nil, discipline: String?=nil, isDeleted: String?=nil) {
    
    Utils.showNetworkActivityIndicatorVisible(true)
    ApiHandler.getAllActivitiesByUserId(userId: userId, updatedFrom: updatedFrom, isDeleted: isDeleted)
      .responseJSON { response in
        Utils.showNetworkActivityIndicatorVisible(false)
        
        if response.result.isSuccess {
          Utils.log(String(describing:  response.result.value!))
          Utils.log("Response with code \(response.response!.statusCode)")
          
          if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
            let date = Date()
            // This defines the format of lastFetchingActivitiesDate which used in different places. (i.e refreshContoller)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            lastFetchingActivitiesDate = dateFormatter.string(from: date)
            
            let activitiesArray = JSON(response.result.value!)
            // JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
            for (_, resActivity):(String,JSON) in activitiesArray {
              
              if resActivity["isDeleted"].boolValue {
                try! uiRealm.write {
                  let tmp = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: resActivity["_id"].stringValue as AnyObject)
                  if tmp != nil {
                    uiRealm.deleteNotified(tmp!)
                  }
                }
              } else {
                let _activity = ActivityModelObject(value: [
                  "userId": resActivity["userId"].stringValue,
                  "activityId": resActivity["_id"].stringValue,
                  "discipline": resActivity["discipline"].stringValue,
                  "performance": resActivity["performance"].stringValue,
                  "date": Utils.timestampToDate(resActivity["date"].stringValue),
                  "dateUnixTimestamp": resActivity["date"].stringValue,
                  "rank": resActivity["rank"].stringValue,
                  "location": resActivity["location"].stringValue,
                  "competition": resActivity["competition"].stringValue,
                  "notes": resActivity["notes"].stringValue,
                  "comments": resActivity["comments"].stringValue,
                  "isDeleted": (resActivity["isDeleted"].boolValue ? true : false),
                  "isOutdoor": (resActivity["isOutdoor"].boolValue ? true : false),
                  "isPrivate": (resActivity["isPrivate"].stringValue == "false" ? false : true),
                  "imageUrl": resActivity["picture"].stringValue,
                  "isDraft": false ])
                _activity.year = String(describing: (currentCalendar as NSCalendar).components(.year, from: _activity.date).year)
                
                _activity.update()
              }
            }
            
            Utils.log("self.activitiesArray.count -> \(activitiesArray.count)")
          } else {
            lastFetchingActivitiesDate = ""
            SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
          }
        } else if response.result.isFailure {
          Utils.log("Request failed with error: \(response.result.error)")
          lastFetchingActivitiesDate = ""
          if let data = response.data {
            Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
          }
        }
    }
  }
}
