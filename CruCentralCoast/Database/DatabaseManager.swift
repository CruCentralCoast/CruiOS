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
}

protocol DatabaseObject: DatabasePath {
    init?(dict: NSDictionary)
}
