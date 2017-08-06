//
//  MinistryTeam.swift
//  Cru
//
//  Created by Deniz Tumer on 3/2/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeam: NSObject, Codable {
    var id: String
    var parentMinistry: String
    var summary: String
    var ministryName: String
    var image: UIImage!
    var imageUrl: String
    var teamImage: UIImage!
    var teamImageUrl: String
    var leaders: [User]
    var parentMinName: String
    
    init?(dict: NSDictionary) {
        //required initialization of variables
        self.id = ""
        self.parentMinistry = ""
        self.ministryName = ""
        self.summary = ""
        self.image = UIImage(named: "event1")
        self.imageUrl = ""
        self.teamImage = UIImage(named: "event1")
        self.teamImageUrl = ""
        self.leaders = [User]()
        self.parentMinName = ""
        
        //grabbing dictionary values
        let dId = dict.object(forKey: "_id")
        let dParentMinistry = dict.object(forKey: "parentMinistry")
        let dSummary = dict.object(forKey: "description")
        let dMinistryName = dict.object(forKey: "name")
        let dImage = dict.object(forKey: "leadersImage")
        let dLeaders = dict.object(forKey: "leaders")
        
        //set up object
        if (dId != nil) {
            self.id = dId as! String
        }
        if (dParentMinistry != nil) {
            self.parentMinistry = dParentMinistry as! String
        }
        if (dSummary != nil) {
            self.summary = dSummary as! String
        }
        if (dMinistryName != nil) {
            self.ministryName = dMinistryName as! String
        }
        if (dImage != nil) {
            if let imageUrl = (dImage as AnyObject).object(forKey: "secure_url") {
                self.imageUrl = imageUrl as! String
            }
            else {
                print("error: no image to display")
            }
        }
        else {
            //if image is nil
            self.image = UIImage(named: "fall-retreat-still")
        }
        if let leaderDicts = dLeaders as? [[String:AnyObject]] {
            self.leaders = leaderDicts.map{
                User(dict: $0 as NSDictionary)
            }
        }
    }
    
    func toDictionary() -> NSDictionary {
        return [
            "id": self.id,
            "name": self.ministryName,
            "description": self.summary,
            "leaders": self.leaders,
            "imageUrl": self.imageUrl,
            "teamImageUrl": self.teamImageUrl
        ]
    }
    
    // MARK: Codable (Encodable & Decodable)
    enum CodingKeys: String, CodingKey {
        case id
        case parentMinistry
        case summary
        case ministryName
//        case image
        case imageUrl
//        case teamImage
        case teamImageUrl
        case leaders
        case parentMinName
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.ministryName = try values.decode(String.self, forKey: .ministryName)
        self.summary = try values.decode(String.self, forKey: .summary)
        self.parentMinistry = try values.decode(String.self, forKey: .parentMinistry)
        self.parentMinName = try values.decode(String.self, forKey: .parentMinName)
//        self.image = try values.decode(UIImage.self, forKey: .image)
        self.imageUrl = try values.decode(String.self, forKey: .imageUrl)
//        self.teamImage = try values.decode(UIImage.self, forKey: .teamImage)
        self.teamImageUrl = try values.decode(String.self, forKey: .teamImageUrl)
        self.leaders = try values.decode(Array.self, forKey: .leaders)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ministryName, forKey: .ministryName)
        try container.encode(summary, forKey: .summary)
        try container.encode(parentMinistry, forKey: .parentMinistry)
        try container.encode(parentMinName, forKey: .parentMinName)
//        try container.encode(image, forKey: .image)
        try container.encode(imageUrl, forKey: .imageUrl)
//        try container.encode(teamImage, forKey: .teamImage)
        try container.encode(teamImageUrl, forKey: .teamImageUrl)
        try container.encode(leaders, forKey: .leaders)
    }
}

/* Function for the Comparable & Equatable protocols */
func  < (lTeam: MinistryTeam, rTeam: MinistryTeam) -> Bool{
    if lTeam.parentMinName < rTeam.parentMinName {
        return true
    }
    else if lTeam.parentMinName > rTeam.parentMinName {
        return false
    }
    else if lTeam.parentMinName == rTeam.parentMinName {
        
        if lTeam.ministryName < rTeam.ministryName {
            return true
        }
        
        else {
            return false
        }
        
    }
    return false
}

func  ==(lTeam: MinistryTeam, rTeam: MinistryTeam) -> Bool{
    return lTeam.id == rTeam.id
}
