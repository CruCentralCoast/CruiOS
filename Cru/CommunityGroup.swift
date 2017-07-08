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
}


class CommunityGroup: Comparable, Equatable{

    // MARK: - Properties
    var id = ""
    var name = ""
    var description = ""
    var dayOfWeek = ""
    var meetingTime: Date!
    var stringTime = ""
    //var meetingTime = ""
    var parentMinistry = ""
    var leaderIDs = [String]() // ids of leaders
    var leaders = [CommunityGroupLeader]() // names of leaders
    var type = ""
    var imgURL = ""
    //var types = [String: String]() // for when groups have multiple types
    
    
    
    init(dict: NSDictionary) {
        if let id = dict[CommunityGroupKeys.id] as? String {
            self.id = id
        }
        
        if let name = dict[CommunityGroupKeys.name] as? String {
            self.name = name
        }
        
        if let desc = dict[CommunityGroupKeys.description] as? String {
            description = desc
        }
        
        if let day = dict[CommunityGroupKeys.dayOfWeek] as? String {
            dayOfWeek = day
        }
        
        if let time = dict[CommunityGroupKeys.meetingTime] as? String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            meetingTime = dateFormatter.date(from: time)
            
            if meetingTime == nil {
                stringTime = time
            }
        }
        else {
            meetingTime = Date()
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
           parentMinistry = min
        }
        
        
    }
    
    func getMeetingTime()->String{
        let format = "h:mm a"
        //let serverFormat = "E M d y H:m:s"
        //let serverFormat = "h:mm a"
  
        let formatter = GlobalUtils.getCommunityGroupsDateFormatter()
        
        
        if (meetingTime != nil ){
            return formatter.string(from: meetingTime)
        }
        else{
            return stringTime
        }
    }
    
    func getLeaderNames() {
        for lead in leaderIDs {
            //str.append(lead + ", ")
            CruClients.getServerClient().getById(DBCollection.User, insert: insertLeader, completionHandler: {
                success in
            }, id: lead)
        }
    }
    
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

func  ==(lGroup: CommunityGroup, rGroup: CommunityGroup) -> Bool{
    return lGroup.id == rGroup.id
}
