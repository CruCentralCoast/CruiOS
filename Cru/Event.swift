//
//  Event.swift
//  Cru
//  This class stores the data for an event, such as its ID, description, start time, end time, and other data.
//
//  Created by Erica Solum on 11/24/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//
// Modified by Deniz Tumer on 3/4/16.

import UIKit
import ImageLoader

class Event: Equatable {
    // MARK: Properties
    static let ministriesField = "ministries"
    static let endDateField = "endDate"
    
    //properties in the database for each event
    var id: String
    var url: String
    var description: String
    var name: String
    var notificationDate: String? //notification date is not applicable for every event
    var parentMinistry: String
    var imageSquare: UIImage!
    var imageSquareUrl: String
    var notifications: [String]
    var parentMinistries: [String]
    var rideSharingEnabled: Bool
    var endDate: String
    var endNSDate: Date
    var startDate: String
    var startNSDate: Date
    var location: NSDictionary?
    var locationTBD: Bool
    var image: UIImage!
    var imageUrl: String
    var rideshareEnabled: Bool?
    
    init?() {
        self.id = ""
        self.url = ""
        self.description = ""
        self.name = ""
        self.notificationDate = ""
        self.parentMinistry = ""
        self.imageSquare = UIImage(named: "event2")
        self.imageSquareUrl = ""
        self.notifications = [String]()
        self.parentMinistries = [String]()
        self.rideSharingEnabled = true
        self.endDate = ""
        self.endNSDate = Date()
        self.startDate = ""
        self.startNSDate = Date()
        self.image = UIImage(named: "event1")
        self.imageUrl = ""
        self.location = NSDictionary()
        self.locationTBD = true
        self.rideshareEnabled = false
    }
    
    
    convenience init?(dict : NSDictionary) {
        //init all required variables
        self.init()
        
        //grab dictionary objects
        if let enabled = dict["rideSharing"] as? Bool{
            self.rideSharingEnabled = enabled
        }
        if let dId = dict["_id"] {
            self.id = dId as! String
        }
        if let dUrl = dict["url"] {
            self.url = dUrl as! String
        }
        if let dDescription = dict["description"] {
            self.description = dDescription as! String
        }
        if let dName = dict["name"] {
            self.name = dName as! String
        }
        if let dNotificationDate = dict["notificationDate"] {
            self.notificationDate = dNotificationDate as? String
        }
        if let dParentMinistry = dict["parentMinistry"] {
            self.parentMinistry = dParentMinistry as! String
        }
        if let dImageSquare = dict["imageSquare"] {
            if let imageUrl = (dImageSquare as AnyObject).object(forKey: "url") {
                self.imageSquareUrl = imageUrl as! String
//                print("SQUARE IMAGE: " + (imageUrl as! String))
            }
        }
        if let dNotifications = dict["notifications"] {
            self.notifications = dNotifications as! [String]
        }
        if let dParentMinistries = dict[Event.ministriesField] {
            self.parentMinistries = dParentMinistries as! [String]
        }
        if let dRideSharingEnabled = dict["rideSharingEnabled"] {
            self.rideSharingEnabled = dRideSharingEnabled as! Bool
        }
        if let dEndDate = dict[Event.endDateField] {
            self.endNSDate = GlobalUtils.dateFromString(dEndDate as! String)
        }
        if let dStartDate = dict["startDate"] {
            self.startNSDate = GlobalUtils.dateFromString(dStartDate as! String)
        }
        if let dLocation = dict["location"] {
            self.location = dLocation as? NSDictionary
        }
        if let dImageLink = dict["imageLink"] {
            self.imageUrl = dImageLink as! String
        }
        if let dLocationTBD = dict["locationTBD"] {
            self.locationTBD = dLocationTBD as! Bool
        }
        
//        if let dImage = dict["image"] {
//            if let imageUrl = dImage.objectForKey("url") {
//                self.imageUrl = imageUrl as! String
////                print("eventName: " + self.name + ": " + self.imageUrl)
//            }
//        }
    }
    
//    //function for sorting events by date
//    class func sortEventsByDate(event1: Event, event2: Event) -> Bool {
//        return event1.startNSDate.compare(event2.endNSDate) == .OrderedAscending
//    }
    
    //return the location as a string
    func getLocationString() -> String {
        if locationTBD {
            return "TBD"
        }
        if location != nil {
            var street: String
            var suburb: String
            var country: String
            
            if let str = location!.object(forKey: "street1") {
                street = str as! String
            }
            else {
                street = "TBD"
            }
            if let str = location!.object(forKey: "suburb") {
                suburb = str as! String
            }
            else {
                suburb = "TBD"
            }
            
            return  street + ", " + suburb
        }
        
        return ""
    }
    
    //Returns address without city, state or zipcode
    func getStreetString() -> String {
        if location != nil {
            let street = location!.object(forKey: "street1") as! String
            return  street
        }
        return ""
    }
    
    //Returns address without city, state or zipcode
    func getSuburbString() -> String {
        if location != nil {
            let suburb = location!.object(forKey: "suburb") as! String
            let state = location!.object(forKey: "state") as! String
            return  "\(suburb), \(state)"
        }
        return ""
    }
    
    func getTime()->String{
        return GlobalUtils.stringFromDate(startNSDate, format: "M/d/YYYY") + "\n" +
               GlobalUtils.stringFromDate(startNSDate, format: "h:mm a")
        
    }
    func getStartTime()-> String{
        return GlobalUtils.stringFromDate(startNSDate, format: "h:mm")
    }
    
    func getEndTime() -> String{
        return GlobalUtils.stringFromDate(endNSDate, format: "h:mm")

    }
    
    func getEndDate() -> String {
        return GlobalUtils.stringFromDate(endNSDate, format: "MMM d, YYYY")
    }
    
    func getAmOrPm()->String{
        return GlobalUtils.stringFromDate(startNSDate, format: "a")
    }
    
    func getShortStartDay() -> String {
        return GlobalUtils.stringFromDate(startNSDate, format: "MMM d")
    }
    
    func getEndAmOrPm() -> String {
        return GlobalUtils.stringFromDate(endNSDate, format: "a")
    }
    
    func getWeekday() ->String{
        let str = GlobalUtils.stringFromDate(startNSDate, format: "EE")
        return str.uppercased()
    }
    
    static func eventsWithRideShare(_ eventList : [Event])->[Event]{
        var filteredList = [Event]()
        
        for event in eventList{
            if event.rideSharingEnabled {
                filteredList.append(event)
            }
        }
        
        return filteredList
    }
}

func  ==(lEvent: Event, rEvent: Event) -> Bool{
    return lEvent.id == rEvent.id
}
