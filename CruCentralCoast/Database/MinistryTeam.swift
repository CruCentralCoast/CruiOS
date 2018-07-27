//
//  MinistryTeam.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import RealmSwift

class MinistryTeam: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var summary: String!
    @objc dynamic var imageLink: String?
    
    // Relations
    @objc dynamic var movement: Movement?
    let leaders = List<Person>()
    /// Inverse relationship that is auto-updated
    let members = LinkingObjects(fromType: Person.self, property: "ministryTeams")
    
    func set(with dict: [String : Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let summary = dict["description"] as? String else { return }
        
        self.id = id
        self.name = name
        self.summary = summary
        self.imageLink = dict["teamImageLink"] as? String
    }
    
    func relate(with dict: [String : Any]) {
        // TODO
    }
}
