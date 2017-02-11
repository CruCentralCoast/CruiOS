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
        name = aDecoder.decodeObject(forKey: "name") as! String
        id = aDecoder.decodeObject(forKey: "id") as! String
        feedEnabled = aDecoder.decodeObject(forKey: "feedEnabled") as! Bool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(feedEnabled, forKey: "feedEnabled")
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
    
    override func isEqual(_ object: Any?) -> Bool {
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
