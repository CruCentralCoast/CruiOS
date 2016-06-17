//
//  Campus.swift
//  Cru
//
//  Created by Max Crane on 11/29/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Ministry: NSObject, NSCoding, Comparable{
    var name: String!
    var id: String!
    var campusId: String
    var feedEnabled: Bool!
    var imageUrl: String!
    var imageData: NSData?
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        id = aDecoder.decodeObjectForKey("id") as! String
        campusId = aDecoder.decodeObjectForKey("campusId") as! String
        feedEnabled = aDecoder.decodeObjectForKey("feedEnabled") as! Bool
        imageUrl = aDecoder.decodeObjectForKey("imgUrl") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(campusId, forKey: "campusId")
        aCoder.encodeObject(feedEnabled, forKey: "feedEnabled")
        aCoder.encodeObject(imageUrl, forKey: "imgUrl")
    }
    
    init(dict: NSDictionary) {
        self.name = dict["name"] as! String
        self.id = dict["_id"] as! String
        self.campusId = dict["campus"] as! String
        self.feedEnabled = false // crashes without this shit

        if dict["imageLink"] != nil {
            self.imageUrl = dict["imageLink"] as! String
        
            if imageUrl.rangeOfString("https:") == nil{
                self.imageUrl = "https:" + imageUrl
            }
        }
        //Default will be the cru logo
        else {
            self.imageUrl = "http://cruatucf.com/wordpress/wp-content/uploads/2012/08/cru_logo_screen.jpg"
        }
        
    }
    
    init(name: String, id: String, campusId: String, feedEnabled: Bool, imgUrl: String){
        self.name = name
        self.id = id
        self.campusId = campusId
        self.feedEnabled = feedEnabled
        self.imageUrl = imgUrl
    }
    
    init(name: String, id: String, campusId: String, imgUrl: String){
        self.name = name
        self.id = id
        self.campusId = campusId
        self.feedEnabled = false
        self.imageUrl = imgUrl
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let obj = object as? Ministry{
            //return obj.name == self.name
            return obj.id == self.id
        }
        else{
            return false
        }
    }
    
}

func  <(lCampus: Ministry, rCampus: Ministry) -> Bool{
    return lCampus.name < rCampus.name
}