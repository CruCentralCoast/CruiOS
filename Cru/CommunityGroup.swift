//
//  CommunityGroup.swift
//  Cru
//
//  Created by Max Crane on 5/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroup{

    var id: String!
    var name : String!
    var description: String!
    var meetingTime: String!
    //var leaders : [[String: AnyObject]]!
    var parentMinistry : String!
    var ministryName: String?
    var leaders = [User]()
    
    init(dict: NSDictionary) {
        id = dict["_id"] as? String
        name = dict["name"] as? String
        description = dict["description"] as? String
        if let dateStr = dict["meetingTime"] as? String {
            //the date is in a different format from other dates
            // just going to use the string for now
            meetingTime = dateStr//GlobalUtils.dateFromString(dateStr)
        }
        if let leadersDict  = dict["leaders"] as? [[String: AnyObject]]{
            for lead in leadersDict{
                leaders.append(User(dict: lead))
            }
        }
        parentMinistry = dict["parentMinistry"] as? String
    }
    
    func getMeetingTime()->String{
        let format = "E h:mm a"
        let serverFormat = "E M d y H:m:s"
  
        let formatter = GlobalUtils.getDefaultDateFormatter()//NSDateFormatter()
        //formatter.dateFormat = serverFormat
        
        if (meetingTime != nil && meetingTime.characters.count > 15){
            //let parsedMeetingTime = meetingTime.substringWithRange(Range<String.Index>(start: meetingTime.startIndex, end: meetingTime.endIndex.advancedBy(-14)))
            let meetingTimeAsDate = formatter.dateFromString(meetingTime)
            formatter.dateFormat = format
            
            if (meetingTimeAsDate != nil){
                return formatter.stringFromDate(meetingTimeAsDate!)
            }
            else{
                return ""
            }
        }
        else{
            return ""
        }
    }
}
