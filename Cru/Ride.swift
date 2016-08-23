//
//  Ride.swift
//  Cru
//
//  Created by Quan Tran on 1/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

//use to parse ride data to and from keystone db
struct RideKeys {
    static let id = "_id"
    static let direction = "direction"
    static let driverName = "driverName"
    static let driverNumber = "driverNumber"
    static let event = "event"
    static let gcm_id = "gcm_id"
    static let gender = "gender" //int
    static let radius = "radius" //int
    static let seats = "seats" //int
    static let v = "__v"
    static let time = "time" //some format that ends in Z
    static let location = "location" //dict
    static let passengers = "passengers" //list
}

//used to parse location into map for keystone db
struct LocationKeys {
    static let loc = "location"
    static let postcode = "postcode"
    static let street1 = "street1"
    static let city = "suburb"
    static let state = "state"
    static let country = "country"
}

struct LocKeys {
    static let loc = "location"
    static let postcode = "ZIP"
    static let street1 = "Street"
    static let city = "City"
    static let state = "State"
    static let country = "CountryCode"
}

//Used for display on detail screens
struct Labels{
    static let eventLabel = "Event:"
    static let eventTimeLabel = "Event Time:"
    static let eventAddressLabel = "Event Address:"
    static let departureDateLabel = "Departure Date:"
    static let departureTimeLabel = "Departure Time:"
    static let addressLabel = "Departure Address:"
    static let pickupRadius = "Pickup Radius:"
    static let seatsLabel = "Seats Offered:"
    static let seatsOfferLabel = "Seats Offering:"
    static let seatsLeftLabel = "Seats Available:"
    static let nameLabel = "Name:"
    static let phoneLabel = "Phone Number:"
    static let directionLabel = "Direction:"
    static let driverName = "Driver Name:"
    static let driverNumber = "Driver Number:"
    static let passengers = "Passengers:"
}

//used for validation errors on ride signup and edit forms
struct ValidationErrors{
    static let none = ""
    static let phoneUnauthorized = "Sorry, but it looks like you are not authorized to drive according to your phone number\nHint: a valid number is (123) 456-7890"
    static let noEvent = "Please pick an event"
    static let noDeparture = "Please provide a departure location"
    static let noSeats = "Please specify how many seats you would like to offer"
    static let badSeats = "Please enter a valid number of seats to offer"
    static let badTimeBefore = "Please select a time before the start of the event"
    static let badTimeBeforeStart = "Please select a time after the start of the event"
    static let noStreet = "Please provide an address with a valid street"
    static let noZip = "Please provide an address with a valid zipcode"
    static let noState = "Please provide an address with a valid state"
    static let noCity = "Please provide an address with a valid city"
    static let noPhone = "Please provide a phone number"
    static let badPhone = "Please provide a valid 10 digit phone number"
    static let noName = "Please provide a first and last name"
    static let badName = "Please provide a valid first and last name"
    static let badNumSeats = "Please provide a valid number of seats (" + String(RideConstants.minSeats) + " to " + String(RideConstants.maxSeats) + ")"
}

struct RideConstants{
    static let minSeats = 1
    static let maxSeats = 50
    
}

class Ride: Comparable, Equatable, TimeDetail {
    var id: String = ""
    var direction: String = ""
    var seats: Int = -1
    var radius: Int = -1
    var gcmId: String = ""
    var driverNumber: String = ""
    var driverName: String = ""
    var eventId: String = ""
    var eventName: String = ""
    var eventStartDate : NSDate!
    var eventEndDate : NSDate!
    var time: String = ""
    var passengers = [String]()
    var day = -1
    var month = ""
    var monthNum = -1
    var hour = -1
    var minute = -1
    var year = -1
    var date : NSDate!
    var postcode: String = ""
    var state: String = ""
    var city: String = ""
    var street: String = ""
    var country: String = ""
    var gender: Int = 0
    var timeStr = ""
    
    //user for offering rides primarily
    var departureDate : NSDate? //both time and date
    var departureTime: NSDate? //only time component h:mm a
    var departureDay : NSDate?  //only date component d/m/y
    
    
    init(){
        self.direction = Directions.both
        self.seats = 1
        self.radius = 1
    }

