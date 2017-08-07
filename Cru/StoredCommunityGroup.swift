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
    var parentMinistry = ""
    var leaderNames = [String]() // ids of leaders
    var imgURL = ""
    
    init(group: CommunityGroup) {
        self.id = group.id
        self.name = group.name
        self.desc = group.desc
        self.dayOfWeek = group.dayOfWeek
        self.stringTime = group.stringTime
        self.parentMinistry = group.parentMinistry
        self.imgURL = group.imgURL
        for leader in group.leaders {
            leaderNames.append(leader.name)
        }
    }
    
    //init for the decoder and whatnot
    init?(id: String, name: String, desc: String, dayOfWeek: String, stringTime: String, parentMinistry: String, leaderNames: [String],imgURL: String) {
        self.id = id
        self.name = name
        self.desc = desc
        self.dayOfWeek = dayOfWeek
        self.stringTime = stringTime
        self.parentMinistry = parentMinistry
        self.imgURL = imgURL
        self.leaderNames = leaderNames
        
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
            let parentMinistry = aDecoder.decodeObject(forKey: "parentMinistry") as? String,
            let leaderNames = aDecoder.decodeObject(forKey: "leaderNames") as? [String],
            let imgURL = aDecoder.decodeObject(forKey: "imgURL") as? String
            
            else { return nil }
        
        self.init(
            id: id, name: name, desc: desc, dayOfWeek: dayOfWeek, stringTime: stringTime, parentMinistry: parentMinistry, leaderNames: leaderNames, imgURL: imgURL
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.desc, forKey: "desc")
        aCoder.encode(self.dayOfWeek, forKey: "dayOfWeek")
        aCoder.encode(self.stringTime, forKey: "stringTime")
        aCoder.encode(self.parentMinistry, forKey: "parentMinistry")
        aCoder.encode(self.leaderNames, forKey: "leaderNames")
        aCoder.encode(self.imgURL, forKey: "imgURL")
    }

}
