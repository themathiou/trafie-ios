//
//  ActivityMaster.swift
//  trafie
//
//  Created by mathiou on 05/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import RealmSwift

class ActivityMaster: Object {
    // MARK: Properties
    dynamic var userId: String = ""
    dynamic var activityId: String?
    dynamic var discipline: String?
    dynamic var performance: String?
    dynamic var readablePerformance: String?
    dynamic var date: String? //NSDate() //String | Date
    dynamic var rank: String?
    dynamic var location: String?
    dynamic var competition: String?
    dynamic var notes: String?
    dynamic var isPrivate: Bool = true
    dynamic var isOutdoor: Bool = true
    dynamic var owner: UserRealm?
    dynamic var isDraft: Bool = true
    
// Specify properties to ignore (Realm won't persist these)
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    override static func primaryKey() -> String? {
        return "activityId"
    }

    func insert() {
        do {
            try uiRealm.write { () -> Void in
                uiRealm.add([self])
            }
        }catch {
            Utils.log("Could not write activity with activityId: \(self.activityId)")
        }
    }
    
    func update() {
        do {
            try uiRealm.write { () -> Void in
                uiRealm.add(self, update: true)
            }
        }catch {
            Utils.log("Could not update activity with activityId: \(self.activityId)")
        }
    }
    
    func delete() {
        do {
            try uiRealm.write { () -> Void in
                uiRealm.delete(self)
            }
        }catch {
            Utils.log("Could not delete activity with activityId: \(self.activityId)")
        }
    }
    
}
