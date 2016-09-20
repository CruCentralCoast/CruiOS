//
//  OfferRideViewController.swift
//  Cru
//
//  Created by Max Crane on 4/14/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import RadioButton
import SwiftValidator
import ActionSheetPicker_3_0
import MapKit
import LocationPicker
import MRProgress

class OfferRideViewController: UIViewController, ValidationDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate{
    @IBOutlet weak var numSeats: UILabel!
    @IBOutlet weak var roundTripButton: RadioButton!
    @IBOutlet weak var toEventButton: RadioButton!
    @IBOutlet weak var fromEventButton: RadioButton!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameFieldError: UILabel!
    @IBOutlet weak var chooseEventButton: UIButton!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var phoneFieldError: UILabel!
    @IBOutlet weak var pickupDate: UILabel!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var pickupLocation: UILabel!
    @IBOutlet weak var eventName: UILabel!
    
    var rideVC: RidesViewController?
    var checkImage = UIImage(named: "checked")
    var uncheckImage = UIImage(named: "unchecked")
    let validator = Validator()
    var events = [Event]()
    var chosenEvent:Event?
    var direction:String?
    var formHasBeenEdited = false
    var location: Location! {
        didSet {
            formHasBeenEdited = true
            pickupLocation.text? = location.address
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        phoneField.keyboardType = UIKeyboardType.NumberPad
        
        roundTripButton.setImage(checkImage, forState: UIControlState.Selected)
        roundTripButton.setImage(uncheckImage, forState: UIControlState.Normal)
        
        toEventButton.setImage(checkImage, forState: UIControlState.Selected)
        toEventButton.setImage(uncheckImage, forState: UIControlState.Normal)
        
        fromEventButton.setImage(checkImage, forState: UIControlState.Selected)
        fromEventButton.setImage(uncheckImage, forState: UIControlState.Normal)
        
        stepper.value = 1
        numSeats.text = "1"
        direction = "Round-Trip"
        
        validator.registerField(nameField, errorLabel: nameFieldError, rules: [RequiredRule(), FullNameRule()])
        validator.registerField(phoneField, errorLabel: phoneFieldError, rules: [RequiredRule(), PhoneNumberRule()])
        
        nameFieldError.text = ""
        phoneFieldError.text = ""
        //eventName.text = ""
        //pickupLocation.text = ""
        //pickupTime.text = ""
        //pickupDate.text = ""

        loadEvents()
        
        navigationItem.title = "Offer a Ride"
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(handleCancelRide(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        eventName.userInteractionEnabled = true // Remember to do this
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseEvent(_:)))
        eventName.addGestureRecognizer(tap)
        tap.delegate = self
        
        //this is here so the event the event name will show if this page was called from the event detail page
        if(chosenEvent != nil){
            eventName.text = chosenEvent!.name
        }
        
        pickupLocation.userInteractionEnabled = true
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "choosePickupLocation:")
        pickupLocation.addGestureRecognizer(tap2)
        tap2.delegate = self
        
        pickupTime.userInteractionEnabled = true
        let tap3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseTime:")
    
        pickupTime.addGestureRecognizer(tap3)
        tap3.delegate = self
        
        pickupDate.userInteractionEnabled = true
        let tap4: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseDate:")
        pickupDate.addGestureRecognizer(tap4)
        tap4.delegate = self
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func numSeatsChanged(sender: UIStepper) {
        var val =  Int(sender.value).description

        if(val == "0"){
            val = "1"
            sender.value = 1
        }
        
        numSeats.text = val
        
    }

    
    @IBAction func touchedButton(sender: AnyObject) {
        if let sendr = sender as? RadioButton{
            let text = sendr.titleLabel?.text
            if(text == "  Round-Trip"){
                direction = "Round-Trip"
            }
            else if(text == "  To Event"){
                direction =  "To Event"
            }
            else if(text == "  From Event"){
                direction = "From Event"
            }
            formHasBeenEdited = true

        }
    }
    
    
    func validationSuccessful() {
        
        if chosenEvent == nil{
            return
        }
        if direction == nil{
            return
        }
        
        if location == nil{
            return
        }
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        //CruClients.getRideUtils().postRideOffer(chosenEvent!.id, name: (nameField.text)!, phone: phoneField.text!, seats: Int(numSeats.text!)!, location: location.getLocationAsDict(location), radius: 1, direction: getDirection(), handler:  handleRequestResult)
        
        
    }
    
    
    
    // Function for returning a direction based off of what is picked in the diriver direction picker
    private func getDirection() -> String {
        if direction! == "To Event" {
            return "to"
        }
        else if direction! == "From Event" {
            return "from"
        }
        else {
            return "both"
        }
    }
    
    func handleRequestResult(result : Ride?){
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        if result != nil {
            presentAlert("Ride Offered", msg: "Thank you your offered ride has been created!", handler:  {
                if let navController = self.navigationController {
                    navController.popViewControllerAnimated(true)
                    self.rideVC?.refresh(self)
                }
            })
            
            
        } else {
            presentAlert("Ride Offer Failed", msg: "Failed to post ride offer", handler:  {})
        }
    }
    
    private func presentAlert(title: String, msg: String, handler: ()->()) {
        let cancelRideAlert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        cancelRideAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            action in
            handler()
            
        }))
        presentViewController(cancelRideAlert, animated: true, completion: nil)
        
    }
    
    
    func resetLabel(field: UITextField, error: UILabel){
        field.layer.borderColor = UIColor.clearColor().CGColor
        field.layer.borderWidth = 0.0
        error.text = ""
    }
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        var numValid = true
        var nameValid = true
        
        // turn the fields to red
        for (field, error) in validator.errors {
            field.layer.borderColor = UIColor.redColor().CGColor
            field.layer.borderWidth = 1.0
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.hidden = false
            
            if(field == nameField){
                nameValid = false
            }
            if(field == phoneField){
                numValid = false
            }
        }
        
        if(nameValid){
            resetLabel(nameField, error: nameFieldError)
        }
        if(numValid){
            resetLabel(phoneField, error: phoneFieldError)
        }
    }
    
    @IBAction func submitPressed(sender: UIButton) {
        validator.validate(self)
    }
    
    @IBAction func choosePickupLocation(sender: AnyObject) {
        let locationPicker = LocationPickerViewController()
        
        if self.location != nil {
            locationPicker.location = self.location
        }
        
        locationPicker.completion = { location in
            self.location = location
        }
        
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func chooseEventSelected(sender: AnyObject) {
        self.performSegueWithIdentifier("eventPopover", sender: self)
    }
    func chooseEvent(sender: UITapGestureRecognizer){
        chooseEventSelected(sender)
    }
    @IBAction func chooseTime(sender: UIButton) {
        TimePicker.pickTime(self)
    }
    
    @IBAction func chooseDate(sender: AnyObject) {
        TimePicker.pickDate(self, handler: chooseDateHandler)
    }
    
    func chooseDateHandler(month : Int, day : Int, year : Int){
        let month = String(month)
        let day = String(day)
        let year = String(year)
        
        self.pickupDate.text = month + "/" + day + "/" + year
        self.formHasBeenEdited = true
    }


    
    func datePicked(obj: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        pickupTime.text = formatter.stringFromDate(obj)
        formHasBeenEdited = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventPopover"{
            let vc  = segue.destinationViewController as? EventsModalTableViewController
            vc?.events = Event.eventsWithRideShare(events)
            vc?.vc = self
            let controller = vc?.popoverPresentationController
            if(controller != nil){
                controller?.delegate = self
            }
        }
    }
    
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: - Table view data source
    func loadEvents(){
        CruClients.getServerClient().getData(.Event, insert: insertEvent, completionHandler: {success in
            //TODO: should be handling failure
        })
    }
    
    func insertEvent(dict : NSDictionary) {
        events.insert(Event(dict: dict)!, atIndex: 0)
    }
    
    /* Function for handling canceling a submission of offering a ride. Displays an alert box if there is unsaved data in the offer ride form and asks the user if they would really like to exit */
    func handleCancelRide(sender: UIBarButtonItem) {
        if (formHasBeenEdited) {
            let cancelRideAlert = UIAlertController(title: "Cancel Ride", message: "Are you sure you would like to continue? All unsaved data will be lost!", preferredStyle: UIAlertControllerStyle.Alert)
            
            cancelRideAlert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: performBackAction))
            cancelRideAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            presentViewController(cancelRideAlert, animated: true, completion: nil)
        }
        else {
            performBackAction(UIAlertAction())
        }
    }
    
    // Helper function for popping the offer rides view controller from the view stack and show the rides table
    func performBackAction(action: UIAlertAction) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

}

