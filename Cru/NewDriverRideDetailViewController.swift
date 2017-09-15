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
    
    // MARK: - Properties
    @IBOutlet weak var illustrationView: UIView!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var directionImage: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    
    
    // MARK: Fields
    @IBOutlet weak var eventField: UITextField?
    @IBOutlet weak var dateField: UITextField?
    @IBOutlet weak var timeField: UITextField?
    @IBOutlet weak var addressField: UITextField?
    @IBOutlet weak var pickupField: UITextField?
    @IBOutlet weak var offeredField: UITextField?
    @IBOutlet weak var availableField: UITextField?
    @IBOutlet weak var directionField: UITextField?
    
    //MARK: Lines
    @IBOutlet weak var eventLine: UIView!
    @IBOutlet weak var dateLine: UIView!
    @IBOutlet weak var timeLine: UIView!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var pickupLine: UIView!
    @IBOutlet weak var offeredLine: UIView!
    
    //MARK: Hints
    @IBOutlet weak var endDateHint: UILabel!
    @IBOutlet weak var timeHint: UILabel!
    
    //MARK: Buttons
    @IBOutlet weak var viewPassengers: UIButton!
    @IBOutlet weak var cancelRide: UIButton!
    
    var timeComponents: DateComponents?
    var dateComponents: DateComponents?
    weak var rideVC: RidesViewController?
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
            
            let parts = pickedLocation.formattedAddress!.components(separatedBy: delimiter)
            
            
            let newDel = " "
            let components = parts[2].components(separatedBy: newDel)
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
        offeredField?.keyboardType = .numberPad
        availableField?.delegate = self
        directionField?.delegate = self
        
        setupIllustration()
        
        fillRideInfo()
        normalMode()
        editModeActivated = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Set up the gradient background after the constraints are set
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = illustrationView.frame
        
        
        gradient.colors = [gradientGray.cgColor, UIColor.white.cgColor]
        illustrationView.layer.insertSublayer(gradient, at: 0)
    }
    
    //Called for every passenger returned from the database query
    func insertPassenger(_ newPassenger: NSDictionary){
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
        availableField?.text = ride.seatsLeftAsString()
        directionField?.text = ride.getDisplayableDirection()
    }
    
    // MARK: - Button actions
    func normalMode() {
        eventLine?.backgroundColor = UIColor.clear
        dateLine?.backgroundColor = UIColor.clear
        timeLine?.backgroundColor = UIColor.clear
        addressLine?.backgroundColor = UIColor.clear
        pickupLine?.backgroundColor = UIColor.clear
        offeredLine?.backgroundColor = UIColor.clear
        
        endDateHint.isHidden = true
        timeHint.isHidden = true
        
        //Disable editing
        eventField?.isUserInteractionEnabled = false
        dateField?.isUserInteractionEnabled = false
        timeField?.isUserInteractionEnabled = false
        addressField?.isUserInteractionEnabled = false
        pickupField?.isUserInteractionEnabled = false
        offeredField?.isUserInteractionEnabled = false
        availableField?.isUserInteractionEnabled = false
        directionField?.isUserInteractionEnabled = false
        
        //Add edit bar button item
        //Add the edit button to the nav bar
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editMode))
        editButton.tintColor = CruColors.orange
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!], for: .normal)
    }

    //Transform field to edit fields
    func editMode(){
        editModeActivated = true
        //Replace the edit button with a save button
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveRide))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!], for: UIControlState())
        
        viewPassengers.setImage(UIImage(named: "edit-passengers"), for: UIControlState())
        
        
        //Enable editing for certain fields
        dateField?.isUserInteractionEnabled = true
        timeField?.isUserInteractionEnabled = true
        addressField?.isUserInteractionEnabled = true
        pickupField?.isUserInteractionEnabled = true
        offeredField?.isUserInteractionEnabled = true
        
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
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
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
    
    //Send request to database
    func sendPatchRequest(){
        CruClients.getRideUtils().patchRide(ride.id, params: [RideKeys.passengers: ride.passengers, RideKeys.radius: ride.radius, RideKeys.driverName: ride.driverName, RideKeys.direction: ride.direction, RideKeys.driverNumber: ride.driverNumber, RideKeys.time : ride.getTimeInServerFormat(), RideKeys.seats: ride.seats, LocationKeys.loc: [LocationKeys.postcode: ride.postcode, LocationKeys.state : ride.state, LocationKeys.street1 : ride.street, LocationKeys.city: ride.city, LocationKeys.country: ride.country]], handler: handlePostResult)
    }
    
    //We get the new ride back if patch was successfull
    func handlePostResult(_ ride: Ride?){
        
        if(ride?.hour != -1){
            let alert = UIAlertController(title: "Ride updated successfully", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: {
                //self.navigationController?.popViewControllerAnimated(true)
            })
            self.ride = ride
        }
        else{
            let alert = UIAlertController(title: "Could not update ride", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /* Functions for handling ride cancellation */
    @IBAction func cancelPressed(_ sender: UIButton) {
        Cancler.confirmCancel(self, handler: cancelConfirmed)
    }
    
    func cancelConfirmed(_ action: UIAlertAction){
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        CruClients.getRideUtils().leaveRideDriver(ride.id, handler: handleCancelResult)
    }
    
    func handleCancelResult(_ success: Bool){
        if(success){
            Cancler.showCancelSuccess(self, handler: { action in
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                    self.rideVC?.refresh(self)
                }
                
            })
        }
        else{
            Cancler.showCancelFailure(self)
        }
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    @IBAction func viewOrEditPassengers(_ sender: UIButton) {
        if editModeActivated {
            self.performSegue(withIdentifier: "viewPassengers", sender: self)
        }
        
    }
    
    
    // MARK: - Validators
    func validateTime() -> Bool {
        ride.eventStartDate = event.startNSDate
        ride.eventEndDate = event.endNSDate
        
        ride.eventStartDate = event.startNSDate
        ride.eventEndDate = event.endNSDate
        
        //Combine date and time
        var mergedComponents = DateComponents()
        if let dComps = dateComponents {
            mergedComponents.year = dComps.year
            mergedComponents.month = dComps.month
            mergedComponents.day = dComps.day
        }
        if let tComps = timeComponents {
            mergedComponents.hour = tComps.hour
            mergedComponents.minute = tComps.minute
        }
        let calendar = Calendar.current
        
        let rideDeptDate = calendar.date(from: mergedComponents)!
        
        if ride.direction == RideDirection.fromEvent.rawValue {
            //check if from-event time is before event starts
            if rideDeptDate.isLessThanDate(ride.eventStartDate) {
                addTextFieldError(timeLine!)
                addTextFieldError(dateLine!)
                showValidationError("Please select a time after the event starts.")
                return false
            }
        }
        else {
            if rideDeptDate.isGreaterThanDate(ride.eventEndDate) {
                addTextFieldError(timeLine!)
                addTextFieldError(dateLine!)
                showValidationError("Please select a time before the event ends.")
                return false
            }
        }
        ride.departureDate = rideDeptDate
        ride.date = rideDeptDate
        return true
        
        
        /*if (ride.isValidTime() == ""){
            return true
        }
        else{
            addTextFieldError(timeLine!)
            showValidationError(ride.isValidTime())
            return false
        }*/
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
            if let val = Int((offeredField?.text)!.trimmingCharacters(
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
                addTextFieldError(offeredLine!)
            }
        }
        
        return true
    }
    
    // MARK: - Text Field Delegate Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    func chooseDateHandler(_ date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM d yyyy"
        
        let calendar = Calendar.current
        
        self.dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        ride.monthNum = (dateComponents?.month)!
        ride.day = (dateComponents?.day)!
        ride.year = (dateComponents?.year)!
        self.dateField?.text = dateFormatter.string(from: date)
    }
    
    //called when a time is chosen
    func datePicked(_ obj: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeField!.text = formatter.string(from: obj)
        
        let calendar = Calendar.current
        self.timeComponents = calendar.dateComponents([.hour, .minute], from: obj)
        
        ride.hour = timeComponents!.hour!
        ride.minute = timeComponents!.minute!
        ride.timeStr = (timeField?.text)!
    }
    
    //Called when the pickup location text field becomes active
    func choosePickupLocation(_ sender: AnyObject) {
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            // Do something with the location the user picked.
            //print("\nThis gets executed\n")
            self.loc = pickedLocationItem
            self.CLocation = CLLocation(latitude: pickedLocationItem.coordinate!.latitude, longitude: pickedLocationItem.coordinate!.longitude)
            self.addressLine.backgroundColor = self.inactiveGray
            
        }
        //locationPicker.addBarButtons()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sendLocation(_:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissLocationPicker(_:)))
        
        doneButton.tintColor = CruColors.lightBlue
        cancelButton.tintColor = UIColor.red
        
        locationPicker.setColors(themeColor: CruColors.yellow, primaryTextColor: CruColors.darkBlue, secondaryTextColor: CruColors.lightBlue)
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
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController!.pushViewController(locationPicker, animated: true)
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
        pickupField?.text = ride.getRadius()
        
    }
    
    // MARK: - Validation UI Functions
    
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
    
    // MARK: - Animations
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

    
    // MARK: - Navigation
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //Prepare for passenger segue
        if segue.identifier == "viewPassengers" {
            let popoverVC = segue.destination
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.96, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (addressField?.frame.origin.y)! - 50.0,width: 0,height: 0)
            
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
            let popoverVC = segue.destination
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.97, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (offeredField?.frame.origin.y)! - 50.0,width: 0,height: 0)
            
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
            let vc = segue.destination as! PickRadiusViewController
            vc.ride = self.ride
            vc.setRadius = setRadius
            vc.numMiles = ride.radius
            //vc.pickedLocation = self.pickedLocation
            vc.location = CLocation
        }
    }
    

}
