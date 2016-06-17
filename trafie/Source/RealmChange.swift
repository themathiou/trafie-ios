//
//  RealmChange.swift
//  RealmResultsController
//
//  Created by Pol Quintana on 11/8/15.
//  Copyright © 2015 Redbooth.
//

import Foundation
import RealmSwift

public enum RealmAction {
    case Add
    case Update
    case Delete
}

/**
This class defines a Change made in a Realm.
It includes the type of the object changed, the action performed and a copy of the object.
It is important to store a copy and not the real object to make it thread safe
*/
public class RealmChange {
    public private(set) var type: Object.Type
    public private(set) var action: RealmAction
    public private(set) var mirror: Object?
    
    init<T:Object>(type: T.Type, action: RealmAction, mirror: Object?) {
        self.type = type
        self.action = action
        self.mirror = mirror
    }
}