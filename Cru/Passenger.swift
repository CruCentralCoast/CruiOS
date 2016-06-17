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
    
    init(dict: NSDictionary){
        if (dict.objectForKey("_id") != nil){
            id = dict.objectForKey("_id") as! String
        }
        if (dict.objectForKey("name") != nil){
            name = dict.objectForKey("name") as! String
        }
        if (dict.objectForKey("phone") != nil){
            phone = dict.objectForKey("phone") as! String
        }
        if (dict.objectForKey("direction") != nil){
            direction = dict.objectForKey("direction") as! String
        }
    }
}
func  <(lPas: Passenger, rPas: Passenger) -> Bool{
    return rPas.name < lPas.name
}
func  ==(lPas: Passenger, rPas: Passenger) -> Bool{
    return lPas.name == rPas.name && lPas.phone == rPas.phone && lPas.id == rPas.id
}