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
import GooglePlaces
import GooglePlacePicker

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
    var placesClient: GMSPlacesClient?
    var placePicker: GMSPlacePicker?
    var parsedNum: String!
    var CLocation: CLLocation?
    var convertedDict = NSDictionary()
    var fromEventDetails = false
    
    struct OfferRideConstants{
        static let pageTitle = "Offer Ride"
        static let bottomButton = "Submit"
        static let chooseEventSegue = "chooseEvent"
        static let editRadiusSegue = "radiusPicker"
    }
    var pickedLocation: GMSPlace! {
        didSet {
            addressField?.text = pickedLocation.formattedAddress
            let delimiter = ", "
           
            let parts = pickedLocation.formattedAddress!.components(separatedBy: delimiter)
            
            
            let newDel = " "
            let components = parts[2].components(separatedBy: newDel)
            let state = components[0]
            let postalcode = components[1]
            let address = parts[0]
            let city = parts[1]
            let country = parts[3]
            
            convertedDict = ["country": country, "state": state, "street1": address, "postcode": postalcode, "suburb": city]
            CLocation = CLLocation(coordinate: pickedLocation.coordinate, altitude: 0.0, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the text field delegates to self
        nameField?.delegate = self
        phoneField?.delegate = self
        phoneField?.keyboardType = .numberPad
        eventField?.delegate = self
        dateField?.delegate = self
        timeField?.delegate = self
        addressField?.delegate = self
        pickupRadiusField?.delegate = self
        seatsField?.delegate = self
        seatsField?.keyboardType = .numberPad
        
        //Instantiate the ride
        self.ride = Ride()
        
        //If the event has already been selected
        if(event != nil){
            ride.eventStartDate = event.startNSDate
            ride.eventEndDate = event.endNSDate
        }
        else {
            //CruClients.getServerClient().getData(DBCollection.Event, insert: insertEvent, completionHandler: {error in})
        }
        
        //Navbar buttons
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(_:)))
        
        doneButton.tintColor = CruColors.lightBlue
        cancelButton.tintColor = CruColors.orange
        
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        //Hide the time hint until an event is selected
        timeHint?.isHidden = true
        endDateHint?.isHidden = true
        
        //Setup for the Google Place Picker
        placesClient = GMSPlacesClient.shared()
        
        //Sync the ride with the event if it's coming from event details
        if fromEventDetails {
            syncRideToEvent()
            eventField?.text = event.name
            eventField?.isEnabled = false
            
        }
        
        // If the location dictionary has not been set, set it to the default location
        if convertedDict.count == 0 {
            convertedDict = ["country": "USA", "state": "CA", "street1": "1 Grand Ave", "postcode": "93407", "suburb": "San Luis Obispo"]
        }
        
    }
    
    //Asynchronous function that's called to insert an event into the table
    func insertEvent(_ dict : NSDictionary) {
        //Create event
        let event = Event(dict: dict)!
        
        //Insert event into the array only if ridesharing is enabled
        if event.rideSharingEnabled == true {
            self.events.insert(event, at: 0)
        }
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
            self.performSegue(withIdentifier: OfferRideConstants.chooseEventSegue, sender: self)
            //eventLine?.backgroundColor = CruColors.lightBlue
        case dateField!:
            highlightField(dateLine)
            //dateLine?.backgroundColor = CruColors.lightBlue
            dateField?.resignFirstResponder()
            TimePicker.pickDate(self, handler: chooseDateHandler)
        case timeField!:
            highlightField(timeLine)
            timeField?.resignFirstResponder()
            TimePicker.pickTime(self)
        case addressField!:
            highlightField(addressLine)
            
            if !fromEventDetails {
                addressField?.resignFirstResponder()
                //choosePickupLocation(self)
                //googlePlacePicker()
                //presentCustomPicker()
                let vc = PlacePickerViewController()
                vc.offerRideVC = self
                self.navigationController!.pushViewController(vc, animated: true)
            }
            
            
        case pickupRadiusField!:
            highlightField(pickupLine)
            pickupRadiusField?.resignFirstResponder()
            
            if self.pickedLocation == nil {
                showValidationError("Please pick a location before picking a radius.")
            }
            
            
        case seatsField!:
            highlightField(seatsLine)
            
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case nameField!:
            makeFieldInactive(nameLine)
            //nameLine?.backgroundColor = inactiveGray
        case phoneField!:
            makeFieldInactive(phoneLine)
            phoneField!.text = PhoneFormatter.unparsePhoneNumber(phoneField!.text!)
        case eventField!:
            makeFieldInactive(eventLine)
        case dateField!:
            makeFieldInactive(dateLine)
        case timeField!:
            makeFieldInactive(timeLine)
        case addressField!:
            makeFieldInactive(addressLine)
        case pickupRadiusField!:
            makeFieldInactive(pickupLine)
        case seatsField!:
            makeFieldInactive(seatsLine)
        default:
            print("Text field not recognized")
        }
    }
    
    // MARK: Animations
    func highlightField(_ view: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = CruColors.lightBlue
        })
    }
    
    func makeFieldInactive(_ view: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = self.inactiveGray
        })
    }
    
    
    
    
    // MARK: Actions
    
    @IBAction func directionChanged(_ sender: SegmentedControl) {
        
        ride.direction = segmentedControl.getDirection()
        
        if timeHint.isHidden == false {
            if segmentedControl.getDirection() == "from" {
                timeHint.text = String("(event ends at \(event.getEndTime())\(event.getEndAmOrPm()))")
                
                endDateHint.isHidden = false
                endDateHint.text = String("(event ends on \(event.getEndDate()))")
            }
                
            else if segmentedControl.getDirection() == "to" || segmentedControl.getDirection() == "both" {
                endDateHint.isHidden = true
                timeHint.text = String("(event starts at \(event.getStartTime())\(event.getAmOrPm()))")
            }
        }
    }
    
    @IBAction func directionPicked(_ sender: UISegmentedControl) {
        switch direction.selectedSegmentIndex {
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
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        //Validation here
        
        if validateName() == false { return}
        if validateNumber() == false {return}
        if validateEvent() == false {return}
        if validateTime() == false {return}
        if validateLoc() == false {return}
        if validateSeats() == false {return}
        if validateDirection() == false {return}
        
        if timeField?.text != "" {
            ride.time = (timeField?.text)!
        }
        //Show the progress wheel and send offer
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        sendRideOffer()
        
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: Validators
    func validateName() -> Bool {
        if (nameField?.text != ""){
            nameField?.text = (nameField?.text)!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
        if (phoneField?.text != "") {
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
        
        
        if let components = GlobalUtils.dateComponentsFromDate(ride.getDepartureDate()){
            ride.day = (components.day)!
            ride.monthNum = (components.month)!
            ride.year = (components.year)!
        }
        
        if let components = GlobalUtils.dateComponentsFromDate(ride.getDepartureTime()){
            ride.hour = (components.hour)!
            ride.minute = (components.minute)!
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
        if(convertedDict.count > 0){
            let map = convertedDict
            
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
    
    func validateSeats() -> Bool{
        if seatsField?.text != "" {
            if let val = Int((seatsField?.text)!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)){
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
            CruClients.getServerClient().checkIfValidNum(Double(parsedNum!)!, handler: postRideOffer)
        }
        
    }
    
    func postRideOffer(_ success: Bool){
        if (success){
            
            //CruClients.getRideUtils().postRideOffer(ride.eventId, name: ride.driverName, phone: ride.driverNumber, seats: ride.seats, time: ride.getTimeInServerFormat(), location: location.getLocationAsDict(location), radius: ride.radius, direction: ride.direction, handler:  handleRequestResult)
            CruClients.getRideUtils().postRideOffer(ride.eventId, name: ride.driverName, phone: (self.phoneField?.text)!, seats: ride.seats, time: ride.getTimeInServerFormat(), location: self.convertedDict, radius: ride.radius, direction: ride.direction, handler:  handleRequestResult)
        }else{
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            showValidationError(ValidationErrors.phoneUnauthorized)
        }
    }
    
    func handleRequestResult(_ result : Ride?){
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        if result != nil {
            
            
            if(rideVC != nil){
                self.rideVC.refresh(self)
                presentAlert("Success", msg: "Thank you! Your ride has been created!", handler:  {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                        
                    }
                })
            }
            else{
                presentAlert("Ride Offered", msg: "Thank you! Your offered ride has been created! You can view your ride offer in the Ridehsaring section.", handler:  {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                        
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
        ride.departureDate = event.startNSDate.addHours(-1)
        
        //Set the text in the fields
        dateField!.text = ride.getDepartureDay()
        timeField!.text = ride.getDepartureTime()
        ride.direction = "both"
        
        //show the time hint
        timeHint.isHidden = false
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
        search.start { (response, error) in
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
    func chooseDateHandler(_ month : Int, day : Int, year : Int){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM d yyyy"
        
        //if date formatter returns nil return the current date/time
        if let date = dateFormatter.date(from: String(month) + " " + String(day) + " " + String(year)) {
            ride.date = date
            ride.monthNum = month
            ride.day = day
            ride.year = year
            ride.departureDay = date
            self.dateField?.text = ride.getDate()
        }
    }
    
    //called when a time is chosen
    func datePicked(_ obj: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeField!.text = formatter.string(from: obj)
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.hour, .minute], from: obj)
        ride.hour = comp.hour!
        ride.minute = comp.minute!
        ride.timeStr = (timeField?.text)!
        ride.departureTime = obj
    }
    
    func dismissLocationPicker(_ sender: UIBarButtonItem) {
        print("\nNow this gets executed\n")
        navigationController!.popViewController(animated: true)
    }
    
    func sendLocation(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    func setRadius(_ radius: Int){
        ride.radius = radius
        pickupRadiusField?.text = ride.getRadius()
        pickupLine.backgroundColor = inactiveGray
    }
    
    // MARK: Pickup Location Function
    //Called when the pickup location text field becomes active
    func presentCustomPicker() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    func googlePlacePicker() {
        // Create a place picker.
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePicker(config: config)
        
        
        // Present it fullscreen.
        placePicker.pickPlace { (place, error) in
            
            // Handle the selection if it was successful.
            if let place = place {
                // Create the next view controller we are going to display and present it.
                //let nextScreen = PlaceDetailViewController(place: place)
                //self.splitPaneViewController?.pushViewController(nextScreen, animated: false)
                //self.mapViewController?.coordinate = place.coordinate
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place attributions \(place.attributions)")
            } else if error != nil {
                // In your own app you should handle this better, but for the demo we are just going to log
                // a message.
                NSLog("An error occurred while picking a place: \(error)")
            } else {
                NSLog("Looks like the place picker was canceled by the user")
            }
            
            // Release the reference to the place picker, we don't need it anymore and it can be freed.
            self.placePicker = nil
        }
        
        // Store a reference to the place picker until it's finished picking. As specified in the docs
        // we have to hold onto it otherwise it will be deallocated before it can return us a result.
        self.placePicker = placePicker
    }
    
    /*func choosePickupLocation(sender: AnyObject) {
        
        
        
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
    }*/
    
    // MARK: Changing UI
    
    func addTextFieldError(_ view: UIView){
        UIView.animate(withDuration: 0.5, animations: {
            //view.backgroundColor = UIColor(red: 190/255, green: 59/255, blue: 52/255, alpha: 1.0)
            view.backgroundColor = UIColor.red
        })
    }
    
    func removeTextFieldError(_ view: UIView){
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = self.inactiveGray
        })
    }
    
    func showValidationError(_ error: String){
        let alert = UIAlertController(title: error, message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: {})
    }
    
    fileprivate func presentAlert(_ title: String, msg: String, handler: @escaping ()->()) {
        let cancelRideAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        cancelRideAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            handler()
            
        }))
        present(cancelRideAlert, animated: true, completion: nil)
        
    }
    
    /* Prevents the event popover to not fill the entire screen */
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "radiusPicker" {
            if self.pickedLocation == nil {
                showValidationError("Please pick a location before picking a radius.")
                
                return false
            }
            pickupLine.backgroundColor = inactiveGray
            return true
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == OfferRideConstants.chooseEventSegue{
            let eventVC = segue.destination as! EventsPopoverViewController
            eventVC.events = self.events
            eventVC.offerRide = self
            
            eventVC.popoverPresentationController?.sourceView = self.eventField
            eventVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.75, height: self.view.frame.height * 0.5)
            eventVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.frame.width / 2, y: 15,width: 0,height: 0)
            eventVC.popoverPresentationController?.permittedArrowDirections = .up
            
            
            let controller = eventVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
        }
        else if(segue.identifier == OfferRideConstants.editRadiusSegue){
            let vc = segue.destination as! PickRadiusViewController
            vc.ride = self.ride
            vc.setRadius = setRadius
            vc.numMiles = ride.radius
            //vc.pickedLocation = self.pickedLocation
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
//Extension for the Google Places picker
extension NewOfferRideViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController!.popViewController(animated: true)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