    init?(dict: NSDictionary){

        if (dict.objectForKey(LocationKeys.loc) != nil){
            let loc = dict.objectForKey(LocationKeys.loc) as! NSDictionary
            
            if (loc[LocationKeys.postcode] != nil && !(loc[LocationKeys.postcode] is NSNull)){
                postcode = loc[LocationKeys.postcode] as! String
            }
            if (loc[LocationKeys.state] != nil && !(loc[LocationKeys.state] is NSNull)){
                state = loc[LocationKeys.state] as! String
            }
            if (loc[LocationKeys.city] != nil && !(loc[LocationKeys.city] is NSNull)){
                city = loc[LocationKeys.city] as! String
            }
            if (loc[LocationKeys.street1] != nil && !(loc[LocationKeys.street1] is NSNull)){
                street = loc[LocationKeys.street1] as! String
            }
            if (loc[LocationKeys.country] != nil && !(loc[LocationKeys.country] is NSNull)) {
                country = loc[LocationKeys.country] as! String
            }
        }
        if (dict.objectForKey(RideKeys.id) != nil){
            id = dict.objectForKey(RideKeys.id) as! String
        }
        if (dict.objectForKey(RideKeys.direction) != nil){
            direction = dict.objectForKey(RideKeys.direction) as! String
        }
        if (dict.objectForKey(RideKeys.seats) != nil){
            seats = dict.objectForKey(RideKeys.seats) as! Int
        }
        if (dict.objectForKey(RideKeys.radius) != nil){
            radius = dict.objectForKey(RideKeys.radius) as! Int
        }
        if (dict.objectForKey(RideKeys.gcm_id) != nil){
            gcmId = dict.objectForKey(RideKeys.gcm_id) as! String
        }
        if (dict.objectForKey(RideKeys.driverNumber) != nil){
            driverNumber = dict.objectForKey(RideKeys.driverNumber) as! String
        }
        if (dict.objectForKey(RideKeys.driverName) != nil){
            driverName = dict.objectForKey(RideKeys.driverName) as! String
        }
        if (dict.objectForKey(RideKeys.event) != nil){
            eventId = dict.objectForKey(RideKeys.event) as! String
        }
        if (dict.objectForKey(RideKeys.time) != nil){
            time = dict.objectForKey(RideKeys.time) as! String
            self.date = GlobalUtils.dateFromString(time)
            self.departureDate = self.date
            //self.departureTime = self.date
            //self.departureDay = self.date
            

            
            let components = GlobalUtils.dateComponentsFromDate(GlobalUtils.dateFromString(time))!
            self.day = components.day
            let monthNumber = components.month
            self.hour = components.hour
            self.minute = components.minute
            self.year = components.year
            self.time = getTime()//Ride.createTime(self.hour, minute: self.minute)
            
            //get month symbol from number
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            self.month = months[monthNumber - 1].uppercaseString
            self.monthNum = monthNumber
        }
        if (dict.objectForKey(RideKeys.passengers) != nil){
            passengers = dict.objectForKey(RideKeys.passengers) as! [String]
        }

    }
    
    
    func getRadius()->String{
        if (radius == 1){
            return String(radius) + " mile"
        }
        else{
            return String(radius) + " miles"
        }
    }
    
    func isPassengerInRide(passId: String)->Bool{
        for pass in passengers{
            if pass == passId{
                return true
            }
        }
        return false
    }
    
    
    func getDescription(eventName: String)->String{
        if (self.gcmId == Config.gcmId()){
            return "Driving to " + eventName + " at " + self.getTime()
         }
        else{
            return "Getting a ride to " + eventName + " with " + self.driverName + " at " + self.getTime()
        }
    }
    
    func getTimeInServerFormat()->String{
        
        var dayString = ""
        var hourString = ""
        var minuteString = ""
        var monthString = ""
        
        if(monthNum < 10){
            monthString = "0" + String(monthNum)
        }
        else{
            monthString = String(monthNum)
        }
        
        if(day < 10){
            dayString = "0" + String(day)
        }
        else{
            dayString = String(day)
        }
        
        if(hour < 10){
            hourString = "0"  + String(hour)
        }
        else{
            hourString = String(hour)
        }
        
        if(minute < 10){
            minuteString = "0"  + String(minute)
        }
        else{
            minuteString = String(minute)
        }
        
        return String(year) + "-" + String(monthString) + "-" + String(dayString) + "T" + hourString + ":" + String(minuteString) + ":00.000Z"
    }
    
