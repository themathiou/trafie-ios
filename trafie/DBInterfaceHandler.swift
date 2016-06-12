//
//  DBInterfaceHandler.swift
//  trafie
//
//  Created by mathiou on 10/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation

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
        ApiHandler.getAllActivitiesByUserId(userId, updatedFrom: updatedFrom)
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
                    for (_, activity):(String,JSON) in activitiesArray {
                        let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
                        let _readablePerformance = activity["isOutdoor"]
                            ? Utils.convertPerformanceToReadable(activity["performance"].stringValue,
                                discipline: activity["discipline"].stringValue,
                                measurementUnit: selectedMeasurementUnit)
                            : Utils.convertPerformanceToReadable(activity["performance"].stringValue,
                                discipline: activity["discipline"].stringValue,
                                measurementUnit: selectedMeasurementUnit) + "i"

                        let activityRealm = ActivityMaster(value: ["userId": activity["userId"].stringValue,
                            "activityId": activity["_id"].stringValue,
                            "discipline": activity["discipline"].stringValue,
                            "performance": activity["performance"].stringValue,
                            "date": activity["date"].stringValue,
                            "rank": activity["rank"].stringValue,
                            "location": activity["location"].stringValue,
                            "competition": activity["competition"].stringValue,
                            "readablePerformance":"",
                            "notes": activity["notes"].stringValue,
                            "isOutdoor": (activity["isOutdoor"] ? true : false),
                            "isPrivate": (activity["isPrivate"].stringValue == "false" ? false : true),
                            "isDraft": false])
                        activityRealm.insert()
                        
//                        if (activity["isDeleted"].stringValue == "true") {
//                            let oldKey = String(currentCalendar.components(.Year, fromDate: _activity.getDate()).year)
//                            removeActivity(_activity, section: oldKey)
//                        } else {
//                            // add activity
//                            addActivity(_activity, section: String(currentCalendar.components(.Year, fromDate: _activity.getDate()).year))
//                        }
                    }
                    
//                    if self.activitiesArray.count == 0 {
//                        self.activitiesTableView.emptyDataSetDelegate = self
//                        self.activitiesTableView.emptyDataSetSource = self
//                    }
//                    
//                    self.reloadActivitiesTableView()
                    Utils.log("self.activitiesArray.count -> \(activitiesArray.count)")
                    
//                    self.loadingActivitiesView.hidden = true
//                    self.activitiesLoadingIndicator.stopAnimating()
//                    self.refreshControl.endRefreshing()
                } else {
                    SweetAlert().showAlert("Oooops!", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                }
                
            case .Failure(let data, let error):
                Utils.log("Request failed with error: \(error)")
//                activitiesArray = []
//                sectionsOfActivities = Dictionary<String, Array<Activity>>()
//                sortedSections = [String]()
                
                if let data = data {
                    Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
            }
        }
    }
    

}