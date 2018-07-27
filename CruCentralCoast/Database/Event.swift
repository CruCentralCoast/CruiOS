//
//  Event.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class Event: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var title: String!
    @objc dynamic var summary: String!
    @objc dynamic var startDate: Date!
    @objc dynamic var endDate: Date!
    @objc dynamic var imageLink: String?
    @objc dynamic var facebookUrl: String?
    @objc dynamic var location: Location?
    
    // Relations
    let movements = List<Movement>()
    
    var image: UIImage?
    
    func set(with dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let title = dict["name"] as? String,
            let summary = dict["description"] as? String,
            let startDate = dict["startDate"] as? Date,
            let endDate = dict["endDate"] as? Date else { return }
        
        self.id = id
        self.title = title
        self.summary = summary
        self.startDate = startDate
        self.endDate = endDate
        self.imageLink = dict["imageLink"] as? String
        self.facebookUrl = dict["url"] as? String
        self.location = Location(dict: dict["location"] as? NSDictionary)
    }
    
    func relate(with dict: [String: Any]) {
        if let movementsArray = dict["ministries"] as? [DocumentReference] {
            DatabaseManager.instance.assignRelationList("movements", on: self, with: movementsArray, ofType: Movement.self)
        }
    }
}