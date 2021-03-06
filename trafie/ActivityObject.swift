//
//  ActivityMaster.swift
//  trafie
//
//  Created by mathiou on 05/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import RealmSwift

class ActivityObject: Object {
  // MARK: Properties
  dynamic var userId: String = ""
  dynamic var activityId: String?
  dynamic var discipline: String?
  dynamic var performance: String?
  dynamic var readablePerformance: String?
  dynamic var dateUnixTimestamp: String? //unix timestamp
  dynamic var date = Date()
  dynamic var year: String?
  dynamic var rank: String?
  dynamic var location: String?
  dynamic var competition: String?
  dynamic var notes: String?
  dynamic var comments: String?
  dynamic var imageUrl: String?
  dynamic var isPrivate: Bool = true
  dynamic var isOutdoor: Bool = true
  dynamic var isDeleted: Bool = false
  dynamic var isDraft: Bool = true
  
  // Specify properties to ignore (Realm won't persist these)
  //  override static func ignoredProperties() -> [String] {
  //    return []
  //  }
  
  override static func primaryKey() -> String? {
    return "activityId"
  }
  
  static func map(_ model: ActivityModelObject) -> ActivityObject {
    let activity = ActivityObject()
    activity.activityId = model.activityId
    activity.userId = model.userId
    activity.discipline = model.discipline
    activity.performance = model.performance
    activity.readablePerformance = model.readablePerformance
    activity.dateUnixTimestamp = model.dateUnixTimestamp
    activity.date = model.date
    activity.year = model.year
    activity.rank = model.rank
    activity.location = model.location
    activity.competition = model.competition
    activity.notes = model.notes
    activity.comments = model.comments
    activity.imageUrl = model.imageUrl
    activity.isPrivate = model.isPrivate
    activity.isOutdoor = model.isOutdoor
    activity.isDeleted = model.isDeleted
    activity.isDraft = model.isDraft
    
    return activity
  }
  
  static func mapTask(_ model: ActivityObject) -> ActivityModelObject {
    let activity = ActivityModelObject()
    activity.activityId = model.activityId
    activity.userId = model.userId
    activity.discipline = model.discipline
    activity.performance = model.performance
    activity.readablePerformance = model.readablePerformance
    activity.dateUnixTimestamp = model.dateUnixTimestamp
    activity.date = model.date
    activity.year = model.year
    activity.rank = model.rank
    activity.location = model.location
    activity.competition = model.competition
    activity.notes = model.notes
    activity.comments = model.comments
    activity.imageUrl = model.imageUrl
    activity.isPrivate = model.isPrivate
    activity.isOutdoor = model.isOutdoor
    activity.isDeleted = model.isDeleted
    activity.isDraft = model.isDraft
    
    return activity
  }
}

class ActivityModelObject: Object {
  // MARK: Properties
  dynamic var userId: String = ""
  dynamic var activityId: String?
  dynamic var discipline: String?
  dynamic var performance: String?
  dynamic var readablePerformance: String?
  dynamic var dateUnixTimestamp: String? //unix timestamp
  dynamic var date = Date()
  dynamic var year: String?
  dynamic var rank: String?
  dynamic var location: String?
  dynamic var competition: String?
  dynamic var notes: String?
  dynamic var comments: String?
  dynamic var imageUrl: String?
  dynamic var isPrivate: Bool = true
  dynamic var isOutdoor: Bool = true
  dynamic var isDeleted: Bool = false
  dynamic var isDraft: Bool = true
  
  // Specify properties to ignore (Realm won't persist these)
  //  override static func ignoredProperties() -> [String] {
  //    return []
  //  }
  
  override static func primaryKey() -> String? {
    return "activityId"
  }
  
  func update() {
    let _selectedMeasurementUnit: String = (UserDefaults.standard.object(forKey: "measurementUnitsDistance") as? String)!
    let _readablePerformance: String = (self.isOutdoor == true)
      ? Utils.convertPerformanceToReadable(self.performance!, discipline: self.discipline!, measurementUnit: _selectedMeasurementUnit)
      : Utils.convertPerformanceToReadable(self.performance!, discipline: self.discipline!, measurementUnit: _selectedMeasurementUnit) + "i"
    let _year: String = String(describing: (currentCalendar as NSCalendar).components(.year, from: self.date).year)

    do {
      try uiRealm.write { () -> Void in
        self.year = _year
        self.readablePerformance = _readablePerformance
        
        uiRealm.add(self, update: true)
        uiRealm.addNotified(self, update: true)
      }
    }catch {
      Utils.log("Could not update activity with activityId: \(self.activityId)")
    }
  }
  
}
