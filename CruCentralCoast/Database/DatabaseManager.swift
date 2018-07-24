//
//  DatabaseManager.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class DatabaseManager {
    
    static let instance = DatabaseManager()
    
    lazy var database: Firestore! = {
        return Firestore.firestore()
    }()
    
    private init() {}
    
    func getData<T: DatabaseObject>(_ completion: @escaping ([T])->Void) {
        self.database.collection(T.databasePath).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting objects from database: \(error)")
            } else {
                #if swift(>=4.1)
                let objects = querySnapshot?.documents.compactMap { T.init(dict: $0.data() as NSDictionary) } ?? []
                #else
                let objects = querySnapshot?.documents.flatMap { T.init(dict: $0.data() as NSDictionary) } ?? []
                #endif
                completion(objects)
            }
        }
    }
    
    func getMinistries(_ completion: @escaping ([Ministry])->Void) {
        getData(completion)
    }
    
    func getResources(ofType type: ResourceType, _ completion: @escaping ([Resource])->Void) {
        self.database.collection(Resource.databasePath).whereField("type", isEqualTo: type.string).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting resources from database: \(error)")
            } else {
                let resources = querySnapshot?.documents.compactMap { Resource.createResource(dict: $0.data() as NSDictionary) } ?? []
                completion(resources)
            }
        }
    }

    func getEvents(_ completion: @escaping ([Event])->Void) {
        getData(completion)
    }
    
    func downloadObject<T: RealmObject>(_ classType: T.Type, document: DocumentReference, completion: ((T)->Void)? = nil) {
        document.getDocument { (document, error) in
            // Handle failure
            guard let document = document else {
                print("Error downloading object from database: \(error!)")
                return
            }
            
            // Add the document id to the properties dict
            var dict = document.data()!
            dict["id"] = document.documentID
            
            // Get the default realm database
            let realm = try! Realm()
            
            // Find the existing realm object or create a new one
            if let realmObject = (realm.objects(T.self).filter { $0.id == document.documentID }.first) {
                try! realm.write {
                    // Update the object's properties
                    realmObject.set(with: dict)
                }
                completion?(realmObject)
            } else {
                // Create the realm object and set its properties
                let realmObject = T()
                realmObject.set(with: dict)
                
                // Add the new object to the realm database
                try! realm.write {
                    realm.add(realmObject)
                }
                completion?(realmObject)
            }
        }
    }
    
    // Objects listening to changes in the database
    var listeners: [WeakRef<DatabaseListener>] = []
    
    func subscribeToDatabaseUpdates(_ subscriber: DatabaseListener) {
        let alreadyExists = self.listeners.contains { weakRef -> Bool in
            if let value = weakRef.value {
                return value == subscriber
            }
            return false
        }
        
        if !alreadyExists {
            self.listeners.append(WeakRef(subscriber))
        }
    }
    
    var personListener: ListenerRegistration?
    var campusListener: ListenerRegistration?
    var movementListener: ListenerRegistration?
    var eventListener: ListenerRegistration?
    var resourceListener: ListenerRegistration?
    var communityGroupListener: ListenerRegistration?
    var ministryTeamListener: ListenerRegistration?
    var missionListener: ListenerRegistration?
    
    func getCampuses() -> Results<Campus> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let campuses = realm.objects(Campus.self)
        
        // Ensure only one listener is created
        if self.campusListener == nil {
            // Listen for Firebase updates on this collection
            self.campusListener = self.listenForChangesInCollection(Campus.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedCampuses?() }
            }
        }
        return campuses
    }
    
    func getMovements() -> Results<Movement> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let movements = realm.objects(Movement.self)
        
        // Ensure only one listener is created
        if self.movementListener == nil {
            // Listen for Firebase updates on this collection
            self.movementListener = self.listenForChangesInCollection(Movement.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedMovements?() }
            }
        }
        return movements
    }
    