extension Location {
    func getLocationAsDict(loc: Location) -> NSDictionary {
        var dict = [String:AnyObject]()
        
        if let street = loc.placemark.addressDictionary!["Street"] {
            dict[LocationKeys.street1] = street
        }
        
        if let state = loc.placemark.addressDictionary!["State"] {
            dict[LocationKeys.state] = state
        }
        
        if let zip = loc.placemark.addressDictionary!["ZIP"] {
            dict[LocationKeys.postcode] = zip
        }
        
        if let suburb = loc.placemark.addressDictionary!["locality"] {
            dict[LocationKeys.city] = suburb
        }
        else if let suburb = loc.placemark.addressDictionary!["subLocality"]{
            dict[LocationKeys.city] = suburb
        }
        else if let suburb = loc.placemark.addressDictionary!["SubAdministrativeArea"]{
            dict[LocationKeys.city] = suburb
        }
        return dict
        
        /*
            public var name: String? { get } // eg. Apple Inc.
            public var thoroughfare: String? { get } // street name, eg. Infinite Loop
            public var subThoroughfare: String? { get } // eg. 1
            public var locality: String? { get } // city, eg. Cupertino
            public var subLocality: String? { get } // neighborhood, common name, eg. Mission District
            public var administrativeArea: String? { get } // state, eg. CA
            public var subAdministrativeArea: String? { get } // county, eg. Santa Clara
            public var postalCode: String? { get } // zip code, eg. 95014
            public var ISOcountryCode: String? { get } // eg. US
            public var country: String? { get } // eg. United States
            public var inlandWater: String? { get } // eg. Lake Tahoe
            public var ocean: String? { get } // eg. Pacific Ocean
            public var areasOfInterest: [String]? { get } // eg. Golden Gate Park
        */
    }
}
