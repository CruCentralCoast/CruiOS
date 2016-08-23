//
//  NewDriverRideDetailViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/12/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit
import MRProgress
import GooglePlaces
import LocationPicker
import LocationPickerViewController

struct IllustrationConstants{
    static let toEvent = "to-event"
    static let fromEvent = "from-event"
    static let noPassengers = "driver-only"
    static let onePassenger = "one-passenger"
    static let twoPassengers = "two-passengers"
    static let threePassengers = "three-passengers"
    static let fourPassengers = "four-passengers"
    static let fivePassengers = "five-passengers"
    static let fullCar = "full-car"
}

class NewDriverRideDetailViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var illustrationView: UIView!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var directionImage: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    
    
    //Fields
    @IBOutlet weak var eventField: UITextField?
    @IBOutlet weak var dateField: UITextField?
    @IBOutlet weak var timeField: UITextField?
    @IBOutlet weak var addressField: UITextField?
    @IBOutlet weak var pickupField: UITextField?
    @IBOutlet weak var offeredField: UITextField?
    @IBOutlet weak var availableField: UITextField?
    @IBOutlet weak var directionField: UITextField?
    
    //Lines
    @IBOutlet weak var eventLine: UIView!
    @IBOutlet weak var dateLine: UIView!
    @IBOutlet weak var timeLine: UIView!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var pickupLine: UIView!
    @IBOutlet weak var offeredLine: UIView!
    
    //Hints
    @IBOutlet weak var endDateHint: UILabel!
    @IBOutlet weak var timeHint: UILabel!
    
    //Buttons
    @IBOutlet weak var viewPassengers: UIButton!
    @IBOutlet weak var cancelRide: UIButton!
    
    var rideVC: RidesViewController?
    var event: Event!
    var gradientGray = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
    var passengers = [Passenger]()
    var passengersToDrop = [Passenger]()
    var passesToDrop : Int!
    var passesDropped : Int!
    var convertedDict = NSDictionary()
    var CLocation: CLLocation?
    var editModeActivated = false
    var ride: Ride!{
        didSet {
            
        }
    }
    var pickedLocation: GMSPlace! {
        didSet {
            addressField?.text = pickedLocation.formattedAddress
            let delimiter = ", "
            
            let parts = pickedLocation.formattedAddress!.componentsSeparatedByString(delimiter)
            
            
            let newDel = " "
            let components = parts[2].componentsSeparatedByString(newDel)
            let state = components[0]
            let postalcode = components[1]
            let address = parts[0]
            let city = parts[1]
            let country = parts[3]
            
            convertedDict = ["country": country, "state": state, "street1": address, "postcode": postalcode, "suburb": city]
            CLocation = CLLocation(latitude: pickedLocation.coordinate.latitude, longitude: pickedLocation.coordinate.longitude)
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
            validateLoc()
            
        }
    }
    var inactiveGray = UIColor(red: 149/225, green: 147/225, blue: 145/225, alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Load the passengers list
        CruClients.getRideUtils().getPassengersByIds(ride.passengers, inserter: insertPassenger, afterFunc: {success in
            //TODO: should be handling failure here
        })
        
        
        self.navigationItem.title = "Ride Details"
        eventField?.delegate = self
        dateField?.delegate = self
        timeField?.delegate = self
        addressField?.delegate = self
        pickupField?.delegate = self
        offeredField?.delegate = self
        offeredField?.keyboardType = .NumberPad
        availableField?.delegate = self
        directionField?.delegate = self
        
        setupIllustration()
        
        fillRideInfo()
        normalMode()
        editModeActivated = false
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //Set up the gradient background after the constraints are set
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = illustrationView.frame
        
        
        gradient.colors = [gradientGray.CGColor, UIColor.whiteColor().CGColor]
        illustrationView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    //Called for every passenger returned from the database query
    func insertPassenger(newPassenger: NSDictionary){
        let newPassenger = Passenger(dict: newPassenger)
        passengers.append(newPassenger)
    }
    
    //Set up the illustration to have the right images
    func setupIllustration() {
        //Set direction image
        if ride.direction == "to" {
            directionImage.image = UIImage(named: IllustrationConstants.toEvent)
        }
        else if ride.direction == "from" {
            directionImage.image = UIImage(named: IllustrationConstants.fromEvent)
        }
        
        //Set labels
        addresslabel.text = String("\(ride.street)\n \(ride.city)")
        eventLabel.text = ride.eventName
        
        //Set car image
        switch ride.passengers.count {
        case 0:
            carImage.image = UIImage(named: IllustrationConstants.noPassengers)
        case 1:
            carImage.image = UIImage(named: IllustrationConstants.onePassenger)
        case 2:
            carImage.image = UIImage(named: IllustrationConstants.twoPassengers)
        case 3:
            carImage.image = UIImage(named: IllustrationConstants.threePassengers)
        case 4:
            carImage.image = UIImage(named: IllustrationConstants.fourPassengers)
        case 5:
            carImage.image = UIImage(named: IllustrationConstants.fivePassengers)
        default:
            carImage.image = UIImage(named: IllustrationConstants.fullCar)
        }
        
        
    }
    
    //Fill all the text fields with ride information
    func fillRideInfo() {
        
        eventField?.text = ride.eventName
        dateField?.text = ride.getDate()
        timeField?.text = ride.getTime()
        addressField?.text = ride.getCompleteAddress()
        pickupField?.text = ride.getRadius()
        offeredField?.text = String(ride.seats)
        availableField?.text = ride.seatsLeft()
        directionField?.text = ride.getDirection()
    }
    
    // MARK: Button actions
    func normalMode() {
        eventLine?.backgroundColor = UIColor.clearColor()
        dateLine?.backgroundColor = UIColor.clearColor()
        timeLine?.backgroundColor = UIColor.clearColor()
        addressLine?.backgroundColor = UIColor.clearColor()
        pickupLine?.backgroundColor = UIColor.clearColor()
        offeredLine?.backgroundColor = UIColor.clearColor()
        
        endDateHint.hidden = true
        timeHint.hidden = true
        
        //Disable editing
        eventField?.userInteractionEnabled = false
        dateField?.userInteractionEnabled = false
        timeField?.userInteractionEnabled = false
        addressField?.userInteractionEnabled = false
        pickupField?.userInteractionEnabled = false
        offeredField?.userInteractionEnabled = false
        availableField?.userInteractionEnabled = false
        directionField?.userInteractionEnabled = false
        
        //Add edit bar button item
        //Add the edit button to the nav bar
        
        /*let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(editMode))
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!], forState: .Normal)*/
    }

    //Transform field to edit fields
    func editMode(){
        editModeActivated = true
        //Replace the edit button with a save button
        let saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(saveRide))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!], forState: .Normal)
        
        viewPassengers.setImage(UIImage(named: "edit-passengers"), forState: .Normal)
        
        
        //Enable editing for certain fields
        dateField?.userInteractionEnabled = true
        timeField?.userInteractionEnabled = true
        addressField?.userInteractionEnabled = true
        pickupField?.userInteractionEnabled = true
        offeredField?.userInteractionEnabled = true
        
        //Change the color of the lines under editable fields
        makeFieldInactive(dateLine)
        makeFieldInactive(timeLine)
        makeFieldInactive(addressLine)
        makeFieldInactive(pickupLine)
        makeFieldInactive(offeredLine)
        
    }
    
    //Save the ride once it's been edited
    func saveRide() {
        if validateTime() == false {return}
        if validateLoc() == false {return}
        if validateSeats() == false {return}
        
        
        //Show the progress wheel and send offer
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        self.passesToDrop = self.passengersToDrop.count
        
        if(self.passesToDrop != 0){
            for pass in self.passengersToDrop{
                CruClients.getRideUtils().dropPassenger(ride.id, passengerId: pass.id, handler: handleDropPass)
            }
        }
        else{
            sendPatchRequest()
        }
        
        normalMode()
    }
    
    //Handle dropping passengers
    func handleDropPass(success: Bool){
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
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            presentAlert("Could not drop a passenger", msg: "", handler: {  })
        }
    }
    
    //Send request to database
    func sendPatchRequest(){
        CruClients.getRideUtils().patchRide(ride.id, params: [RideKeys.passengers: ride.passengers, RideKeys.radius: ride.radius, RideKeys.driverName: ride.driverName, RideKeys.direction: ride.direction, RideKeys.driverNumber: ride.driverNumber, RideKeys.time : ride.getTimeInServerFormat(), RideKeys.seats: ride.seats, LocationKeys.loc: [LocationKeys.postcode: ride.postcode, LocationKeys.state : ride.state, LocationKeys.street1 : ride.street, LocationKeys.city: ride.city, LocationKeys.country: ride.country]], handler: handlePostResult)
    }
    
    //We get the new ride back if patch was successfull
    func handlePostResult(ride: Ride?){
        
        if(ride?.hour != -1){
            let alert = UIAlertController(title: "Ride updated successfully", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: {
                //self.navigationController?.popViewControllerAnimated(true)
            })
            self.ride = ride
        }
        else{
            let alert = UIAlertController(title: "Could not update ride", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    /* Functions for handling ride cancellation */
    @IBAction func cancelPressed(sender: UIButton) {
        Cancler.confirmCancel(self, handler: cancelConfirmed)
    }
    
    func cancelConfirmed(action: UIAlertAction){
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        CruClients.getRideUtils().leaveRideDriver(ride.id, handler: handleCancelResult)
    }
    
    func handleCancelResult(success: Bool){
        if(success){
            Cancler.showCancelSuccess(self, handler: { action in
                if let navController = self.navigationController {
                    navController.popViewControllerAnimated(true)
                    self.rideVC?.refresh(self)
                }
                
            })
        }
        else{
            Cancler.showCancelFailure(self)
        }
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }
    
    @IBAction func viewOrEditPassengers(sender: UIButton) {
        if editModeActivated {
            self.performSegueWithIdentifier("viewPassengers", sender: self)
        }
        
    }
    
    
    // MARK: Validators
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
    
    func validateSeats() -> Bool{
        if offeredField?.text != "" {
            if let val = Int((offeredField?.text)!.stringByTrimmingCharactersInSet(
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
                addTextFieldError(offeredLine!)
            }
        }
        
        return true
    }
    
    // MARK: Text Field Functions
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case dateField!:
            highlightField(dateLine)
            dateField?.resignFirstResponder()
            TimePicker.pickDate(self, handler: chooseDateHandler)
        case timeField!:
            highlightField(timeLine)
            timeField?.resignFirstResponder()
            TimePicker.pickTime(self)
        case addressField!:
            highlightField(addressLine)
            addressField?.resignFirstResponder()
            choosePickupLocation(self)
        case pickupField!:
            highlightField(pickupLine)
            pickupField?.resignFirstResponder()
            
            if(self.loc != nil){
                //self.performSegueWithIdentifier("editRadius", sender: self)
                
            }
            else{
                showValidationError("Please pick a location before picking a radius.")
            }
        case offeredField!:
            highlightField(offeredLine)
        //seatsLine?.backgroundColor = CruColors.lightBlue
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        switch textField {
        case dateField!:
            makeFieldInactive(dateLine)
        case timeField!:
            makeFieldInactive(timeLine)
        case addressField!:
            makeFieldInactive(addressLine)
        case pickupField!:
            makeFieldInactive(pickupLine)
        case offeredField!:
            makeFieldInactive(offeredLine)
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case dateField!:
            dateField?.resignFirstResponder()
        case timeField!:
            timeField?.resignFirstResponder()
        case pickupField!:
            pickupField?.resignFirstResponder()
        case offeredField!:
            offeredField?.resignFirstResponder()
        default:
            print("Text field not recognizied")
        }
        return true
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
    
    func dismissLocationPicker(sender: UIBarButtonItem) {
        print("\nNow this gets executed\n")
        navigationController!.popViewControllerAnimated(true)
    }
    
    func sendLocation(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    func setRadius(radius: Int){
        ride.radius = radius
        pickupField?.text = ride.getRadius()
        
    }
    
    // MARK: Validation UI Functions
    
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

    
    // MARK: - Navigation
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //Prepare for passenger segue
        if segue.identifier == "viewPassengers" {
            let popoverVC = segue.destinationViewController
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.96, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), (addressField?.frame.origin.y)! - 50.0,0,0)
            
            let controller = popoverVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
            
            if let vc = popoverVC as? PassengersViewController{
                vc.passengers = self.passengers
                if editModeActivated == true {
                    vc.editable = true
                    vc.editVC = self
                }
            }
        }
        else if segue.identifier == EditRideConstants.editPassengersSegue {
            let popoverVC = segue.destinationViewController
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.97, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), (offeredField?.frame.origin.y)! - 50.0,0,0)
            
            let controller = popoverVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
            
            if let vc = popoverVC as? PassengersViewController{
                vc.passengers = self.passengers
                vc.editable = true
                vc.editVC = self
            }
        }
        else if segue.identifier == "editRadius" {
            let vc = segue.destinationViewController as! PickRadiusViewController
            vc.ride = self.ride
            vc.setRadius = setRadius
            vc.numMiles = ride.radius
            //vc.pickedLocation = self.pickedLocation
            vc.location = CLocation
        }
    }
    

}