//    func getEvents2() -> Results<Event> { return self.getObjects() }
//
//    private func getObjects<T: RealmObject>(_ classType: T.Type) -> Results<T> {
//        // Get the default realm database
//        let realm = try! Realm()
//        // Get an always up-to-date list of realm objects of the given type
//        let realmObjects = realm.objects(T.self)
//
//        // Ensure only one listener is created
//        if self.movementListener == nil {
//            // Listen for Firebase updates on this collection
//            self.movementListener = self.listenForChangesInCollection(T.self) {
//                // Attempt to call the appropriate callback on each listener
//                self.listeners.forEach { $0.value?.updatedMovements?() }
//            }
//        }
//        return realmObjects
//    }
    
    /// Creates a Firebase listener on a collection of elements. Every time one of these elements is modified in Firebase,
    /// the app is immediately notified and the realm database is updated.
    /// - parameter classType: The type of the elements within the collection.
    /// - parameter callback: An escaping block which is executed upon propagation of updates to the realm database.
    private func listenForChangesInCollection<T: RealmObject>(_ classType: T.Type, callback: @escaping ()->Void) -> ListenerRegistration {
        return self.database.collection(T.databasePath).addSnapshotListener { (querySnapshot, error) in
            // Handle failure
            guard let snapshot = querySnapshot else {
                print("ERROR: Failed to fetch Firebase snapshot: \(error!)")
                return
            }
            
            // Get the default realm database
            let realm = try! Realm()
            
            // Handle changes to each Firebase object
            snapshot.documentChanges.forEach { diff in
                switch diff.type {
                case .added, .modified:
                    print("New/Modified Firebase/Realm object: \(diff.document.data())")
                    
                    // Add the document id to the properties dict
                    var dict = diff.document.data()
                    dict["id"] = diff.document.documentID
                    
                    // Find the existing realm object or create a new one
                    if let realmObject = (realm.objects(T.self).filter { $0.id == diff.document.documentID }.first) {
                        // Update the object's properties
                        try! realm.write {
                            realmObject.set(with: dict)
                        }
                        
                        // Link the object with other realm objects
                        realmObject.link?(from: dict)
                    } else {
                        // Create the realm object and set its properties
                        let realmObject = T()
                        realmObject.set(with: dict)
                        
                        // Link the object with other realm objects
                        realmObject.link?(from: dict)
                        
                        // Add the new object to the realm database
                        try! realm.write {
                            realm.add(realmObject)
                        }
                    }
                case .removed:
                    print("Deleting Firebase/Realm object: \(diff.document.data())")
                    
                    // Find the existing realm object and delete it
                    if let realmObject = (realm.objects(T.self).filter { $0.id == diff.document.documentID }.first) {
                        try! realm.write {
                            realm.delete(realmObject)
                        }
                    } else {
                        print("WARN: Could not delete realm object with id: \(diff.document.documentID). It may have already been deleted.")
                    }
                }
            }
            
            // Trigger callback
            callback()
        }
    }
    
    func linkObject<T: RealmObject>(_ object: RealmObject, withProperty property: String, to classType: T.Type, at documentReference: DocumentReference) {
        // Get the default realm database
        let realm = try! Realm()
        
        // Try to find the existing realm object or download it
        if let realmObject = (realm.objects(T.self).filter { $0.id == documentReference.documentID }.first) {
            // Update the property on the original realm object
            try! realm.write {
                object.setValue(realmObject, forKey: property)
            }
        } else {
            print("Could not find realm object with id: \(documentReference.documentID). Downloading it now.")
            // Download the object from Firebase
            self.downloadObject(T.self, document: documentReference) { realmObject in
                // Update the property on the original realm object
                try! realm.write {
                    object.setValue(realmObject, forKey: property)
                }
            }
        }
    }
}

typealias DatabaseListener = UIViewController & DatabaseListenerProtocol

final class WeakRef<A: AnyObject> {
    weak var value: A?
    
    init(_ value: A) {
        self.value = value
    }
}

@objc protocol DatabaseListenerProtocol: AnyObject {
    @objc optional func updatedPeople()
    @objc optional func updatedCampuses()
    @objc optional func updatedMovements()
    @objc optional func updatedEvents()
    @objc optional func updatedResources()
    @objc optional func updatedCommunityGroups()
    @objc optional func updatedMinistryTeams()
    @objc optional func updatedMissions()
}

protocol DatabaseObject: DatabasePath {
    init?(dict: NSDictionary)
}

@objc protocol RealmObjectProtocol: DatabasePath {
    var id: String! { get set }
    
    func set(with dict: [String: Any])
    @objc optional func link(from dict: [String: Any])
}

typealias RealmObject = Object & RealmObjectProtocol
