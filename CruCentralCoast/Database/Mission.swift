//
//  Mission.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import RealmSwift

class Mission: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var summary: String!
    @objc dynamic var startDate: Date!
    @objc dynamic var endDate: Date!
    @objc dynamic var imageLink: String?
    @objc dynamic var location: Location?
    
    // Relations
    /// Inverse relationship that is auto-updated
    let members = LinkingObjects(fromType: Person.self, property: "missions")
    
    func set(with dict: [String : Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let summary = dict["description"] as? String,
            let startDate = dict["startDate"] as? Date,
            let endDate = dict["endDate"] as? Date else { return }
        
        self.id = id
        self.name = name
        self.summary = summary
        self.startDate = startDate
        self.endDate = endDate
        self.location = Location(dict: dict["location"] as? NSDictionary)
        self.imageLink = dict["imageLink"] as? String
    }
}
