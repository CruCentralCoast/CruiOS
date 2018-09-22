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
    
    lazy private var database: Firestore! = {
        return Firestore.firestore()
    }()
    
    // Firebase listeners for each data type
    private var personListener: ListenerRegistration?
    private var campusListener: ListenerRegistration?
    private var movementListener: ListenerRegistration?
    private var eventListener: ListenerRegistration?
    private var resourceListener: ListenerRegistration?
    private var communityGroupListener: ListenerRegistration?
    private var ministryTeamListener: ListenerRegistration?
    private var missionListener: ListenerRegistration?
    
    // Objects listening to changes in the database
    private var listeners: [WeakRef<DatabaseListener>] = []
    
    private init() {
        // Handle database migrations
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // Added Person.movements
                }
                else if (oldSchemaVersion < 2) {
                    //Added Mission.url
                }
        })
    }
    
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
                    print("New/Modified Firebase/Realm object: \(T.className())")
                    
                    // Add the document id to the properties dict
                    var dict = diff.document.data()
                    dict["id"] = diff.document.documentID
                    
                    // Find the existing realm object or create a new one
                    if let realmObject = (realm.objects(T.self).filter { $0.id == diff.document.documentID }.first) {
                        // Try to update the object's properties
                        try! realm.write {
                            if !realmObject.set(with: dict) {
                                print("WARN: \(T.className())'s properties could not be updated.")
                            }
                        }
                        
                        // Update the object's relations
                        realmObject.relate?(with: dict)
                    } else {
                        // Try to create the realm object and set its properties
                        let realmObject = T()
                        if realmObject.set(with: dict) {
                        
                            // Update the object's relations
                            realmObject.relate?(with: dict)
                            
                            // Add the new object to the realm database
                            try! realm.write {
                                realm.add(realmObject)
                            }
                        } else {
                            print("WARN: New \(T.className())'s properties could not be updated.")
                        }
                    }
                case .removed:
                    print("Deleting Firebase/Realm object: \(T.className())")
                    
                    // Find the existing realm object and delete it
                    if let realmObject = (realm.objects(T.self).filter { $0.id == diff.document.documentID }.first) {
                        try! realm.write {
                            realm.delete(realmObject)
                        }
                    } else {
                        print("WARN: Could not delete realm object \(T.className()) with id: \(diff.document.documentID). It may have already been deleted.")
                    }
                }
            }
            
            // Trigger callback
            callback()
        }
    }
    
    func assignRelation<T: RealmObject>(_ property: String, on firstObject: RealmObject, with documentReference: DocumentReference, ofType secondObjectType: T.Type) {
        // Get the default realm database
        let realm = try! Realm()
        
        // Try to find the second object in the realm database or download it
        if let secondObject = (realm.objects(T.self).filter { $0.id == documentReference.documentID }.first) {
            // Assign the relation on the first object
            try! realm.write {
                firstObject.setValue(secondObject, forKey: property)
            }
        } else {
            print("Could not find realm object with id: \(documentReference.documentID). Downloading it now.")
            // Download the object from Firebase
            self.downloadObject(T.self, reference: documentReference) { secondObject in
                // Assign the relation on the first object
                try! realm.write {
                    firstObject.setValue(secondObject, forKey: property)
                }
            }
        }
    }
    
    func assignRelationList<T: RealmObject>(_ property: String, on firstObject: RealmObject, with array: [DocumentReference], ofType secondObjectType: T.Type) {
        // Get the default realm database
        let realm = try! Realm()
        
        // Reset the list
        try! realm.write {
            if let relationList = firstObject.value(forKey: property) as? List<T> {
                relationList.removeAll()
            }
        }
        
        // Assign each object separately since some may need to be downloaded
        for documentReference in array {
            // Try to find the second object in the realm database or download it
            if let secondObject = (realm.objects(T.self).filter { $0.id == documentReference.documentID }.first) {
                // Update the relation on the first object
                try! realm.write {
                    // Add the second object to the existing relation list
                    if let relationList = firstObject.value(forKey: property) as? List<T> {
                        relationList.append(secondObject)
                    } else {
                        print("WARN: Relation list could not be found on \(firstObject.className()) named: \(property)")
                    }
                }
            } else {
                print("Could not find realm object with id: \(documentReference.documentID). Downloading it now.")
                // Download the object from Firebase
                self.downloadObject(T.self, reference: documentReference) { secondObject in
                    // Update the relation on the first object
                    try! realm.write {
                        // Add the second object to the existing relation list
                        if let relationList = firstObject.value(forKey: property) as? List<T> {
                            relationList.append(secondObject)
                        } else {
                            print("WARN: Relation list could not be found on \(firstObject.className()) named: \(property)")
                        }
                    }
                }
            }
        }
    }
    
    /// Download a single object from Firebase. Once downloaded, update the associated Realm object
    /// or create a new one. Only the Realm object's properties are updated here, not its relations.
    /// This method should NOT be used to download a collection of objects since relations are not
    /// updated. See the listenForChangesInCollection() method for downloading collections.
    private func downloadObject<T: RealmObject>(_ classType: T.Type, reference: DocumentReference, completion: ((T)->Void)? = nil) {
        reference.getDocument { (document, error) in
            // Handle failure
            guard let document = document else {
                print("ERROR: Failed to download \(T.className()) reference \(reference.documentID) from database: \(error!)")
                return
            }
            guard document.exists else {
                print("WARN: \(T.className()) reference \(document.documentID) does not exist in database.")
                return
            }
            
            // Add the document id to the properties dict
            var dict = document.data()!
            dict["id"] = document.documentID
            
            // Get the default realm database
            let realm = try! Realm()
            
            // Find the existing realm object or create a new one
            let objects = realm.objects(T.self)
            if let realmObject = (objects.filter { $0.id == document.documentID }.first) {
                // Try to update the object's properties
                try! realm.write {
                    if !realmObject.set(with: dict) {
                        print("WARN: \(T.className())'s properties could not be updated.")
                    }
                }
                completion?(realmObject)
            } else {
                // Try to create the realm object and set its properties
                let realmObject = T()
                if realmObject.set(with: dict) {
                
                    // Add the new object to the realm database
                    try! realm.write {
                        realm.add(realmObject)
                    }
                    completion?(realmObject)
                } else {
                    print("WARN: New \(T.className())'s properties could not be updated.")
                }
            }
        }
    }
}

