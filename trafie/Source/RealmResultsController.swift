//
//  RealmResultsController.swift
//  redbooth-ios-sdk
//
//  Created by Isaac Roldan on 4/8/15.
//  Copyright © 2015 Redbooth Inc.
//

import Foundation
import UIKit
import RealmSwift

enum RRCError: Error {
    case invalidKeyPath
    case emptySortDescriptors
}

public enum RealmResultsChangeType: String {
    case Insert
    case Delete
    case Update
    case Move
}

public protocol RealmResultsControllerDelegate: class {
    
    /**
    Notifies the receiver that the realm results controller is about to start processing of one or more changes due to an add, remove, move, or update.
    
    :param: controller The realm results controller that sent the message.
    */
    func willChangeResults(_ controller: AnyObject)
    
    /**
    Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    
    :param: controller   The realm results controller that sent the message.
    :param: object       The object in controller’s fetched results that changed.
    :param: oldIndexPath The index path of the changed object (this value is the same as newIndexPath for insertions).
    :param: newIndexPath The destination path for the object for insertions or moves (this value is the same as oldIndexPath for a deletion).
    :param: changeType   The type of change. For valid values see RealmResultsChangeType.
    */
    func didChangeObject<U>(_ controller: AnyObject, object: U, oldIndexPath: IndexPath, newIndexPath: IndexPath, changeType: RealmResultsChangeType)
    
    /**
    Notifies the receiver of the addition or removal of a section.
    
    :param: controller The realm results controller that sent the message.
    :param: section    The section that changed.
    :param: index      The index of the changed section.
    :param: changeType The type of change (insert or delete).
    */
    func didChangeSection<U>(_ controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType)
    
    /**
    Notifies the receiver that the realm results controller has completed processing of one or more changes due to an add, remove, move, or update.
    
    :param: controller The realm results controller that sent the message.
    */
    func didChangeResults(_ controller: AnyObject)
}

open class RealmResultsController<T: RealmSwift.Object, U> : RealmResultsCacheDelegate {
    open weak var delegate: RealmResultsControllerDelegate?
    var _test: Bool = false
    var populating: Bool = false
    var observerAdded: Bool = false
    var cache: RealmResultsCache<T>!
    fileprivate(set) open var request: RealmRequest<T>
    fileprivate(set) open var filter: ((T) -> Bool)?
    var mapper: (T) -> U
    var sectionKeyPath: String? = ""
    var queueManager: RealmQueueManager = RealmQueueManager()
    var temporaryAdded: [T] = []
    var temporaryUpdated: [T] = []
    var temporaryDeleted: [T] = []

    /**
    All results separated by the sectionKeyPath in RealmSection<U>
    
    Warning: This is computed variable that maps all the avaliable sections using the mapper. Could be an expensive operation
    Warning2: The RealmSections contained in the array do not contain objects, only its keyPath
    */
    open var sections: [RealmSection<U>] {
        return cache.sections.map(realmSectionMapper)
    }
    
    /// Number of sections in the RealmResultsController
    open var numberOfSections: Int {
        return cache.sections.count
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        observerAdded = false
    }
    
    
    //MARK: Initializers

    /**
    Create a RealmResultsController with a Request, a SectionKeypath to group the results and a mapper.
    This init NEEDS a mapper, and all the Realm Models (T) will be transformed using the mapper
    to objects of type (U). Done this way to avoid using Realm objects that are not thread safe.
    And to decouple the Model layer of the View Layer.
    If you want the RRC to return Realm objects that are thread safe, you should use the init
    that doesn't require a mapper.
    
    NOTE: If sectionKeyPath is used, it must be equal to the property used in the first SortDescriptor
    of the RealmRequest. If not, RRC will throw an error.
    NOTE2: Realm does not support sorting by KeyPaths, so you must only use properties of the model
    you want to fetch and not KeyPath to any relationship
    NOTE3: The RealmRequest needs at least one SortDescriptor
    
    - param: request        Request to fetch objects
    - param: sectionKeyPath KeyPath to group the results by sections
    - param: mapper         Mapper to map the results.
    
    - returns: Self
    */
    public init(request: RealmRequest<T>, sectionKeyPath: String? ,mapper: @escaping (T) -> U, filter: ((T) -> Bool)? = nil) throws {
        self.request = request
        self.mapper = mapper
        self.sectionKeyPath = sectionKeyPath
        self.cache = RealmResultsCache<T>(request: request, sectionKeyPath: sectionKeyPath)
        self.filter = filter
        if sortDescriptorsAreEmpty(request.sortDescriptors) {
            throw RRCError.emptySortDescriptors
        }
        if !keyPathIsValid(sectionKeyPath, sorts: request.sortDescriptors) {
            throw RRCError.invalidKeyPath
        }
        self.cache?.delegate = self
    }
    
