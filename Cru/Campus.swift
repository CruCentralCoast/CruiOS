//
//  Campus.swift
//  Cru
//
//  Created by Max Crane on 11/29/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
//use to parse community group data to and from keystone db
struct CampusKeys {
    static let id = "_id"
    static let name = "name"
    static let url = "url"
    static let imageURL = "imageLink"
    static let location = "location"
}

class Campus: NSObject, NSCoding, Comparable {
    let name: String!
    let id: String!
    var feedEnabled: Bool!
    var imageURL: String!
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        id = aDecoder.decodeObject(forKey: "id") as! String
        feedEnabled = aDecoder.decodeObject(forKey: "feedEnabled") as! Bool
        if aDecoder.containsValue(forKey: "imageURL") {
            imageURL = aDecoder.decodeObject(forKey: "imageURL") as! String
        }
        else {
            imageURL = ""
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(feedEnabled, forKey: "feedEnabled")
        aCoder.encode(imageURL, forKey: "imageURL")
    }

    init(name: String, id: String, feedEnabled: Bool, imageURL: String){
        self.name = name
        self.id = id
        self.feedEnabled = feedEnabled
        self.imageURL = imageURL
    }
    
    init(name: String, id: String, imageURL: String){
        self.name = name
        self.id = id
        self.feedEnabled = false
        self.imageURL = imageURL
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
