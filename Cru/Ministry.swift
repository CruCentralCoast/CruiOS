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
    var imageData: Data?
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        id = aDecoder.decodeObject(forKey: "id") as! String
        campusId = aDecoder.decodeObject(forKey: "campusId") as! String
        feedEnabled = aDecoder.decodeObject(forKey: "feedEnabled") as! Bool
        imageUrl = aDecoder.decodeObject(forKey: "imgUrl") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(campusId, forKey: "campusId")
        aCoder.encode(feedEnabled, forKey: "feedEnabled")
        aCoder.encode(imageUrl, forKey: "imgUrl")
    }
    
    init(dict: NSDictionary) {
        self.name = dict["name"] as! String
        self.id = dict["_id"] as! String
        self.campusId = dict["campus"] as! String
        self.feedEnabled = false // crashes without this shit

        if dict["imageLink"] != nil {
            self.imageUrl = dict["imageLink"] as! String
        
            if imageUrl.range(of: "https:") == nil{
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
    
    override func isEqual(_ object: Any?) -> Bool {
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
