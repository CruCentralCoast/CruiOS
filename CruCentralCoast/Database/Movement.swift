//
//  Movement.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class Movement: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var summary: String?
    @objc dynamic var imageLink: String?
    
    // Relations
    @objc dynamic var campus: Campus?
    /// Inverse relationship that is auto-updated
    let events = LinkingObjects(fromType: Event.self, property: "movements")
    
    func set(with dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String else { return }
        
        self.id = id
        self.name = name
        self.summary = dict["discription"] as? String
        self.imageLink = dict["imageLink"] as? String
    }
    
    func relate(with dict: [String: Any]) {
        if let campusReference = dict["campus"] as? DocumentReference {
            DatabaseManager.instance.assignRelation("campus", on: self, with: campusReference, ofType: Campus.self)
        }
    }
}
