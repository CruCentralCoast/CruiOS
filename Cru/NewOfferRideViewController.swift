//
//  NewOfferRideViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/20/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit
import LocationPicker
import LocationPickerViewController
import MRProgress

class NewOfferRideViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var nameField: UITextField?
    @IBOutlet weak var phoneField: UITextField?
    @IBOutlet weak var eventField: UITextField?
    @IBOutlet weak var dateField: UITextField?
    @IBOutlet weak var timeField: UITextField?
    @IBOutlet weak var addressField: UITextField?
    @IBOutlet weak var pickupRadiusField: UITextField?
    @IBOutlet weak var seatsField: UITextField?
    @IBOutlet weak var direction: UISegmentedControl!
    
    @IBOutlet weak var nameLine: UIView!
    @IBOutlet weak var phoneLine: UIView!
    @IBOutlet weak var eventLine: UIView!
    @IBOutlet weak var dateLine: UIView!
    @IBOutlet weak var timeLine: UIView!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var pickupLine: UIView!
    @IBOutlet weak var seatsLine: UIView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var timeHint: UILabel!
    @IBOutlet weak var endDateHint: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: SegmentedControl!
    
    var inactiveGray = UIColor(red: 149/225, green: 147/225, blue: 145/225, alpha: 1.0)
    var ride: Ride!
    var events = [Event]()
    var event: Event!
    var rideVC: RidesViewController!
    var parsedNum: String!
    var CLocation: CLLocation?
    var convertedDict = NSDictionary()
    
    struct OfferRideConstants{
        static let pageTitle = "Offer Ride"
        static let bottomButton = "Submit"
        static let chooseEventSegue = "chooseEvent"
        static let editRadiusSegue = "radiusPicker"
    }
    var location: Location! {
        didSet {
            addressField?.text = location.address
            validateLocation()
            
        }
    }
    
    var loc: LocationItem! {
        didSet {
            let dict = loc.addressDictionary as! NSDictionary
            //let convertedDict = NSDictionary()
            let country = dict["CountryCode"] as! String
            let state = dict["State"] as! String
            let street = dict["Street"] as! String
            let postcode = dict["ZIP"] as! String
            let city = dict["City"] as! String
            
            convertedDict = ["country": country, "state": state, "street1": street, "postcode": postcode]
            
            let formatted = String("\(street), \(city) \(postcode)")
            //print("\n\(street), \(city) \(postcode)\n")
            addressField?.text = formatted
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the text field delegates to self
        nameField?.delegate = self
        phoneField?.delegate = self
        phoneField?.keyboardType = .NumberPad
        eventField?.delegate = self
        dateField?.delegate = self
        timeField?.delegate = self
        addressField?.delegate = self
        pickupRadiusField?.delegate = self
        seatsField?.delegate = self
        seatsField?.keyboardType = .NumberPad
        
        //Instantiate the ride
        self.ride = Ride()
        
        //If the event has already been selected
        if(event != nil){
            ride.eventStartDate = event.startNSDate
            ride.eventEndDate = event.endNSDate
        }
        else {
            CruClients.getServerClient().getData(DBCollection.Event, insert: insertEvent, completionHandler: {error in})
        }
        
        //Navbar buttons
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneAction(_:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelAction(_:)))
        
        doneButton.tintColor = CruColors.lightBlue
        cancelButton.tintColor = CruColors.orange
        
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        //Hide the time hint until an event is selected
        timeHint?.hidden = true
        endDateHint?.hidden = true
        
    }
    
    //Asynchronous function that's called to insert an event into the table
    func insertEvent(dict : NSDictionary) {
        //Create event
        let event = Event(dict: dict)!
        
        //Insert event into the array only if ridesharing is enabled
        if event.rideSharingEnabled == true {
            self.events.insert(event, atIndex: 0)
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case nameField!:
            nameField?.resignFirstResponder()
        case phoneField!:
            phoneField?.resignFirstResponder()
        case eventField!:
            eventField?.resignFirstResponder()
        case dateField!:
            dateField?.resignFirstResponder()
        case timeField!:
            timeField?.resignFirstResponder()
        case pickupRadiusField!:
            pickupRadiusField?.resignFirstResponder()
        case seatsField!:
            seatsField?.resignFirstResponder()
        default:
            print("Text field not recognizied")
        }
        return true
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case nameField!:
            highlightField(nameLine)
            //nameLine?.backgroundColor = CruColors.lightBlue
        case phoneField!:
            highlightField(phoneLine)
            //phoneLine?.backgroundColor = CruColors.lightBlue
        case eventField!:
            eventField?.resignFirstResponder()
            highlightField(eventLine)
            self.performSegueWithIdentifier(OfferRideConstants.chooseEventSegue, sender: self)
            //eventLine?.backgroundColor = CruColors.lightBlue
        case dateField!:
            highlightField(dateLine)
            //dateLine?.backgroundColor = CruColors.lightBlue
            dateField?.resignFirstResponder()
            TimePicker.pickDate(self, handler: chooseDateHandler)
        case timeField!:
            highlightField(timeLine)
            //timeLine?.backgroundColor = CruColors.lightBlue
            timeField?.resignFirstResponder()
            TimePicker.pickTime(self)
        case addressField!:
            highlightField(addressLine)
            addressField?.resignFirstResponder()
            choosePickupLocation(self)
            //addressLine?.backgroundColor = CruColors.lightBlue
        case pickupRadiusField!:
            highlightField(pickupLine)
            pickupRadiusField?.resignFirstResponder()
            
            if(self.loc != nil){
                //self.performSegueWithIdentifier(OfferRideConstants.editRadiusSegue, sender: self)
            }
            else{
                showValidationError("Please pick a location before picking a radius.")
            }
            //pickupLine?.backgroundColor = CruColors.lightBlue
        case seatsField!:
            highlightField(seatsLine)
            //seatsLine?.backgroundColor = CruColors.lightBlue
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        switch textField {
        case nameField!:
            makeFieldInactive(nameLine)
            //nameLine?.backgroundColor = inactiveGray
        case phoneField!:
            makeFieldInactive(phoneLine)
            phoneField!.text = PhoneFormatter.unparsePhoneNumber(phoneField!.text!)
            //phoneLine?.backgroundColor = inactiveGray
        case eventField!:
            makeFieldInactive(eventLine)
            //eventLine?.backgroundColor = inactiveGray
        case dateField!:
            makeFieldInactive(dateLine)
            //dateLine?.backgroundColor = inactiveGray
        case timeField!:
            makeFieldInactive(timeLine)
            //timeLine?.backgroundColor = inactiveGray
        case addressField!:
            makeFieldInactive(addressLine)
            //addressLine?.backgroundColor = inactiveGray
        case pickupRadiusField!:
            makeFieldInactive(pickupLine)
            //pickupLine?.backgroundColor = inactiveGray
        case seatsField!:
            makeFieldInactive(seatsLine)
            //seatsLine?.backgroundColor = inactiveGray
        default:
            print("Text field not recognized")
        }
    }
    
    // MARK: Animations
    func highlightField(view: UIView) {
        UIView.animateWithDuration(0.5, animations: {
            view.backgroundColor = CruColors.lightBlue
        })
    }
    
    func makeFieldInactive(view: UIView) {
        UIView.animateWithDuration(0.5, animations: {
            view.backgroundColor = self.inactiveGray
        })
    }
    
    
    
    
    // MARK: Actions
    
    @IBAction func directionChanged(sender: SegmentedControl) {
        
        ride.direction = segmentedControl.getDirection()
        
        if timeHint.hidden == false {
            if segmentedControl.getDirection() == "from" {
                timeHint.text = String("(event ends at \(event.getEndTime())\(event.getEndAmOrPm()))")
                
                endDateHint.hidden = false
                endDateHint.text = String("(event ends on \(event.getEndDate()))")
            }
                
            else if segmentedControl.getDirection() == "to" || segmentedControl.getDirection() == "both" {
                endDateHint.hidden = true
                timeHint.text = String("(event starts at \(event.getStartTime())\(event.getAmOrPm()))")
            }
        }
    }
    
    @IBAction func directionPicked(sender: UISegmentedControl) {
        switch direction {
        case 0:
            //Round trip
            ride.direction = ride.getServerDirectionValue("both")
        case 1:
            //to event
            ride.direction = ride.getServerDirectionValue("to")
        case 2:
            //from event
            ride.direction = ride.getServerDirectionValue("from")
        default:
            ride.direction = ride.getServerDirectionValue("both")
        }
    }
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        //Validation here
        
        if validateName() == false { return}
        if validateNumber() == false {return}
        if validateEvent() == false {return}
        if validateTime() == false {return}
        if validateLocation() == false {return}
        if validateSeats() == false {return}
        if validateDirection() == false {return}
        
        if timeField?.text != "" {
            ride.time = (timeField?.text)!
        }
        //Show the progress wheel and send offer
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        sendRideOffer()
        
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Validators
    func validateName() -> Bool {
        if (nameField?.text != ""){
            nameField?.text = (nameField?.text)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let error  = ride.isValidName((nameField?.text)!)
            if(error != ""){
                showValidationError(error)
                
                addTextFieldError(nameLine!)
                
                return false
            }
            else{
                ride.driverName = (nameField?.text)!
                removeTextFieldError(nameLine!)
                return true
            }
        }
        else{
            if(ride.driverName == ""){
                showValidationError(ValidationErrors.noName)
                addTextFieldError(nameLine!)
                return false
            }
            else{
                return true
            }
        }
    }
    
    func validateNumber() -> Bool {
        if (phoneField != "") {
            parsedNum = PhoneFormatter.parsePhoneNumber((phoneField?.text)!)
            
            let error  = ride.isValidPhoneNum(parsedNum!)
            if(error != ""){
                showValidationError(error)
                addTextFieldError(phoneLine!)
                return false
            }
            else{
                ride.driverNumber = parsedNum!
                removeTextFieldError(phoneLine!)
                return true
            }
            
        }
        else{
            if(ride.isValidPhoneNum(ride.driverNumber) == ""){
                return true
            }
            else{
                ride.isValidPhoneNum(ride.driverNumber)
                return false
            }
            
        }
    }
    
    func validateEvent() -> Bool {
        if(ride.eventStartDate == nil){
            addTextFieldError(eventLine!)
            showValidationError(ValidationErrors.noEvent)
            return false
        }
        return true
    }
    
    func validateTime() -> Bool {
        ride.eventStartDate = event.startNSDate
        ride.eventEndDate = event.endNSDate
        
        if let components = GlobalUtils.dateComponentsFromDate(ride.getDepartureDay()){
            ride.day = (components.day)
            ride.monthNum = (components.month)
            ride.year = (components.year)
        }
        
        if let components = GlobalUtils.dateComponentsFromDate(ride.getDepartureTime()){
            ride.hour = (components.hour)
            ride.minute = (components.minute)
        }
        
        
        ride.date = GlobalUtils.dateFromString(ride.getTimeInServerFormat())
        
        if (ride.isValidTime() == ""){
            return true
        }
        else{
            addTextFieldError(timeLine!)
            showValidationError(ride.isValidTime())
            return false
        }
    }
    func validateLoc() -> Bool {
        if(loc != nil){
            let map = loc.addressDictionary!
            
            ride.clearAddress()
            
            
            
            if(map[LocationKeys.city] != nil){
                ride.city = map[LocationKeys.city] as! String
            }
            if(map[LocationKeys.state] != nil){
                ride.state = map[LocationKeys.state] as! String
            }
            if(map[LocationKeys.street1] != nil){
                ride.street = map[LocationKeys.street1] as! String
            }
            if(map[LocationKeys.country] != nil){
                ride.country = map[LocationKeys.country] as! String
            }
            if(map[LocationKeys.postcode] != nil){
                ride.postcode = map[LocationKeys.postcode] as! String
            }
            
            if(ride.isValidAddress() == ""){
                return true
            }
            else{
                showValidationError(ride.isValidAddress())
                addTextFieldError(addressLine!)
                return false
            }
            
        }
        return true
    }
    
    func validateLocation() -> Bool {
        if(location != nil){
            let map = location.getLocationAsDict(location)
            
            ride.clearAddress()
            
            if(map[LocationKeys.city] != nil){
                ride.city = map[LocationKeys.city] as! String
            }
            if(map[LocationKeys.state] != nil){
                ride.state = map[LocationKeys.state] as! String
            }
            if(map[LocationKeys.street1] != nil){
                ride.street = map[LocationKeys.street1] as! String
            }
            if(map[LocationKeys.country] != nil){
                ride.country = map[LocationKeys.country] as! String
            }
            if(map[LocationKeys.postcode] != nil){
                ride.postcode = map[LocationKeys.postcode] as! String
            }
            
            if(ride.isValidAddress() == ""){
                return true
            }
            else{
                showValidationError(ride.isValidAddress())
                return false
            }
            
        }
        return true
    }
    
    func validateSeats() -> Bool{
        if seatsField?.text != "" {
            if let val = Int((seatsField?.text)!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())){
                if(ride.isValidNumSeats(val) != ""){
                    showValidationError(ride.isValidNumSeats(val))
                    return false
                }
                else{
                    ride.seats = val
                    return true
                }
            }
            else{
                showValidationError(ValidationErrors.badSeats)
                addTextFieldError(seatsLine!)
            }
        }
        
        return true
    }
    
    func validateDirection() -> Bool {
        
        //ride.direction = segmentedControl.getDirection()
        
        if ride.direction == "" {
            return false
        }
        
        return true
    }
    
    //Send ride request
    func sendRideOffer(){
        if parsedNum != nil {
            CruClients.getServerClient().checkIfValidNum(Int(parsedNum!)!, handler: postRideOffer)
        }
        
    }
    
    func postRideOffer(success: Bool){
        if (success){
            
            //CruClients.getRideUtils().postRideOffer(ride.eventId, name: ride.driverName, phone: ride.driverNumber, seats: ride.seats, time: ride.getTimeInServerFormat(), location: location.getLocationAsDict(location), radius: ride.radius, direction: ride.direction, handler:  handleRequestResult)
            CruClients.getRideUtils().postRideOffer(ride.eventId, name: ride.driverName, phone: (self.phoneField?.text)!, seats: ride.seats, time: ride.getTimeInServerFormat(), location: self.convertedDict, radius: ride.radius, direction: ride.direction, handler:  handleRequestResult)
        }else{
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            showValidationError(ValidationErrors.phoneUnauthorized)
        }
    }
    
    func handleRequestResult(result : Ride?){
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        if result != nil {
            
            
            if(rideVC != nil){
                self.rideVC.refresh(self)
                presentAlert("Success", msg: "Thank you! Your ride has been created!", handler:  {
                    if let navController = self.navigationController {
                        navController.popViewControllerAnimated(true)
                        
                    }
                })
            }
            else{
                presentAlert("Ride Offered", msg: "Thank you! Your offered ride has been created! You can view your ride offer in the Ridehsaring section.", handler:  {
                    if let navController = self.navigationController {
                        navController.popViewControllerAnimated(true)
                        
                    }
                })
            }
            
            
        } else {
            presentAlert("Ride Offer Failed", msg: "Failed to post ride offer", handler:  {})
        }
    }
    
    //Syncs the ride's values to the event's
    func syncRideToEvent(){
        //Automatically set the ride info to an hour before the event starts
        ride.eventName = event.name
        ride.eventId = event.id
        ride.eventStartDate = event.startNSDate
        ride.eventEndDate = event.endNSDate
        ride.departureDay = event.startNSDate
        ride.departureTime = event.startNSDate.addHours(-1)
        
        //Set the text in the fields
        dateField!.text = ride.getDepartureDay()
        timeField!.text = ride.getDepartureTime()
        ride.direction = "both"
        
        //show the time hint
        timeHint.hidden = false
        timeHint.text = String("(event starts at \(event.getStartTime())\(event.getAmOrPm()))")
        
    }
    
    func getRideLocation(){
        if (ride.getCompleteAddress() == ""){
            return
        }
        
        var initialLocation = CLLocation()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = ride!.getCompleteAddress()
        
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                initialLocation = item.placemark.location!
                self.CLocation = initialLocation
            }
        }
    }
    
    //called when a date is chosen
    func chooseDateHandler(month : Int, day : Int, year : Int){
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "MM d yyyy"
        
        //if date formatter returns nil return the current date/time
        if let date = dateFormatter.dateFromString(String(month) + " " + String(day) + " " + String(year)) {
            ride.date = date
            ride.monthNum = month
            ride.day = day
            ride.year = year
            ride.departureDay = date
            self.dateField?.text = ride.getDate()
        }
    }
    
    //called when a time is chosen
    func datePicked(obj: NSDate){
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        timeField!.text = formatter.stringFromDate(obj)
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute], fromDate: obj)
        ride.hour = comp.hour
        ride.minute = comp.minute
        ride.timeStr = (timeField?.text)!
        ride.departureTime = obj
    }
    
    func dismissLocationPicker(sender: UIBarButtonItem) {
        print("\nNow this gets executed\n")
        navigationController!.popViewControllerAnimated(true)
    }
    
    func sendLocation(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    func setRadius(radius: Int){
        ride.radius = radius
        pickupRadiusField?.text = ride.getRadius()
        pickupLine.backgroundColor = inactiveGray
    }
    
    // MARK: Pickup Location Function
    //Called when the pickup location text field becomes active
    func choosePickupLocation(sender: AnyObject) {
        
        
        
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            // Do something with the location the user picked.
            //print("\nThis gets executed\n")
            self.loc = pickedLocationItem
            self.CLocation = CLLocation(latitude: pickedLocationItem.coordinate!.latitude, longitude: pickedLocationItem.coordinate!.longitude)
            self.addressLine.backgroundColor = self.inactiveGray
            
        }
        //locationPicker.addBarButtons()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(sendLocation(_:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(dismissLocationPicker(_:)))
        
        doneButton.tintColor = CruColors.lightBlue
        cancelButton.tintColor = UIColor.redColor()
        
        locationPicker.setColors(CruColors.yellow, primaryTextColor: CruColors.darkBlue, secondaryTextColor: CruColors.lightBlue)
        locationPicker.searchBar.barTintColor = CruColors.gray
    
        //locationPicker.addBarButtons()
        //locationPicker.addBarButtons(doneButton, cancelButtonItem: cancelButton, doneButtonOrientation: .Right)
        
        // Call this method to add a done and a cancel button to navigation bar.
        

        /*let locationPicker = LocationPickerViewController()
        
        locationPicker.searchBarPlaceholder = "Search"
        
        if self.location != nil {
            locationPicker.location = self.location
        }
        
        locationPicker.completion = { location in
            
            self.location = location
            self.CLocation = self.location.location
            
        }*/
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    // MARK: Changing UI
    
    func addTextFieldError(view: UIView){
        UIView.animateWithDuration(0.5, animations: {
            //view.backgroundColor = UIColor(red: 190/255, green: 59/255, blue: 52/255, alpha: 1.0)
            view.backgroundColor = UIColor.redColor()
        })
    }
    
    func removeTextFieldError(view: UIView){
        UIView.animateWithDuration(0.5, animations: {
            view.backgroundColor = self.inactiveGray
        })
    }
    
    func showValidationError(error: String){
        let alert = UIAlertController(title: error, message: "", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: {})
    }
    
    private func presentAlert(title: String, msg: String, handler: ()->()) {
        let cancelRideAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        cancelRideAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            action in
            handler()
            
        }))
        presentViewController(cancelRideAlert, animated: true, completion: nil)
        
    }
    
    /* Prevents the event popover to not fill the entire screen */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "radiusPicker" {
            if self.loc == nil {
                showValidationError("Please pick a location before picking a radius.")
                
                return false
            }
            pickupLine.backgroundColor = inactiveGray
            return true
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == OfferRideConstants.chooseEventSegue{
            let eventVC = segue.destinationViewController as! EventsPopoverViewController
            eventVC.events = self.events
            eventVC.offerRide = self
            
            eventVC.popoverPresentationController?.sourceView = self.eventField
            eventVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.75, height: self.view.frame.height * 0.5)
            eventVC.popoverPresentationController!.sourceRect = CGRectMake(self.view.frame.width / 2, 15,0,0)
            eventVC.popoverPresentationController?.permittedArrowDirections = .Up
            
            
            let controller = eventVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
        }
        else if(segue.identifier == OfferRideConstants.editRadiusSegue){
            let vc = segue.destinationViewController as! PickRadiusViewController
            vc.ride = self.ride
            vc.setRadius = setRadius
            vc.numMiles = ride.radius
            vc.location = CLocation
        }
        /*else if segue.identifier == "LocationPicker" {
            let locationPicker = segue.destinationViewController as! LocationPickerViewController
            locationPicker.location = location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.showCurrentLocationInitially = true
            
            
            locationPicker.completion = { location in
                self.location = location
                self.CLocation = self.location.location
            }
        }*/
        
    }
    

}
