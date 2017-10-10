//
//  MinistryTeam.swift
//  Cru
//
//  Created by Deniz Tumer on 3/2/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeam: NSObject, NSCoding {
    var id: String
    var name: String
    var parentMinistry: String
    var parentMinistryName: String
    var summary: String
    var image: UIImage!
    var imageUrl: String
    var teamImage: UIImage!
    var teamImageUrl: String
    var leaders: [User]
    
    init?(dict: NSDictionary) {
        // Required initialization of variables
        self.id = dict.object(forKey: "_id") as? String ?? ""
        self.name = dict.object(forKey: "name") as? String ?? ""
        self.parentMinistry = dict.object(forKey: "parentMinistry") as? String ?? ""
        self.parentMinistryName = dict.object(forKey: "parentMinistryName") as? String ?? ""
        self.summary = dict.object(forKey: "description") as? String ?? ""
        self.teamImageUrl = dict.object(forKey: "teamImageLink") as? String ?? ""
//      self.image = UIImage(named: "fall-retreat-still")
        self.imageUrl = dict.object(forKey: "teamImageLink") as? String ?? ""
        self.leaders = [User]()
        
        // Set the leaders if they exist
        if let leaderDicts = dict.object(forKey: "leaders") as? [[String:AnyObject]] {
            self.leaders = leaderDicts.map {
                User(dict: $0 as NSDictionary)
            }
        }
    }
    
    func toDictionary() -> NSDictionary {
        return [
            "id": self.id,
            "name": self.name,
            "description": self.summary,
            "leaders": self.leaders,
            "imageUrl": self.imageUrl,
            "teamImageUrl": self.teamImageUrl
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.parentMinistry = aDecoder.decodeObject(forKey: "parentMinistry") as! String
        self.parentMinistryName = aDecoder.decodeObject(forKey: "parentMinistryName") as! String
        self.summary = aDecoder.decodeObject(forKey: "summary") as! String
        self.imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as! String
        self.teamImageUrl = aDecoder.decodeObject(forKey: "teamImageUrl") as! String
        self.leaders = aDecoder.decodeObject(forKey: "leaders") as! [User]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(parentMinistry, forKey: "parentMinistry")
        aCoder.encode(parentMinistryName, forKey: "parentMinistryName")
        aCoder.encode(summary, forKey: "summary")
        //        aCoder.encode(image, forKey: .image)
        aCoder.encode(imageUrl, forKey: "imageUrl")
        //        aCoder.encode(teamImage, forKey: .teamImage)
        aCoder.encode(teamImageUrl, forKey: "teamImageUrl")
        aCoder.encode(leaders, forKey: "leaders")
    }
}

/* Function for the Comparable & Equatable protocols */
func < (lTeam: MinistryTeam, rTeam: MinistryTeam) -> Bool{
    if lTeam.parentMinistryName < rTeam.parentMinistryName {
        return true
    } else if lTeam.parentMinistryName > rTeam.parentMinistryName {
        return false
    } else if lTeam.parentMinistryName == rTeam.parentMinistryName {
        return lTeam.name < rTeam.name
    }
    return false
}

func == (lTeam: MinistryTeam, rTeam: MinistryTeam) -> Bool{
    return lTeam.id == rTeam.id
}
