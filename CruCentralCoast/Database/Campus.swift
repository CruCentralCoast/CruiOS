//
//  Campus.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import RealmSwift

class Campus: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var imageLink: String?
    
    // Relations
    /// Inverse relationship that is auto-updated
    let movements = LinkingObjects(fromType: Movement.self, property: "campus")
    
    func set(with dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String else { return }
        
        self.id = id
        self.name = name
        self.imageLink = dict["imageLink"] as? String
    }
}