    /**
    This INIT does not require a mapper, instead will use an empty mapper.
    If you plan to use this INIT, you should create the RRC specifiyng T = U
    Ex: let RRC = RealmResultsController<TaskModel, TaskModel>....
    
    All objects sent to the delegate of the RRC will be of the model type but
    they will be "mirrors", i.e. they don't belong to any Realm DB.
    
    NOTE: If sectionKeyPath is used, it must be equal to the property used in the first SortDescriptor
    of the RealmRequest. If not, RRC will throw an error
    NOTE2: The RealmRequest needs at least one SortDescriptor
    
    - param: request        Request to fetch objects
    - param: sectionKeyPath keyPath to group the results of the request
    
    - returns: self
    */
    public convenience init(request: RealmRequest<T>, sectionKeyPath: String?) throws {
        try self.init(request: request, sectionKeyPath: sectionKeyPath, mapper: {$0 as! U})
    }
    
    internal convenience init(forTESTRequest request: RealmRequest<T>, sectionKeyPath: String?, mapper: @escaping (T)->(U)) throws {
        try self.init(request: request, sectionKeyPath: sectionKeyPath, mapper: mapper)
        self._test = true
    }
    
    /**
    Update the filter currently used in the RRC by a new one.
    
    This func resets completetly the RRC, so:
    - It will force the RRC to clean all its cache and refetch all the objects.
    - You MUST do a reloadData() in your UITableView after calling this method.
    - Not refreshing the table could cause a crash because the indexes changed.
    
    :param: newFilter A Filter closure applied to T: Object
    */
    open func updateFilter(_ newFilter: @escaping (T) -> Bool) {
        filter = newFilter
        performFetch()
    }
    
    
    //MARK: Fetch
    
    /**
    Fetches the initial data for the RealmResultsController
    
    Atention: Must be called after the initialization and should be called only once
    */
    open func performFetch() {
        populating = true
        var objects = self.request.execute().toArray().map{ $0.getMirror() }
        if let filter = filter {
            objects = objects.filter(filter)
        }
        self.cache.reset(objects)
        populating = false
        if !observerAdded { self.addNotificationObservers() }
    }

    
    //MARK: Helpers
    
    /**
    Returns the number of objects at a given section index
    
    - param: sectionIndex Int
    
    - returns: the objects count at the sectionIndex
    */
    open func numberOfObjectsAt(_ sectionIndex: Int) -> Int {
        if cache.sections.count == 0 { return 0 }
        return cache.sections[sectionIndex].objects.count
    }

    /**
    Returns the mapped object at a given NSIndexPath
    
    - param: indexPath IndexPath for the desired object
    
    - returns: the object as U (mapped)
    */
    open func objectAt(_ indexPath: IndexPath) -> U {
        let object = cache.sections[(indexPath as NSIndexPath).section].objects[(indexPath as NSIndexPath).row] as! T
        return self.mapper(object)
    }

    fileprivate func sortDescriptorsAreEmpty(_ sorts: [SortDescriptor]) -> Bool {
        return sorts.first == nil
    }
    
    // At this point, we are sure sorts.first always has a SortDescriptor
    fileprivate func keyPathIsValid(_ keyPath: String?, sorts: [SortDescriptor]) -> Bool {
        if keyPath == nil { return true }
        return keyPath == sorts.first!.property
    }
    
    fileprivate func realmSectionMapper<S>(_ section: Section<S>) -> RealmSection<U> {
        return RealmSection<U>(objects: nil, keyPath: section.keyPath)
    }
    
    
    //MARK: Cache delegate
    
    func didInsert<T: Object>(_ object: T, indexPath: IndexPath) {
        Threading.executeOnMainThread {
            self.delegate?.didChangeObject(self, object: object, oldIndexPath: indexPath, newIndexPath: indexPath, changeType: .Insert)
        }
    }
    
    func didUpdate<T: Object>(_ object: T, oldIndexPath: IndexPath, newIndexPath: IndexPath, changeType: RealmResultsChangeType) {
        Threading.executeOnMainThread {
            self.delegate?.didChangeObject(self, object: object, oldIndexPath: oldIndexPath, newIndexPath: newIndexPath, changeType: changeType)
        }
    }
    
    func didDelete<T: Object>(_ object: T, indexPath: IndexPath) {
        Threading.executeOnMainThread {
            self.delegate?.didChangeObject(self, object: object, oldIndexPath: indexPath, newIndexPath: indexPath, changeType: .Delete)
        }
    }
    
