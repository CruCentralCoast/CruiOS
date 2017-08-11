//
//  CommunityGroup.swift
//  Cru
//
//  Created by Max Crane on 5/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

//use to parse community group data to and from keystone db
struct CommunityGroupKeys {
    static let id = "_id"
    static let ministry = "ministry"
    static let type = "type"
    static let meetingTime = "meetingTime"
    static let description = "description"
    static let name = "name"
    static let dayOfWeek = "dayOfWeek"
    static let leaders = "leaders"
    static let imageURL = "imageURL"
    static let gender = "gender"
}


class CommunityGroup: NSObject, NSCoding, Comparable {

    // MARK: - Properties
    var id = ""
    var name = ""
    var desc = ""
    var dayOfWeek = ""
    var gender = ""
    var meetingTime = ""
    var stringTime = ""
    var parentMinistryID = ""
    var parentMinistryName = ""
    var leaderIDs = [String]() // ids of leaders
    var leaders = [CommunityGroupLeader]() // names of leaders
    var type = ""
    var imgURL = ""
    var role = ""
    //var types = [String: String]() // for when groups have multiple types
    
    init(dict: NSDictionary) {
        if let id = dict[CommunityGroupKeys.id] as? String {
            self.id = id
        }
        
        if let name = dict[CommunityGroupKeys.name] as? String {
            self.name = name
        }
        
        if let desc = dict[CommunityGroupKeys.description] as? String {
            self.desc = desc
        }
        
        if let day = dict[CommunityGroupKeys.dayOfWeek] as? String {
            dayOfWeek = day
        }
        
        if let time = dict[CommunityGroupKeys.meetingTime] as? String {
            self.meetingTime = time
            /*let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            meetingTime = dateFormatter.date(from: time) as Date!
            
            if meetingTime == nil {
                stringTime = time
            }*/
        }
        
        if let leadersDict = dict[CommunityGroupKeys.leaders] as? [String]{
            for lead in leadersDict{
                
                leaderIDs.append(lead)
            }
            //getLeaderNames()
        }
        if let type = dict[CommunityGroupKeys.type] as? String {
            self.type = type
        }
        
        if let url = dict[CommunityGroupKeys.imageURL] as? String {
            self.imgURL = url
        }
        
        if let min = dict[CommunityGroupKeys.ministry] as? String {
           self.parentMinistryID = min
        }
        
        if let gen = dict[CommunityGroupKeys.gender] as? String {
            self.gender = gen
        }
        
        self.role = "member"
        
        self.parentMinistryName = ""
        
    }
    
    //init for the decoder and whatnot
    init?(id: String, name: String, desc: String, dayOfWeek: String, meetingTime: String, parentMinistryID: String, parentMinistryName: String, leaderIDs: [String], leaders: [CommunityGroupLeader], type: String, imgURL: String, gender: String, role: String) {
        self.id = id
        self.name = name
        self.desc = desc
        self.dayOfWeek = dayOfWeek
        self.meetingTime = meetingTime
        self.parentMinistryID = parentMinistryID
        self.parentMinistryName = parentMinistryName
        self.leaderIDs = leaderIDs
        self.leaders = leaders
        self.type = type
        self.imgURL = imgURL
        self.gender = gender
        self.role = role
    }
    
    func getMeetingTime()->String{
        //let format = "h:mm a"
        //let serverFormat = "E M d y H:m:s"
        //let serverFormat = "h:mm a"
  
        /*let formatter = GlobalUtils.getCommunityGroupsDateFormatter()
        
        
        if (meetingTime != nil ){
            return formatter.string(from: meetingTime as Date)
        }
        else{
            return stringTime
        }*/
        
        return meetingTime
    }
    
    // Gets the names of the community group leaders from the database using the stored IDs
    func getLeaderNames() {
        for lead in leaderIDs {
            //str.append(lead + ", ")
            CruClients.getServerClient().getById(DBCollection.User, insert: insertLeader, completionHandler: {
                success in
            }, id: lead)
        }
    }
    
    //Returns a displayable string with the leaders' names
    func getLeaderString() ->String {
        var str = ""
        for lead in leaders {
            str.append(lead.name + ", ")
        }
        return str
    }
    
    func insertLeader(_ dict: NSDictionary) {
        let leader = CommunityGroupLeader(dict)
        leaders.append(leader)
        /*if let nameDict = dict[CommunityGroupLeaderKeys.name] as? [String:String]{
            
            if let first = nameDict[CommunityGroupLeaderKeys.firstName], let last = nameDict[CommunityGroupLeaderKeys.lastName] {
                leaderNames.append(first + " " + last)
            }
            

        }*/
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        /*var id = ""
        var name = ""
        var desc = ""
        var dayOfWeek = ""
        var meetingTime: Date!
        var stringTime = ""
        var parentMinistry = ""
        var leaderIDs = [String]() // ids of leaders
        var leaders = [CommunityGroupLeader]() // names of leaders
        var type = ""
        var imgURL = ""*/
        
        guard let id = aDecoder.decodeObject(forKey: "id") as? String,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let desc = aDecoder.decodeObject(forKey: "desc") as? String,
            let dayOfWeek = aDecoder.decodeObject(forKey: "dayOfWeek") as? String,
            let meetingTime = aDecoder.decodeObject(forKey: "meetingTime") as? String,
            let parentMinistryID = aDecoder.decodeObject(forKey: "parentMinistryID") as? String,
            let parentMinistryName = aDecoder.decodeObject(forKey: "parentMinistryName") as? String,
            let leaderIDs = aDecoder.decodeObject(forKey: "leaderIDs") as? [String],
            let leaders = aDecoder.decodeObject(forKey: "leaders") as? [CommunityGroupLeader],
            let type = aDecoder.decodeObject(forKey: "type") as? String,
            let gender = aDecoder.decodeObject(forKey: "gender") as? String,
            let imgURL = aDecoder.decodeObject(forKey: "imgURL") as? String,
            let role = aDecoder.decodeObject(forKey: "role") as? String
        
            else { return nil }
        
        
        self.init(
            id: id, name: name, desc: desc, dayOfWeek: dayOfWeek, meetingTime: meetingTime, parentMinistryID: parentMinistryID, parentMinistryName: parentMinistryName, leaderIDs: leaderIDs, leaders: leaders, type: type, imgURL: imgURL, gender: gender, role: role
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.desc, forKey: "desc")
        aCoder.encode(self.dayOfWeek, forKey: "dayOfWeek")
        aCoder.encode(self.meetingTime, forKey: "meetingTime")
        aCoder.encode(self.parentMinistryID, forKey: "parentMinistryID")
        aCoder.encode(self.parentMinistryName, forKey: "parentMinistryName")
        aCoder.encode(self.leaderIDs, forKey: "leaderIDs")
        aCoder.encode(self.leaders, forKey: "leaders")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.gender, forKey: "gender")
        aCoder.encode(self.imgURL, forKey: "imgURL")
        aCoder.encode(self.role, forKey: "role")
    }
    
//    static func  ==(lGroup: CommunityGroup, rGroup: CommunityGroup) -> Bool{
//        return lGroup.id == rGroup.id
//    }
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CommunityGroup {
            return id == object.id
        } else {
            return false
        }
    }
    
    
}

/* Function for the Comparable & Equatable protocols */
func  < (lGroup: CommunityGroup, rGroup: CommunityGroup) -> Bool{
    if(lGroup.name < rGroup.name){
        return true
    }
    else if(lGroup.name > rGroup.name){
        return false
    }
    return false
}


