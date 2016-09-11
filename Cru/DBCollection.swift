//
//  DBCollection.swift
//  Cru
//
//  Created by Peter Godkin on 3/12/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

enum DBCollection : String {
    
    case MinistryTeam = "ministryteams"
    case Ride = "rides"
    case Passenger = "passengers"
    case Ministry = "ministries"
    case Campus = "campuses"
    case SummerMission = "summermissions"
    case Resource = "resources"
    case Event = "events"
    case MinistyQuestion = "ministryquestions"
    case CommunityGroup = "communitygroups"
    case User = "users"
    case Question = "questions" //subsection of ministry
    case Leader = "leaders" //subsection of community group
    case ResourceTags = "resourcetags"
    
    func name()->String {
        return self.rawValue
    }
}