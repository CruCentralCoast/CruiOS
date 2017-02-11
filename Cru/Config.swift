//
//  Config.swift
//  Cru
//
//  Created by Peter Godkin on 12/1/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

struct Config {
    static let serverUrl = "http://ec2-52-39-130-135.us-west-2.compute.amazonaws.com:3001/"
    static let serverEndpoint = serverUrl + "api/"
    static let name = "name"
    static let campusIds = "campuses"
    static let globalTopic = "/topics/global"
    static let gcmIdField = "gcmId"
    static let googleAPIKey = "AIzaSyBxo_oBsj-cNhzynsF65sHjMBEdIhgJr_Q"
    static let instagramUsername = "crucentralcoast"
    static func gcmId()->String{
        return CruClients.getSubscriptionManager().loadGCMToken()
    }
    static var simulatorMode: Bool{
        get{
            #if (arch(i386) || arch(x86_64)) && os(iOS)
                return true
            #else
                return false
            #endif
        }
    }
    static let leaderApiKey = "LeaderAPIKey"
    static let username = "username"
    static let ridesReceiving = "ridesReceiving"
    static let ridesOffering = "ridesOffering"
    static let communityGroupKey = "CommunityGroup"
    
    static let campusKey = "campusKey"
    static let ministryKey = "ministryKey"
    
    /* Modal Configurations: Used on the introduction page and create ride */
    static let backgroundViewOpacity: CGFloat = 0.7
    static let modalBackgroundRadius: CGFloat = 15.0
    
    /* Configurations for Events */
    //reuse identifier for event collection cells
    static let eventReuseIdentifier = "event"
    //resourse loader key for events
    static let eventResourceLoaderKey = "event"
    
    /* Configurations for Ministry Teams */
    //reuse identifier for collection cells in Ministry Teams
    static let ministryTeamReuseIdentifier = "ministryteam"
    //identifier for ministry team resource loading
    static let ministryTeamResourceLoaderKey = "ministryteam"
    //configuration key for NSUserDefaults ministry teams
    static let ministryTeamNSDefaultsKey = "ministryTeams"
    
    //LOCAL STORAGE KEYS
    static let eventStorageKey = "events"
    static let userStorageKey = "user"
    static let ministryStorageKey = "ministries"
    static let ministryTeamStorageKey = "ministryTeams"
    
    // Modal header and footer text color
    static let textColor = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 1.0)
    // Modal background color
    static let introModalBackgroundColor = UIColor.white
    
    // Content View Color For Modals
    static let introModalContentColor = UIColor(red: 0.8824, green: 0.8824, blue: 0.8824, alpha: 1.0)
    // Content Text Color
    static let introModalContentTextColor = UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.0)
    static let fontName = "FreightSans Pro"
    static let fontBold = "FreightSansProMedium-Regular"
    
    /* Image names */
    static let noConnectionImageName = "server-error"
    static let noRidesImageName = "no-rides"
    static let noRidesForEvent = "no-rides-for-event"
    static let noCampusesImage = "no-subscribed-campuses"
    static let noPassengersImage = "no-passengers"
    static let campusImage = "campusImage"
    static let communityImage = "communityImage"
    static let noEventsImage = "no-events"
}
