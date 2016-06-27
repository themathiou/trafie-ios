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
    class func fetchUserActivitiesFromServer(userId: String, from: String?=nil, to: String?=nil, updatedFrom: String?=nil, updatedTo: String?=nil, discipline: String?=nil, isDeleted: String?=nil) {
        
        Utils.showNetworkActivityIndicatorVisible(true)
        ApiHandler.getAllActivitiesByUserId(userId, updatedFrom: updatedFrom, isDeleted: isDeleted)
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            Utils.log("totalBytesRead: \(totalBytesRead)")
        }
        .responseJSON { request, response, result in
            Utils.showNetworkActivityIndicatorVisible(false)
            switch result {
            case .Success(let JSONResponse):
                Utils.log(String(JSONResponse))
                Utils.log("Response with code \(response?.statusCode)")
                
                if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response?.statusCode)!)) {
                    let date = NSDate()
                    // This defines the format of lastFetchingActivitiesDate which used in different places. (i.e refreshContoller)
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    lastFetchingActivitiesDate = dateFormatter.stringFromDate(date)
                    
                    let activitiesArray = JSON(JSONResponse)
                    // JSON TO NSMUTABLE ARRAY THAT WILL BE READEN FROM TABLEVIEW
                    for (_, resActivity):(String,JSON) in activitiesArray {

                        if resActivity["isDeleted"] {
                            try! uiRealm.write {
                                let tmp = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: resActivity["_id"].stringValue)
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
                                "isDeleted": (resActivity["isDeleted"] ? true : false),
                                "isOutdoor": (resActivity["isOutdoor"] ? true : false),
                                "isPrivate": (resActivity["isPrivate"].stringValue == "false" ? false : true),
                                "isDraft": false ])
                            _activity.year = String(currentCalendar.components(.Year, fromDate: _activity.date).year)

                            _activity.update()
                        }
                    }
                    
                    Utils.log("self.activitiesArray.count -> \(activitiesArray.count)")
                    
                } else {
                    SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                }

            case .Failure(let data, let error):
                Utils.log("Request failed with error: \(error)")
                if let data = data {
                    Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }
}