    func didInsertSection<T : Object>(_ section: Section<T>, index: Int) {
        if populating { return }
        Threading.executeOnMainThread {
            self.delegate?.didChangeSection(self, section: self.realmSectionMapper(section), index: index, changeType: .Insert)
        }
    }
    
    func didDeleteSection<T : Object>(_ section: Section<T>, index: Int) {
        Threading.executeOnMainThread {
            self.delegate?.didChangeSection(self, section: self.realmSectionMapper(section), index: index, changeType: .Delete)
        }
    }
    
    
    //MARK: Realm Notifications
    
    fileprivate func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRealmChanges), name: NSNotification.Name(rawValue: "realmChanges"), object: nil)
        observerAdded = true
    }
    
    @objc func didReceiveRealmChanges(_ notification: Foundation.Notification) {
        guard case let notificationObject as [String : [RealmChange]] = notification.object
            , notificationObject.keys.first == request.realm.realmIdentifier,
            let objects = notificationObject[self.request.realm.realmIdentifier] else { return }
        queueManager.addOperation {
            self.refetchObjects(objects)
            self.finishWriteTransaction()
        }
        
    }
    
    fileprivate func refetchObjects(_ objects: [RealmChange]) {
        for object in objects {
            guard String(describing: object.type) == String(describing: T.self), let mirrorObject = object.mirror as? T else { continue }
            if object.action == RealmAction.delete {
                temporaryDeleted.append(mirrorObject)
                continue
            }
            
            var passesFilter = true
            var passesPredicate = true
            
            Threading.executeOnMainThread(true) {
                passesPredicate = self.request.predicate.evaluate(with: mirrorObject)
                if let filter = self.filter {
                    passesFilter = filter(mirrorObject)
                }
            }
    
            if object.action == RealmAction.add && passesPredicate && passesFilter {
                temporaryAdded.append(mirrorObject)
            }
            else if object.action == RealmAction.update {
                if passesFilter && passesPredicate {
                    temporaryUpdated.append(mirrorObject)
                }
                else {
                    temporaryDeleted.append(mirrorObject)
                }
            }
        }
    }

    func pendingChanges() -> Bool{
        return temporaryAdded.count > 0 ||
            temporaryDeleted.count > 0 ||
            temporaryUpdated.count > 0
    }
    
    fileprivate func finishWriteTransaction() {
        if !pendingChanges() { return }
        Threading.executeOnMainThread(true) {
            self.delegate?.willChangeResults(self)
        }
        
        removeDuplicates()
        
        var objectsToMove: [T] = []
        var objectsToUpdate: [T] = []
        for object in temporaryUpdated {
            cache.updateType(object) == .Move ? objectsToMove.append(object) : objectsToUpdate.append(object)
        }
        
        temporaryDeleted.append(contentsOf: objectsToMove)
        temporaryAdded.append(contentsOf: objectsToMove)
        cache.update(objectsToUpdate)
        cache.delete(temporaryDeleted)
        cache.insert(temporaryAdded)
        temporaryAdded.removeAll()
        temporaryDeleted.removeAll()
        temporaryUpdated.removeAll()
        Threading.executeOnMainThread(true) {
            self.delegate?.didChangeResults(self)
        }
    }
    
    func removeDuplicates() {
        // DELETED > UPDATED > ADDED
        temporaryDeleted.forEach { deletedObject in
            if let index = temporaryAdded.index(where: { $0.hasSamePrimaryKeyValue(deletedObject)}) {
                warnDuplicated(T.self, originalChange: .add, prevails: .delete)
                temporaryAdded.remove(at: index)
            }
            if let index = temporaryUpdated.index(where: { $0.hasSamePrimaryKeyValue(deletedObject)}) {
                warnDuplicated(T.self, originalChange: .update, prevails: .delete)
                temporaryUpdated.remove(at: index)
            }
        }
        temporaryUpdated.forEach { updatedObject in
            if let index = temporaryAdded.index(where: { $0.hasSamePrimaryKeyValue(updatedObject)}) {
                warnDuplicated(T.self, originalChange: .add, prevails: .update)
                temporaryAdded.remove(at: index)
            }
        }
    }
    
    func warnDuplicated(_ type: Object.Type, originalChange: RealmAction, prevails: RealmAction) {
        NSLog("[WARNING] Attempt to \(prevails) and \(originalChange) an object of type \(type). \(prevails) prevails")
        NSLog("Set a symbolic breakpoint on 'RealmResultsController.warnDuplicated' to debug this error")
    }
}
