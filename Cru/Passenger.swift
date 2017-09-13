//
//  Passenger.swift
//  Cru
//
//  Created by Max Crane on 2/23/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Passenger: Comparable, Equatable {
    var id = ""
    var name = ""
    var phone = ""
    var direction = ""
    var event = ""
    var gender_pref = 0
    var has_driver = false
    var location = [String: String]()
    
    init(dict: NSDictionary){
        if (dict.object(forKey: "_id") != nil){
            id = dict.object(forKey: "_id") as! String
        }
        if (dict.object(forKey: "name") != nil){
            name = dict.object(forKey: "name") as! String
        }
        if (dict.object(forKey: "phone") != nil){
            phone = dict.object(forKey: "phone") as! String
        }
        if (dict.object(forKey: "direction") != nil){
            direction = dict.object(forKey: "direction") as! String
        }
        if (dict.object(forKey: "event") != nil){
            event = dict.object(forKey: "event") as! String
        }
        if (dict.object(forKey: "gender_pref") != nil){
            gender_pref = dict.object(forKey: "gender_pref") as! Int
        }
        if (dict.object(forKey: "has_driver") != nil){
            has_driver = dict.object(forKey: "has_driver") as! Bool
        }
        if (dict.object(forKey: "location") != nil){
            location = dict.object(forKey: "location") as! [String: String]
        }
    }
}
func  <(lPas: Passenger, rPas: Passenger) -> Bool{
    return rPas.name < lPas.name
}
func  ==(lPas: Passenger, rPas: Passenger) -> Bool{
    return lPas.name == rPas.name && lPas.phone == rPas.phone && lPas.id == rPas.id
}
