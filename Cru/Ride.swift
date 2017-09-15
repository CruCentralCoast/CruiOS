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
    static let fcm_id = "fcm_id"
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
    static let maxSeats = 15
    
}

class Ride: Comparable, Equatable, TimeDetail {
    var id: String = ""
    var direction: String = ""
    var seats: Int = -1
    var radius: Int = -1
    var fcmId: String = ""
    var driverNumber: String = ""
    var driverName: String = ""
    var eventId: String = ""
    var eventName: String = ""
    var eventStartDate : Date!
    var eventEndDate : Date!
    var time: String = ""
    var passengers = [String]()
    var day = -1
    var month = ""
    var monthNum = -1
    var hour = -1
    var minute = -1
    var year = -1
    var date : Date!
    var postcode: String = ""
    var state: String = ""
    var city: String = ""
    var street: String = ""
    var country: String = ""
    var gender: Int = 0
    var timeStr = ""
    
    //user for offering rides primarily
    var departureDate : Date? //both time and date
    //var departureTime: Date? //only time component h:mm a
    //var departureDay : Date?  //only date component d/m/y
    
    
    init(){
        self.direction = RideDirection.roundTrip.rawValue
        self.seats = 1
        self.radius = 1
    }

    init?(dict: NSDictionary){

        if (dict.object(forKey: LocationKeys.loc) != nil){
            let loc = dict.object(forKey: LocationKeys.loc) as! NSDictionary
            
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
        if (dict.object(forKey: RideKeys.id) != nil){
            id = dict.object(forKey: RideKeys.id) as! String
        }
        if (dict.object(forKey: RideKeys.direction) != nil){
            direction = dict.object(forKey: RideKeys.direction) as! String
        }
        if (dict.object(forKey: RideKeys.seats) != nil){
            seats = dict.object(forKey: RideKeys.seats) as! Int
        }
        if (dict.object(forKey: RideKeys.radius) != nil){
            radius = dict.object(forKey: RideKeys.radius) as! Int
        }
        if (dict.object(forKey: RideKeys.fcm_id) != nil){
            fcmId = dict.object(forKey: RideKeys.fcm_id) as! String
        }
        if (dict.object(forKey: RideKeys.driverNumber) != nil){
            driverNumber = dict.object(forKey: RideKeys.driverNumber) as! String
        }
        if (dict.object(forKey: RideKeys.driverName) != nil){
            driverName = dict.object(forKey: RideKeys.driverName) as! String
        }
        if (dict.object(forKey: RideKeys.event) != nil){
            eventId = dict.object(forKey: RideKeys.event) as! String
        }
        if (dict.object(forKey: RideKeys.time) != nil){
            time = dict.object(forKey: RideKeys.time) as! String
            self.date = GlobalUtils.dateFromString(time)
            self.departureDate = self.date
            //self.departureTime = self.date
            //self.departureDay = self.date
            

            
            let components = GlobalUtils.dateComponentsFromDate(GlobalUtils.dateFromString(time))!
            self.day = components.day!
            let monthNumber = components.month!
            self.hour = components.hour!
            self.minute = components.minute!
            self.year = components.year!
            self.time = getTime()//Ride.createTime(self.hour, minute: self.minute)
            
            //get month symbol from number
            let dateFormatter: DateFormatter = DateFormatter()
            let months = dateFormatter.shortMonthSymbols
            self.month = (months?[monthNumber - 1].uppercased())!
            self.monthNum = monthNumber
        }
        if (dict.object(forKey: RideKeys.passengers) != nil){
            passengers = dict.object(forKey: RideKeys.passengers) as! [String]
        }

    }
    
    func getRideAsDict()->[String:AnyObject]{
        var map: [String:AnyObject] = [RideKeys.id : self.id as AnyObject,
                                       RideKeys.direction: self.direction as AnyObject, RideKeys.driverName: self.driverName as AnyObject,
                                       RideKeys.driverNumber: self.driverNumber as AnyObject, RideKeys.radius: self.radius as AnyObject,
                                       RideKeys.seats: self.seats as AnyObject, RideKeys.time: self.time as AnyObject,
                                       RideKeys.location: self.getLocationAsDict() as AnyObject, RideKeys.passengers: self.passengers as AnyObject]
        map.updateValue(self.direction as AnyObject, forKey: RideKeys.direction)
        map[RideKeys.direction] = self.direction as AnyObject?
        return map
    }
    
    
    
    
    func isPassengerInRide(_ passId: String)->Bool{
        for pass in passengers{
            if pass == passId{
                return true
            }
        }
        return false
    }
    
    
    func getDescription(_ eventName: String)->String{
        if (self.fcmId == Config.fcmId()){
            return "Driving to " + eventName + " at " + self.getTime()
         }
        else{
            return "Getting a ride to " + eventName + " with " + self.driverName + " at " + self.getTime()
        }
    }
    
    // MARK: - Location Functions
    //Return just the street address
    func getStreetString() -> String {
        return street
    }
    
    //Return just the street address
    func getSuburbString() -> String {
        var address: String = ""
        
        if(city != ""){
            address += city
        }
        if(state != ""){
            address += ", " + state
        }
        return address
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
    
    func clearAddress(){
        postcode = ""
        state = ""
        city = ""
        street = ""
        country = ""
    }
    
    func getLocationAsDict()->[String:AnyObject]{
        var map = [String:AnyObject]()
        var locMap = [String:String]()
        
        locMap[LocationKeys.postcode] = self.postcode
        locMap[LocationKeys.state] = self.state
        locMap[LocationKeys.street1] = self.street
        locMap[LocationKeys.country] = self.country
        locMap[LocationKeys.city] = self.city
        
        map[LocationKeys.loc] = locMap as AnyObject?
        
        return map
    }
    
    func getMapSubtitle()->String{
        return self.seatsLeftAsString()  + " seats left"
    }
    
    // MARK: - Pickup Radius Functions
    func getRadius()->String{
        if (radius == 1){
            return String(radius) + " mile"
        }
        else{
            return String(radius) + " miles"
        }
    }
    
    // MARK: - Time and Date Functions
    func getTimeInServerFormat()->String{
        
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: departureDate!)
        
        let year = comps.year!
        let month = comps.month!
        let day = comps.day!
        let hour = comps.hour!
        let minute = comps.minute!
        
        var dayString = String(format: "%02d", day)
        var hourString = String(format: "%02d", hour)
        var minuteString = String(format: "%02d", minute)
        var monthString = String(format: "%02d", month)
        
        return String(year) + "-" + String(monthString) + "-" + String(dayString) + "T" + hourString + ":" + String(minuteString) + ":00.000Z"
    }
    
    func getTime()->String{
        let dFormat = "h:mm a"
        return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
    }
    
    func getDate()->String{
        if(self.departureDate == nil){
            return ""
        }
        else{
            let dFormat = "MMMM d, yyyy"
            return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
        }
    }
    
    func getDepartureDate()->Date{
        return self.departureDate!
    }
    
    func getDepartureDay()->String{
        let dFormat = "MMMM d, yyyy"
        if(self.departureDate == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
        }
        
    }
    
    //For use in the Join Ride view controller
    // Returns date formatted like SEP 23
    func getShortDepartureDay()->String{
        let dFormat = "MMM d"
        if(self.departureDate == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
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
    
    func getDepartureDay()->Date{
        return self.departureDate!
    }
    
    func getDepartureTime()->String{
        let dFormat = "h:mm a"
        if(self.departureDate == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
        }
    }
    
    //Get Departure time without AM or PM
    func getDeptTimeNoAMPM() -> String {
        let dFormat = "h:mm"
        if(self.departureDate == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
        }
    }
    
    func getDeptAMPM() -> String {
        let dFormat = "a"
        if(self.departureDate == nil){
            return ""
        }
        else{
            return GlobalUtils.stringFromDate(self.departureDate!, format: dFormat)
        }
    }
    
    func getDepartureTime()->Date{
        return self.departureDate!
    }
    
    
    // MARK: - Seat Functions
    func hasSeats()->Bool{
        return (self.seats - passengers.count)  != 0
    }
    
    func seatsLeftAsString()->String{
        return String(self.seats - self.passengers.count)
    }
    
    func seatsLeft()->Int{
        return self.seats - self.passengers.count
    }
    
    func numSeatsNeedToDrop(_ proposedNumSeats: Int)->Int{
        return passengers.count - proposedNumSeats
    }
    
    func getSeatsInfo() -> [EditableItem]{
        var details = [EditableItem]()
        details.append(EditableItem(itemName: Labels.seatsLabel, itemValue: String(seats), itemEditable: false, itemIsText: true))
        details.append(EditableItem(itemName: Labels.seatsLeftLabel, itemValue: String(seatsLeft()), itemEditable: false, itemIsText: true))
        return details
    }

    
    // MARK: - Direction Functions
    func getDirection()->String{
        return direction
    }
    
    func getServerDirection()-> String {
        return direction
    }
    
    //converts our direction value to a server value
    func getServerDirectionValue(_ dir : String)->String{
        return dir
    }
    
    //Return displayable string for Join Ride VC
    func getDisplayableDirection() -> String {
        switch (direction){
        case "both":
            return "Round trip"
        case "to":
            return "To event"
        case "from":
            return "From event"
        default:
            return "Round trip"
        }
    }
    
    // MARK: - Validator Function
    
    func isValidTime() -> String{
        let theDate =  GlobalUtils.dateFromString(self.getTimeInServerFormat())
        
        if(minute == -1 || hour == -1 || day == -1 || monthNum == -1 || day == -1 || year == -1){
            return ValidationErrors.none
        }
        
        if(direction == RideDirection.toEvent.rawValue || direction == RideDirection.roundTrip.rawValue){
            
            if theDate.compare(eventStartDate) == ComparisonResult.orderedDescending {
                return ValidationErrors.badTimeBefore  + " " + GlobalUtils.stringFromDate(eventStartDate, format: "MM/dd/yy h:mm a")
            }
        }
        else{
            print("\nDirection is: \(direction)\n")
            if theDate.compare(eventStartDate) == ComparisonResult.orderedAscending {
                return ValidationErrors.badTimeBeforeStart + " " + GlobalUtils.stringFromDate(eventStartDate, format: "MM/dd/yy h:mm a")
            }
        }
        
        return ValidationErrors.none
    }
    
    func isValidNumSeats(_ num: Int) -> String{
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
    func isValidPhoneNum(_ num: String) -> String{
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
    func isValidName(_ name: String) -> String{
        let fullNameArr = name.components(separatedBy: " ")
        
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
    
    // MARK: - Old Functions 
    // TODO: Check if still being used
    
    func getRiderDetails() -> [EditableItem]{
        var details = [EditableItem]()
        details.append(contentsOf: getEventInfo())
        details.append(contentsOf: getDriverInfo())
        details.append(contentsOf: getDepartureInfo())
        return details
    }
    
    func getDriverDetails() -> [EditableItem]{
        var details = [EditableItem]()
        details.append(contentsOf: getEventInfo())
        details.append(contentsOf: getDepartureInfo())
        details.append(contentsOf: getSeatsInfo())
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
