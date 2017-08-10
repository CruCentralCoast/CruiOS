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
//        self.image = UIImage(named: "fall-retreat-still")
        self.imageUrl = ""
//        self.teamImage = UIImage(named: "event1")
        self.teamImageUrl = ""
        self.leaders = [User]()
        
        // Set the image if it exists
        if let imageDict = dict.object(forKey: "leadersImage") as? [String:AnyObject], let imageUrl = imageDict["secure_url"] as? String {
            self.imageUrl = imageUrl
        }
        
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
    
    // MARK: Codable (Encodable & Decodable)
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case parentMinistry
        case parentMinistryName
        case summary
//        case image
        case imageUrl
//        case teamImage
        case teamImageUrl
        case leaders
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.parentMinistry = try values.decode(String.self, forKey: .parentMinistry)
        self.parentMinistryName = try values.decode(String.self, forKey: .parentMinistryName)
        self.summary = try values.decode(String.self, forKey: .summary)
//        self.image = try values.decode(UIImage.self, forKey: .image)
        self.imageUrl = try values.decode(String.self, forKey: .imageUrl)
//        self.teamImage = try values.decode(UIImage.self, forKey: .teamImage)
        self.teamImageUrl = try values.decode(String.self, forKey: .teamImageUrl)
        self.leaders = try values.decode(Array.self, forKey: .leaders)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(parentMinistry, forKey: .parentMinistry)
        try container.encode(parentMinistryName, forKey: .parentMinistryName)
        try container.encode(summary, forKey: .summary)
//        try container.encode(image, forKey: .image)
        try container.encode(imageUrl, forKey: .imageUrl)
//        try container.encode(teamImage, forKey: .teamImage)
        try container.encode(teamImageUrl, forKey: .teamImageUrl)
        try container.encode(leaders, forKey: .leaders)
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
