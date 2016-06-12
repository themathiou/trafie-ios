//
//  UserRealm.swift
//  trafie
//
//  Created by mathiou on 05/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import RealmSwift

class UserRealm: Object {
    
    // MARK: Properties
    dynamic var firstname = ""
    dynamic var lastname = ""
    dynamic var about = ""
    dynamic var isMale = true
    dynamic var mainDiscipline = ""
    dynamic var profileIsPrivate = true
    dynamic var birthday = NSDate()
    
    let activities = List<ActivityMaster>()

    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
