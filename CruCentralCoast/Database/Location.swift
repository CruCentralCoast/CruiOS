//
//  Location.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    
    // Properties
    @objc dynamic var street: String!
    @objc dynamic var city: String!
    @objc dynamic var state: String!
    @objc dynamic var postcode: String!
    
    convenience init?(dict: NSDictionary?) {
        guard let dict = dict,
            let street = dict["street1"] as? String,
            let city = dict["suburb"] as? String,
            let state = dict["state"] as? String,
            let postcode = dict["postcode"] as? String else { return nil }
        // Call realm initializer
        self.init()
        
        self.street = street
        self.city = city
        self.state = state
        self.postcode = postcode
    }
}
