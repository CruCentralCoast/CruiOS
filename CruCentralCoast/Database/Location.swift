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
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var state: String?
    @objc dynamic var postcode: String?
    
    // Computed Properties
    var string: String {
        var locationString = ""
        if let street = self.street, !street.isEmpty, street != "TBD" {
            locationString += street
        }
        if let city = self.city, !city.isEmpty, city != "TBD" {
            locationString += ", \(city)"
        }
        if let state = self.state, !state.isEmpty, state != "TBD" {
            locationString += ", \(state)"
        }
        if let postcode = self.postcode, !postcode.isEmpty, postcode != "TBD" {
            locationString += ", \(postcode)"
        }
        let trimmedCharacters = CharacterSet(charactersIn: ",").union(.whitespaces)
        return locationString.trimmingCharacters(in: trimmedCharacters)
    }
    
    convenience init?(dict: NSDictionary?) {
        guard let dict = dict else { return nil }
        // Call realm initializer
        self.init()
        
        self.street = dict["street1"] as? String
        self.city = dict["suburb"] as? String
        self.state = dict["state"] as? String
        self.postcode = dict["postcode"] as? String
    }
}
