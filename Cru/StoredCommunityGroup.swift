//
//  StoredCommunityGroup.swift
//  Cru
//
//  Version of the CommunityGroupClass that can be stored in UserDefaults.
//
//  Created by Erica Solum on 8/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class StoredCommunityGroup: NSObject, NSCoding {
    
    // MARK: - Properties
    var id = ""
    var name = ""
    var desc = ""
    var dayOfWeek = ""
    var stringTime = ""
    var parentMinistryName = ""
    var leaderNames = [String]() // ids of leaders
    var imgURL = ""
    var role = ""
    
    init(group: CommunityGroup, role: String) {
        self.id = group.id
        self.name = group.name
        self.desc = group.desc
        self.dayOfWeek = group.dayOfWeek
        self.stringTime = group.stringTime
        self.parentMinistryName = group.parentMinistryName
        self.imgURL = group.imgURL
        for leader in group.leaders {
            leaderNames.append(leader.name)
        }
        self.role = role
    }
    
    //init for the decoder and whatnot
    init?(id: String, name: String, desc: String, dayOfWeek: String, stringTime: String, parentMinistryName: String, leaderNames: [String],imgURL: String, role: String) {
        self.id = id
        self.name = name
        self.desc = desc
        self.dayOfWeek = dayOfWeek
        self.stringTime = stringTime
        self.parentMinistryName = parentMinistryName
        self.imgURL = imgURL
        self.leaderNames = leaderNames
        self.role = role
    }
    
    //Returns a displayable string with the leaders' names
    func getLeaderString() ->String {
        var str = ""
        for lead in leaderNames {
            str.append(lead + ", ")
        }
        return str
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let desc = aDecoder.decodeObject(forKey: "desc") as? String,
            let dayOfWeek = aDecoder.decodeObject(forKey: "dayOfWeek") as? String,
            let stringTime = aDecoder.decodeObject(forKey: "stringTime") as? String,
            let parentMinistryName = aDecoder.decodeObject(forKey: "parentMinistryName") as? String,
            let leaderNames = aDecoder.decodeObject(forKey: "leaderNames") as? [String],
            let imgURL = aDecoder.decodeObject(forKey: "imgURL") as? String,
            let role = aDecoder.decodeObject(forKey: "role") as? String
            
            else { return nil }
        
        self.init(
            id: id, name: name, desc: desc, dayOfWeek: dayOfWeek, stringTime: stringTime, parentMinistryName: parentMinistryName, leaderNames: leaderNames, imgURL: imgURL, role: role
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.desc, forKey: "desc")
        aCoder.encode(self.dayOfWeek, forKey: "dayOfWeek")
        aCoder.encode(self.stringTime, forKey: "stringTime")
        aCoder.encode(self.parentMinistryName, forKey: "parentMinistryName")
        aCoder.encode(self.leaderNames, forKey: "leaderNames")
        aCoder.encode(self.imgURL, forKey: "imgURL")
        aCoder.encode(self.role, forKey: "role")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? StoredCommunityGroup {
            return self.id == other.id
        } else {
            return false
        }
    }

}
