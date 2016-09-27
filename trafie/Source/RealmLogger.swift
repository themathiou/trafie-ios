//
//  RealmLogger.swift
//  RealmResultsController
//
//  Created by Pol Quintana on 6/8/15.
//  Copyright © 2015 Redbooth.
//

import Foundation
import RealmSwift

/**
 Internal RealmResultsController class
 In charge of listen to Realm notifications and notify the RRCs when finished
 A logger is associated with one and only one Realm.
*/
class RealmLogger {
    var realm: Realm
    var temporary: [RealmChange] = []
    var notificationToken: NotificationToken?
    
    init(realm: Realm) {
        self.realm = realm
        
        if Thread.isMainThread {
            registerNotificationBlock()
        }
        else {
            CFRunLoopPerformBlock(CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
                self.registerNotificationBlock()
                CFRunLoopStop(CFRunLoopGetCurrent())
            }
            CFRunLoopRun()
        }
    }
    
    @objc func registerNotificationBlock() {
        self.notificationToken = self.realm.addNotificationBlock { notification, realm in
            if notification == .didChange {
                self.finishRealmTransaction()
            }
        }
    }
    
    /**
    When a Realm finish a write transaction, notify any active RRC via NSNotificaion
    Then clean the current state.
    */
    func finishRealmTransaction() {
        let realmIdentifier = realm.realmIdentifier
        var notificationName = "realmChanges"

        //For testing
        if realmIdentifier == "testingRealm" { notificationName = "realmChangesTest" }

        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName),
                                                                  object: [realmIdentifier : temporary])
        postIndividualNotifications()
        cleanAll()
    }
    
    /**
    Posts a notification for every change occurred in Realm
    */
    func postIndividualNotifications() {
        for change: RealmChange in temporary {
            guard let object = change.mirror else { continue }
            guard let name = object.objectIdentifier() else { continue }
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: change)
        }
    }
    
    func didAdd<T: RealmSwift.Object>(_ object: T) {
        add(object, action: .add)
    }
    
    func didUpdate<T: RealmSwift.Object>(_ object: T) {
        add(object, action: .update)
    }
    
    func didDelete<T: RealmSwift.Object>(_ object: T) {
        add(object, action: .delete)
    }
    
    /**
    When there is an operation in a Realm, instead of keeping a reference to the original object
    we create a mirror that is thread safe and can be passed to RRC to operate with it safely.
    :warning: the relationships of the Mirror are not thread safe.
    
    - parameter object Object that is involed in the transaction
    - parameter action Action that was performed on that object
    */
    func add<T: RealmSwift.Object>(_ object: T, action: RealmAction) {
        let realmChange = RealmChange(type: type(of: (object as Object)), action: action, mirror: object.getMirror())
        temporary.append(realmChange)
    }
    
    func cleanAll() {
        temporary.removeAll()
    }
    
}

