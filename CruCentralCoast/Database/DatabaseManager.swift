//
//  DatabaseManager.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import Firebase

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
    
    func getCommunityGroup(_ completion: @escaping ([CommunityGroup])->Void) {
        getData(completion)
    }
    
    func getMinistryTeam(_ completion: @escaping ([MinistryTeam])->Void) {
        getData(completion)
    }
    
    func getMission(_ completion: @escaping ([Missions])->Void) {
        getData(completion)
    }
}

protocol DatabaseObject: DatabasePath {
    init?(dict: NSDictionary)
}
