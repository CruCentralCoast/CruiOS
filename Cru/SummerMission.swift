//
//  SummerMission.swift
//  Cru
//
//  Created by Deniz Tumer on 6/1/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SummerMission {
    
    var id: String
    var description: String
    var name: String
    var url: String
    var cost: Double
    var leaders: String
    var startNSDate: Date
    var endNSDate: Date
    var location: NSDictionary?
    var imageLink: String
    
    init?() {
        self.id = ""
        self.description = ""
        self.name = ""
        self.url = ""
        self.cost = 0.0
        self.leaders = ""
        self.startNSDate = Date()
        self.endNSDate = Date()
        self.location = NSDictionary()
        self.imageLink = ""
    }
    
    convenience init?(dict: NSDictionary) {
        self.init()
        
        if let dId = dict["_id"] {
            self.id = dId as! String
        }
        if let dDescription = dict["description"] {
            self.description = dDescription as! String
        }
        if let dName = dict["name"] {
            self.name = dName as! String
        }
        if let dUrl = dict["url"] {
            self.url = dUrl as! String
        }
        if let dCost = dict["cost"] {
           self.cost = dCost as! Double
        }
        if let dLeaders = dict["leaders"] {
            self.leaders = dLeaders as! String
        }
        if let dStartDate = dict["startDate"] {
            self.startNSDate = GlobalUtils.dateFromString(dStartDate as! String)
        }
        if let dEndDate = dict["endDate"] {
            self.endNSDate = GlobalUtils.dateFromString(dEndDate as! String)
        }
        if let dLocation = dict["location"] {
            self.location = dLocation as? NSDictionary
        }
        if let dImageLink = dict["imageLink"] {
            self.imageLink = dImageLink as! String
        }
    }
    
    //return the location as a string
    func getLocationString() -> String {
        var retLoc = ""
        
        if location != nil {
            if let dSuburb = location!["suburb"] as? String {
                retLoc += dSuburb
            }
            
            if let dCountry = location!["country"] as? String {
                if retLoc != "" {
                    retLoc += ", "
                }
                retLoc += dCountry
            }
            
        }
        
        return retLoc
    }
}
