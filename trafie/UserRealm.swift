//
//  UserRealm.swift
//  trafie
//
//  Created by mathiou on 14/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import RealmSwift

class UserObject: Object {
    // MARK: Properties
    dynamic var userId: String = ""
    dynamic var firstname: String = ""
    dynamic var lastname: String = ""
    dynamic var about: String = ""
    dynamic var isMale: Bool = true
    dynamic var mainDiscipline: String = ""
    dynamic var profileIsPrivate: Bool = false
    dynamic var birthday: String = ""  //needs upgrade to proper type

    // Specify properties to ignore (Realm won't persist these)
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}
