//
//  EditRideViewController.swift
//  Cru
//
//  This class represents the view and controller whereby a user can edit
//  all of the details of their ride or create a new ride. This page segues into
//  a radius editor, address picker, and spawns popovers to allow the user
//  to edit passengers and direction of the ride. Everything but the ride's
//  event is editable.
//
//  Created by Max Crane on 5/3/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit
import LocationPicker
import MRProgress

enum EditTags: Int {
    case time
    case date
    case address
    case radius
    case direction
    case seats
    case name
    case number
}

struct EditRideConstants{
    static let pageTitle = "Edit Ride"
    static let cellIdentifier = "cell"
    static let editDirectionSegue = "direction"
    static let editRadiusSegue = "radius"
    static let editPassengersSegue = "editPassengerSegue"
    static let bottomButton = "Save"
}

struct OfferRideConstants{
    static let pageTitle = "Offer Ride"
    static let bottomButton = "Submit"
    static let chooseEventSegue = "chooseEvent"
}

class OfferOrEditRideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var bottomButton: UIButton!
    var isOfferingRide = false
    
    var events = [Event]()
    var event : Event!{
        didSet{
            if(ride != nil){
                syncRideToEvent()
            }
        }
    }
    var ride : Ride!{
        didSet{
            if(event != nil){
                syncRideToEvent()
            }
        }
    }
    var location: Location! {
        didSet {
            addressValue.text? = location.address
            extractLocationFromView()
            updateOptions()
        }
    }
    var options = [EditableItem]()
    var directionOption: EditableItem!
    var passengers = [Passenger]()
    var passengersToDrop = [Passenger]()
    
    var CLocation: CLLocation?
    var timeValue: UILabel!
    var dateValue: UILabel!
    var directionValue: UILabel!
    var addressValue: UILabel!
    var pickupRadius: UITextView!
    var seatsValue: UITextView!
    var nameValue: UITextView!
    var numberValue: UITextView!
    var passengerValue: UITextView!
    var eventValue: UILabel!
    var hasUserEdited = false
    var directionCell: UITableViewCell!
    var directionCellPath: IndexPath!
    var passesToDrop : Int!
    var passesDropped : Int!
    var parsedNum : String?
    
    var updateFunctions: [()->()] = []
    var rideDetailVC: DriverRideDetailViewController!
    var rideVC: RidesViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(rideDetailVC != nil){
            updateFunctions.append(rideDetailVC.updateData)
        }
        
        if(rideVC != nil){
            updateFunctions.append(rideVC.refresh)
        }
        
        
        if(isOfferingRide){
            self.navigationItem.title = OfferRideConstants.pageTitle
            self.ride = Ride()
            bottomButton.setTitle(OfferRideConstants.bottomButton, for: UIControlState())
            
        }
        else{
            self.navigationItem.title = EditRideConstants.pageTitle
            bottomButton.setTitle(EditRideConstants.bottomButton, for: UIControlState())
            getRideLocation()
        }
        
        if(event != nil && ride != nil){
            ride.eventStartDate = event.startNSDate
            ride.eventEndDate = event.endNSDate
        }
        else{
            //event = Event()
        }
        
        populateOptions()
        
    }
    
    func syncRideToEvent(){
        ride.eventName = event.name
        ride.eventId = event.id
        ride.eventStartDate = event.startNSDate
        ride.eventEndDate = event.endNSDate
        ride.departureDate = event.startNSDate
    }
    
    
    func populateOptions(){
        options.append(EditableItem(itemName: Labels.eventLabel, itemValue: ride.eventName, itemEditable: isOfferingRide, itemIsText: false))
        
        
        options.append(EditableItem(itemName: Labels.departureTimeLabel, itemValue: ride.getDepartureTime(), itemEditable: true, itemIsText: false))
        options.append(EditableItem(itemName: Labels.departureDateLabel, itemValue: ride.getDepartureDay(), itemEditable: true, itemIsText: false))
        
        
        
        options.append(EditableItem(itemName: Labels.addressLabel, itemValue: ride.getCompleteAddress(), itemEditable: true, itemIsText: false))
        options.append(EditableItem(itemName: Labels.pickupRadius, itemValue: ride.getRadius(), itemEditable: true, itemIsText: true))
        directionOption = EditableItem(itemName: Labels.directionLabel, itemValue: ride.getDirection(), itemEditable: true, itemIsText: false)
        options.append(directionOption)
        
        if (!isOfferingRide){
            options.append(EditableItem(itemName: Labels.seatsLabel, itemValue: String(ride.seats), itemEditable: true, itemIsText: true))
            options.append(EditableItem(itemName: Labels.passengers, itemValue: String(ride.passengers.count), itemEditable: true, itemIsText: false))
        }
        else{
            options.append(EditableItem(itemName: Labels.seatsOfferLabel, itemValue: String(ride.seats), itemEditable: true, itemIsText: true))
        }
        
        options.append(EditableItem(itemName: Labels.nameLabel, itemValue: ride.driverName, itemEditable: true, itemIsText: true))
        options.append(EditableItem(itemName: Labels.phoneLabel, itemValue: "", itemEditable: true, itemIsText: true))
    }
    
    func updateOptions(){
        for option in options{
            switch option.itemName{
            case Labels.eventLabel:
                option.itemValue = ride.eventName
            case Labels.nameLabel:
                option.itemValue = ride.driverName
            case Labels.seatsLabel:
                option.itemValue = String(ride.seats)
            case Labels.seatsOfferLabel:
                option.itemValue = String(ride.seats)
            case Labels.pickupRadius:
                option.itemValue = ride.getRadius()
            case Labels.directionLabel:
                option.itemValue = ride.getDirection()
            case Labels.phoneLabel:
                option.itemValue = ride.driverNumber
            case Labels.departureTimeLabel:
                option.itemValue = ride.getDepartureTime()
            case Labels.departureDateLabel:
                option.itemValue = ride.getDepartureDay()
            case Labels.addressLabel:
                option.itemValue = ride.getCompleteAddress()
            case Labels.passengers:
                option.itemValue = String(ride.passengers.count)
            default:
                print("")
            }
        }
        self.table?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditRideConstants.cellIdentifier) as! EditCell
        let option = options[indexPath.row]
        
        cell.contentType.text = option.itemName
        cell.contentValue.text = option.itemValue
        cell.editButton.setTitle(option.itemName, for: UIControlState())
        
        if option.itemIsText! {
            cell.contentValue.isHidden = true
            cell.contentTextField.isHidden = false
            cell.contentTextField.text = option.itemValue
        }
        else{
            cell.contentTextField.isHidden = true
            cell.contentValue.isHidden = false
        }
        
        switch (cell.contentType.text!){
        case Labels.eventLabel:
            if(isOfferingRide){
                eventValue = cell.contentValue
            }
        case Labels.departureTimeLabel:
            timeValue = cell.contentValue
            
        case Labels.departureDateLabel:
            dateValue = cell.contentValue
            
        case Labels.seatsLabel:
            cell.contentTextField.keyboardType = .numberPad
            cell.contentTextField.tag = EditTags.seats.rawValue
            cell.contentTextField.delegate = self
            seatsValue = cell.contentTextField
            
        case Labels.seatsOfferLabel:
            cell.contentTextField.keyboardType = .numberPad
            cell.contentTextField.tag = EditTags.seats.rawValue
            cell.contentTextField.delegate = self
            seatsValue = cell.contentTextField
            
        case Labels.addressLabel:
            addressValue = cell.contentValue
            
        case Labels.nameLabel:
            nameValue = cell.contentTextField
            nameValue.delegate = self
            cell.contentTextField.tag = EditTags.name.rawValue
            cell.contentTextField.keyboardType = .default
            nameValue.delegate = self
            
        case Labels.phoneLabel:
            cell.contentTextField.keyboardType = .numberPad
            cell.contentTextField.tag = EditTags.number.rawValue
            numberValue = cell.contentTextField
            numberValue.delegate = self
            numberValue.text = PhoneFormatter.unparsePhoneNumber(ride.driverNumber)
            
        case Labels.directionLabel:
            directionValue = cell.contentValue
            directionCell = cell
            directionCellPath = indexPath
            
        case Labels.pickupRadius:
            pickupRadius = cell.contentTextField
            pickupRadius.tag = EditTags.radius.rawValue
            pickupRadius.delegate = self
            pickupRadius.isEditable = false
            
        case Labels.passengers:
            passengerValue = cell.contentTextField
            
        default:
            print("error in switch statement on edit ride page")
        }
        
        cell.editButton.isHidden = !(option.itemEditable)
        table = tableView
        
        return cell
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        let editChoice = sender.currentTitle
        hasUserEdited = true
        
        switch editChoice!{
        case Labels.departureTimeLabel:
            TimePicker.pickTime(self)
        case Labels.departureDateLabel:
            TimePicker.pickDate(self, handler: chooseDateHandler)
        case Labels.addressLabel:
            choosePickupLocation(self)
        case Labels.nameLabel:
            nameValue.becomeFirstResponder()
        case Labels.phoneLabel:
            numberValue.becomeFirstResponder()
        case Labels.seatsLabel:
            seatsValue.becomeFirstResponder()
        case Labels.seatsOfferLabel:
            seatsValue.becomeFirstResponder()
        case Labels.directionLabel:
            self.performSegue(withIdentifier: EditRideConstants.editDirectionSegue, sender: self)
        case Labels.pickupRadius:
            if(self.CLocation != nil){
                self.performSegue(withIdentifier: EditRideConstants.editRadiusSegue, sender: self)
            }
            else{
                showValidationError("Please pick a location before picking a radius.")
            }
        case Labels.passengers:
            self.performSegue(withIdentifier: EditRideConstants.editPassengersSegue, sender: self)
        case Labels.eventLabel:
            if (isOfferingRide){
                self.performSegue(withIdentifier: OfferRideConstants.chooseEventSegue, sender: self)
            }
        default:
            print("")
        }
        
    }
    
    //called when a date is chosen
    func chooseDateHandler(_ date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM d yyyy"
        
        ride.date = date
        
        //if date formatter returns nil return the current date/time
        /*if let date = dateFormatter.date(from: String(month) + " " + String(day) + " " + String(year)) {
            ride.date = date
            ride.monthNum = month
            ride.day = day
            ride.year = year
            //ride.departureDate = date
            self.dateValue.text = ride.getDate()
            self.dateValue.isHidden = false
            updateOptions()
            self.table.reloadData()
        }*/
    }
    
    //called when a time is chosen
    func datePicked(_ obj: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeValue.text = formatter.string(from: obj)
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.hour, .minute], from: obj)
        ride.hour = comp.hour!
        ride.minute = comp.minute!
        ride.timeStr = timeValue.text!
        //ride.departureDate = obj
        updateOptions()
    }
    
    func choosePickupLocation(_ sender: AnyObject) {
        let locationPicker = LocationPickerViewController()
        
        if self.location != nil {
            locationPicker.location = self.location
        }
        
        locationPicker.completion = { location in
            self.location = location
            self.CLocation = self.location.location
        }
        
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    func extractDateTimeFromView()->Bool{
        
        if(ride.eventStartDate == nil){
            showValidationError(ValidationErrors.noEvent)
            return false
        }
        
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
            showValidationError(ride.isValidTime())
            return false
        }
    }
    
    
    func extractLocationFromView()->Bool{
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
    
    
    func extractNameFromView() -> Bool{
        if (nameValue != nil){
            let error  = ride.isValidName(nameValue.text)
            if(error != ""){
                showValidationError(error)
                addTextViewError(nameValue)
                return false
            }
            else{
                ride.driverName = nameValue.text!
                removeTextViewError(nameValue)
                return true
            }
        }
        else{
            if(ride.driverName == ""){
                showValidationError(ValidationErrors.noName)
                return false
            }
            else{
                return true
            }
        }
        
    }
    
    func extractNumberFromView()->Bool{
        if (numberValue != nil){
            parsedNum = PhoneFormatter.parsePhoneNumber(numberValue.text!)
            
            let error  = ride.isValidPhoneNum(parsedNum!)
            if(error != ""){
                showValidationError(error)
                addTextViewError(numberValue)
                return false
            }
            else{
                ride.driverNumber = parsedNum!
                removeTextViewError(numberValue)
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
    
    
    func extractDirectionFromView(){
        if(directionValue != nil){
            ride.direction = ride.getServerDirectionValue(directionValue.text!)
        }
    }
    
    func extractNumSeats()->Bool{
        if (seatsValue != nil && seatsValue.text != ""){
            if let val = Int(seatsValue.text.trimmingCharacters(
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
            }
        }
        
        return true
    }
    
    
        
    
    @IBAction func savePressed(_ sender: AnyObject) {
        //extract seats, time, date, location, name, phone number (all if possible aka null checking)
        if(timeValue != nil){ ride.time = timeValue.text! }
        if(extractNumSeats() == false){return}
        
        //you must extract direction before time, time validation depends on direction of ride
        extractDirectionFromView()
        if(extractDateTimeFromView() == false){return}
        if(extractLocationFromView() == false){return}
        if (extractNameFromView() == false){return}
        if (extractNumberFromView() == false){return}
        
        if(isOfferingRide){
            if (validateOffer()) {
                MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
                sendRideOffer()
            }
            
        }
        else{
            
            self.passesToDrop = self.passengersToDrop.count
            
            if(self.passesToDrop != 0){
                for pass in self.passengersToDrop{
                    CruClients.getRideUtils().dropPassenger(ride.id, passengerId: pass.id, handler: handleDropPass)
                }
            }
            else{
                sendPatchRequest()
            }
            
        }
    }
    
    func validateOffer() -> Bool {
        if (location != nil) {
            return true
        } else {
            showValidationError(ValidationErrors.noDeparture)
            return false
        }
    }
    
    func sendPatchRequest(){
        CruClients.getRideUtils().patchRide(ride.id, params: [RideKeys.passengers: ride.passengers, RideKeys.radius: ride.radius, RideKeys.driverName: ride.driverName, RideKeys.direction: ride.direction, RideKeys.driverNumber: ride.driverNumber, RideKeys.time : ride.getTimeInServerFormat(), RideKeys.seats: ride.seats, LocationKeys.loc: [LocationKeys.postcode: ride.postcode, LocationKeys.state : ride.state, LocationKeys.street1 : ride.street, LocationKeys.city: ride.city, LocationKeys.country: ride.country]], handler: handlePostResult)
    }
    func sendRideOffer(){
        if parsedNum != nil {
            CruClients.getServerClient().checkIfValidNum(Double(parsedNum!)!, handler: postRideOffer)
        }
        
    }
    
    func postRideOffer(_ success: Bool){
        if (success){
            CruClients.getRideUtils().postRideOffer(ride.eventId, name: nameValue.text, phone: numberValue.text, seats: ride.seats, time: ride.getTimeInServerFormat(), location: location.getLocationAsDict(location) as NSDictionary, radius: ride.radius, direction: ride.direction, handler:  handleRequestResult)
        }else{
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            showValidationError(ValidationErrors.phoneUnauthorized)
        }
    }
    
    func handleDropPass(_ success: Bool){
        if(self.passesDropped == nil){
            self.passesDropped = 0
        }
        
        
        if(success){
            self.passesDropped = self.passesDropped + 1
            if(self.passesDropped == self.passengersToDrop.count){
                self.passesDropped = 0
                self.passengersToDrop.removeAll()
                sendPatchRequest()
            }
        }
        else{
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            presentAlert("Could not drop a passenger", msg: "", handler: {  })
        }
    }
    
    func handleRequestResult(_ result : Ride?){
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        if result != nil {
            
            
            if(rideVC != nil){
                self.rideVC.refresh(self)
                presentAlert("Ride Offered", msg: "Thank you! Your offered ride has been created!", handler:  {
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
    
    fileprivate func presentAlert(_ title: String, msg: String, handler: @escaping ()->()) {
        let cancelRideAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        cancelRideAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            handler()
            
        }))
        present(cancelRideAlert, animated: true, completion: nil)
        
    }
    
    func addTextViewError(_ textView: UITextView){
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.red.cgColor
    }
    
    func removeTextViewError(_ textView: UITextView){
        textView.layer.borderWidth = 0
    }
    
    func showValidationError(_ error: String){
        let alert = UIAlertController(title: error, message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: {})
    }
    
    
    func handlePostResult(_ ride: Ride?){
        
        if(ride?.hour != -1){
            let alert = UIAlertController(title: "Ride updated successfully", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: {
                //self.navigationController?.popViewControllerAnimated(true)
            })
            self.ride = ride
            self.table!.reloadData()
            rideDetailVC?.ride = ride
            
            for update in updateFunctions{
                update()
            }
        }
        else{
            let alert = UIAlertController(title: "Could not update ride", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func handleDirectionChoice(_ choice: String){
        directionValue.text = choice
        ride.direction = ride.getServerDirectionValue(choice)
        directionOption.itemValue = choice
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == EditRideConstants.editDirectionSegue){
            
            //uipopover magic
            let popoverVC = segue.destination
            let controller = popoverVC.popoverPresentationController
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width - 30, height: 195)
            
            if(controller != nil){
                controller?.delegate = self
            }
            
            if let vc = popoverVC as? DirectionTVC{
                vc.handler = handleDirectionChoice
            }
            let fromRect:CGRect = self.table!.rectForRow(at: directionCellPath!)
            controller!.sourceView = self.table
            controller!.sourceRect = fromRect
            controller!.permittedArrowDirections = .any
        }
        else if (segue.identifier == OfferRideConstants.chooseEventSegue){
            let eventVC = segue.destination as! EventsModalTableViewController
            eventVC.events = self.events
            eventVC.offerRide = self
            
            eventVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.97, height: self.view.frame.height * 0.77)
            eventVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (eventValue.frame.origin.y),width: 0,height: 0)
            eventVC.popoverPresentationController?.permittedArrowDirections = .any
            eventVC.popoverPresentationController?.sourceView = self.table
            
            let controller = eventVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
        }
        else if(segue.identifier == EditRideConstants.editRadiusSegue){
            let vc = segue.destination as! PickRadiusViewController
            vc.ride = self.ride
            vc.setRadius = setRadius
            vc.numMiles = ride.radius
            //vc.location = CLocation
        }
        else if(segue.identifier == EditRideConstants.editPassengersSegue){
            let popoverVC = segue.destination
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.97, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (passengerValue?.frame.origin.y)! - 50.0,width: 0,height: 0)
            
            let controller = popoverVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
            
            if let vc = popoverVC as? PassengersViewController{
                vc.passengers = self.passengers
                vc.editable = true
                vc.parentEditVC = self
            }
        }
    }
    
    
    func setRadius(_ radius: Int){
        ride.radius = radius
        pickupRadius.text = ride.getRadius()
        updateOptions()
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let senderId = textView.tag
        
        switch senderId{
        case EditTags.name.rawValue:
            ride.driverName = nameValue.text
        case EditTags.number.rawValue:
            ride.driverNumber = numberValue.text
        case EditTags.direction.rawValue:
            ride.direction = ride.getServerDirectionValue(directionValue.text!)
        case EditTags.seats.rawValue:
            if let val = Int(seatsValue.text.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)){
                if (ride.numSeatsNeedToDrop(val) >= 1 && val > 0){
                    needToDropPassenger(val, numToDrop: ride.numSeatsNeedToDrop(val))
                }
                else{
                    ride.seats = val
                }
            }
        default:
            print("Issue -1 on edit ride page")
        }
        updateOptions()
    }
    
    func needToDropPassenger(_ num : Int, numToDrop: Int){
        var message = "If you want to lower the number of offered seats to " +
            String(num) + ", you must drop " + String(numToDrop)
        
        if(numToDrop == 1){
            message += " passenger."
        }
        else{
            message += " passengers."
        }
        
        showValidationError(message)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(textView == nameValue || textView == seatsValue){
            return GlobalUtils.shouldChangeNameTextInRange(textView.text, range: range, text: text)
        }
        else if (textView == numberValue) {
            let res = GlobalUtils.shouldChangePhoneTextInRange(numberValue.text, range: range, replacementText: text)
            numberValue.text = res.newText
            return res.shouldChange
        }
        
        return false
    }
    
}