    func getCompleteAddress()->String{
        var address: String = ""
        
        if(street != ""){
            address += street
        }
        if(city != ""){
            address += ", " + city
        }
        if(state != ""){
            address += ", " + state
        }
        if(postcode != ""){
            address += ", " + postcode
        }
        if(country != ""){
            address += ", " + country
        }
        
        return address
    }
    
    func getTime()->String{
        let dFormat = "h:mm a"
        return GlobalUtils.stringFromDate(self.date, format: dFormat)
    }
    
    func getDate()->String{
        if(day == -1){
            return ""
        }
        else{
            let dFormat = "MMMM d, yyyy"
            return GlobalUtils.stringFromDate(self.date, format: dFormat)
        }
    }
    
    func getDepartureDate()->NSDate{
        return self.departureDate!
    }
    
    func getDepartureDay()->String{
        let dFormat = "MMMM d, yyyy"
        if(self.departureDay == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureDay!, format: dFormat)
        }
        
    }
    
    func getFormatedDay() -> String {
        if(day == -1){
            return ""
        }
        else{
            let dFormat = "MMMM d, yyyy"
            return GlobalUtils.stringFromDate(self.date, format: dFormat)
        }
    }
    
    func getDepartureDay()->NSDate{
        return self.departureDate!
    }
    
    func getDepartureTime()->String{
        let dFormat = "h:mm a"
        if(self.departureTime == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureTime!, format: dFormat)
        }
    }
    
    func getDepartureTime()->NSDate{
        return self.departureDate!
    }
        
    func hasSeats()->Bool{
        return (self.seats - passengers.count)  != 0
    }
    
    func seatsLeft()->String{
        return String(self.seats - self.passengers.count)
    }
    
    func seatsLeft()->Int{
        return self.seats - self.passengers.count
    }
    
    func numSeatsNeedToDrop(proposedNumSeats: Int)->Int{
        return passengers.count - proposedNumSeats
    }
    
    func getDirection()->String{
        switch (direction){
            case "both":
                return Directions.both
            case "to":
                return Directions.to
            case "from":
                return Directions.from
            default:
                return Directions.both
        }
    }
    
    func clearAddress(){
        postcode = ""
        state = ""
        city = ""
        street = ""
        country = ""
    }
    
    func isValidTime() -> String{
        let theDate =  GlobalUtils.dateFromString(self.getTimeInServerFormat())
        
        if(minute == -1 || hour == -1 || day == -1 || monthNum == -1 || day == -1 || year == -1){
            return ValidationErrors.none
        }
        
        if(direction == "to" || direction == "both"){
            
            if theDate.compare(eventStartDate) == NSComparisonResult.OrderedDescending {
                return ValidationErrors.badTimeBefore  + " " + GlobalUtils.stringFromDate(eventStartDate, format: "MM/dd/yy h:mm a")
            }
        }
        else{
            print("\nDirection is: \(direction)\n")
            if theDate.compare(eventStartDate) == NSComparisonResult.OrderedAscending {
                return ValidationErrors.badTimeBeforeStart + " " + GlobalUtils.stringFromDate(eventStartDate, format: "MM/dd/yy h:mm a")
            }
        }
        
        return ValidationErrors.none
    }
    
    func isValidNumSeats(num: Int) -> String{
        if (num < RideConstants.minSeats || num > RideConstants.maxSeats){
            return ValidationErrors.badNumSeats
        }
        else{
            return ValidationErrors.none
        }
    }
    
    func isValidAddress() -> String{
        if (street == ""){
            return ValidationErrors.noStreet
        }
        if (postcode == ""){
            return ValidationErrors.noZip
        }
        if (city == ""){
            return ValidationErrors.noCity
        }
        if (state == ""){
            return ValidationErrors.noState
        }

        
        return ValidationErrors.none
    }
    
    //Accepts a phone number as a string and returns a String indicating any errors
    func isValidPhoneNum(num: String) -> String{
        if(num.characters.count == 10){
            for c in num.characters{
                if let _ = Int(String(c)){
                    
                }
                else{
                    return ValidationErrors.badPhone
                }
            }
        }
        else if(num.characters.count == 0){
            return ValidationErrors.noPhone
        }
        else {
            return ValidationErrors.badPhone
        }
        
        return ValidationErrors.none
    }
    
    //Accepts a name and returns a String indicating any errors
    func isValidName(name: String) -> String{
        let fullNameArr = name.componentsSeparatedByString(" ")
        
        if(fullNameArr.count == 2){
            if let _ = Int(fullNameArr[0]){
                return ValidationErrors.badName
            }
            if let _ = Int(fullNameArr[1]){
                return ValidationErrors.badName
            }
            return ValidationErrors.none
        }
        else{
            return ValidationErrors.noName;
        }
        
    }
    
    
    //converts our direction value to a server value
    func getServerDirectionValue(dir : String)->String{
        switch (dir){
            case Directions.from:
                return "from"
            case Directions.to:
                return  "to"
            case Directions.both:
                return  "both"
            default:
                return  ""
        }
    }
    
    
    func getRiderDetails() -> [EditableItem]{
        var details = [EditableItem]()
        details.appendContentsOf(getEventInfo())
        details.appendContentsOf(getDriverInfo())
        details.appendContentsOf(getDepartureInfo())
        return details
    }
    
    func getDriverDetails() -> [EditableItem]{
        var details = [EditableItem]()
        details.appendContentsOf(getEventInfo())
        details.appendContentsOf(getDepartureInfo())
        details.appendContentsOf(getSeatsInfo())
        return details
    }
    
    func getSeatsInfo() -> [EditableItem]{
        var details = [EditableItem]()
        details.append(EditableItem(itemName: Labels.seatsLabel, itemValue: String(seats), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.seatsLeftLabel, itemValue: String(seatsLeft()), itemEditable: false, itemIsText: true))
        return details
    }
    
    func getEventInfo() -> [EditableItem]{
        return [EditableItem(itemName: Labels.eventLabel, itemValue: eventName, itemEditable: false, itemIsText: true)]
    }
    
    func getDepartureInfo() -> [EditableItem]{
        var details = [EditableItem]()
        details.append(EditableItem(itemName: Labels.departureDateLabel, itemValue: getDate(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.departureTimeLabel, itemValue: getTime(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.directionLabel, itemValue: getDirection(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.addressLabel, itemValue: getCompleteAddress(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.pickupRadius, itemValue: getRadius(), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.directionLabel, itemValue: getDirection(), itemEditable: false, itemIsText: true))
        return details
    }
    
    func getDriverInfo() -> [EditableItem]{
        var details = [EditableItem]()
        details.append(EditableItem(itemName: Labels.driverName, itemValue: driverName, itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.driverNumber, itemValue: driverNumber, itemEditable: false, itemIsText: true))
        return details
    }
    
    func getMapSubtitle()->String{
        return self.seatsLeft()  + " seats left"
    }
    
    func getRideAsDict()->[String:AnyObject]{
        var map: [String:AnyObject] = [RideKeys.id : self.id,
            RideKeys.direction: self.direction, RideKeys.driverName: self.driverName,
            RideKeys.driverNumber: self.driverNumber, RideKeys.radius: self.radius,
            RideKeys.seats: self.seats, RideKeys.time: self.time,
            RideKeys.location: self.getLocationAsDict(), RideKeys.passengers: self.passengers]
        map.updateValue(self.direction, forKey: RideKeys.direction)
        map[RideKeys.direction] = self.direction
        return map
    }
    
    func getLocationAsDict()->[String:AnyObject]{
        var map = [String:AnyObject]()
        var locMap = [String:String]()
        
        locMap[LocationKeys.postcode] = self.postcode
        locMap[LocationKeys.state] = self.state
        locMap[LocationKeys.street1] = self.street
        locMap[LocationKeys.country] = self.country
        locMap[LocationKeys.city] = self.city
        
        map[LocationKeys.loc] = locMap
        
        return map
    }
}

func  <(lRide: Ride, rRide: Ride) -> Bool{
    if(lRide.year < rRide.year){
        return true
    }
    else if(lRide.year > rRide.year){
        return false
    }
    if(lRide.monthNum < rRide.monthNum){
        return true
    }
    else if(lRide.monthNum > rRide.monthNum){
        return false
    }
    
    if(lRide.day < rRide.day){
        return true
    }
    else if(lRide.day > rRide.day){
        return false
    }
    return false
}
func  ==(lRide: Ride, rRide: Ride) -> Bool{
    return lRide.id == rRide.id
}