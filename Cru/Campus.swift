//
//  Campus.swift
//  Cru
//
//  Created by Max Crane on 11/29/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Campus: NSObject, NSCoding, Comparable {
    let name: String!
    let id: String!
    var feedEnabled: Bool!
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        id = aDecoder.decodeObjectForKey("id") as! String
        feedEnabled = aDecoder.decodeObjectForKey("feedEnabled") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(feedEnabled, forKey: "feedEnabled")
    }

    init(name: String, id: String, feedEnabled: Bool){
        self.name = name
        self.id = id
        self.feedEnabled = feedEnabled
    }
    
    init(name: String, id: String){
        self.name = name
        self.id = id
        self.feedEnabled = false
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Campus{
            return obj.name == self.name
        }
        else{
            return false
        }
    }
    
    override var hashValue: Int {
        get {
            return id.hashValue
        }
    }

}

func  <(lCampus: Campus, rCampus: Campus) -> Bool{
    return lCampus.name < rCampus.name
}

func ==(lCampus: Campus, rCampus: Campus) -> Bool{
    return lCampus.id == rCampus.id
}