extension DatabaseManager {
    func subscribeToDatabaseUpdates(_ subscriber: DatabaseListener) {
        // Add subscriber if not already in list
        if !(self.listeners.contains { return ($0.value != nil) && ($0.value! == subscriber) }) {
            self.listeners.append(WeakRef(subscriber))
        }
    }
    
    func getPeople() -> Results<Person> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let people = realm.objects(Person.self)
        
        // Ensure only one listener is created
        if self.personListener == nil {
            // Listen for Firebase updates on this collection
            self.personListener = self.listenForChangesInCollection(Person.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedPeople?() }
            }
        }
        return people
    }
    
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
    
    func getEvents() -> Results<Event> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let events = realm.objects(Event.self)
        
        // Ensure only one listener is created
        if self.eventListener == nil {
            // Listen for Firebase updates on this collection
            self.eventListener = self.listenForChangesInCollection(Event.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedEvents?() }
            }
        }
        return events
    }
    
    func getCommunityGroups() -> Results<CommunityGroup> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let communityGroups = realm.objects(CommunityGroup.self)
        
        // Ensure only one listener is created
        if self.communityGroupListener == nil {
            // Listen for Firebase updates on this collection
            self.communityGroupListener = self.listenForChangesInCollection(CommunityGroup.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedCommunityGroups?() }
            }
        }
        return communityGroups
    }
    
    func getMinistryTeams() -> Results<MinistryTeam> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let ministryTeams = realm.objects(MinistryTeam.self)
        
        // Ensure only one listener is created
        if self.ministryTeamListener == nil {
            // Listen for Firebase updates on this collection
            self.ministryTeamListener = self.listenForChangesInCollection(MinistryTeam.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedMinistryTeams?() }
            }
        }
        return ministryTeams
    }
    
    func getMissions() -> Results<Mission> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let missions = realm.objects(Mission.self)
        
        // Ensure only one listener is created
        if self.missionListener == nil {
            // Listen for Firebase updates on this collection
            self.missionListener = self.listenForChangesInCollection(Mission.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedMissions?() }
            }
        }
        return missions
    }
    
    func getResources() -> Results<Resource> {
        // Get the default realm database
        let realm = try! Realm()
        // Get an always up-to-date list of realm objects of the given type
        let resources = realm.objects(Resource.self)
        
        // Ensure only one listener is created
        if self.resourceListener == nil {
            // Listen for Firebase updates on this collection
            self.resourceListener = self.listenForChangesInCollection(Resource.self) {
                // Attempt to call the appropriate callback on each listener
                self.listeners.forEach { $0.value?.updatedResources?() }
            }
        }
        return resources
    }
}

final class WeakRef<A: AnyObject> {
    weak var value: A?
    
    init(_ value: A) {
        self.value = value
    }
}

typealias DatabaseListener = NSObject & DatabaseListenerProtocol

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

typealias RealmObject = Object & RealmObjectProtocol

@objc protocol RealmObjectProtocol: DatabasePath {
    var id: String! { get set }
    
    /// Set the properties on a Realm object.
    func set(with dict: [String: Any]) -> Bool
    /// Set the relations on a Realm object.
    @objc optional func relate(with dict: [String: Any])
}
