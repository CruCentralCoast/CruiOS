//
//  EventDetailsViewController.swift
//  
//  This class customizes the view that is shown when an event is inspected in detail. The app switches to 
//  this view when a cell in its parent view EventCollectionViewController.swift is selected.
//
//  Created by Erica Solum on 11/25/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import EventKit

class EventDetailsViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var detailsScroller: UIScrollView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var findRideButton: UIButton!
    @IBOutlet weak var offerRideButton: UIButton!
    @IBOutlet weak var offerLeading: NSLayoutConstraint!
    @IBOutlet weak var findRideLeading: NSLayoutConstraint!
    //passed in prepareForSegue
    var event: Event!
    var eventLocalStorageManager: MapLocalStorageManager!
    var calendarManager: CalendarManager!
    var rides = [Ride]()
    
    //function called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup local storage manager for events
        eventLocalStorageManager = MapLocalStorageManager(key: Config.eventStorageKey)
        
        //setup calendar maanger
        calendarManager = CalendarManager()
        
        //Set nav title & font
        navigationItem.title = "Event Details"
        
        if self.navigationController != nil {
            self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
        
        
        
        //initialize the view
        initializeView()
        setButtonConstraints(UIScreen.mainScreen().bounds.width)
        
        //Disable the ride sharing buttons if user is already driving/is passenger
        CruClients.getRideUtils().getMyRides(insertRide, afterFunc: finishRideInsert)
    }
    
    func insertRide(dict : NSDictionary) {
        //create ride
        let newRide = Ride(dict: dict)
        
        //insert into ride array
        rides.insert(newRide!, atIndex: 0)
    }
    
    func finishRideInsert(type: ResponseType){
        
        switch type{
            
            
        case .NoConnection:
            print("No Connection")
            //self.ridesTableView.emptyDataSetSource = self
            //self.ridesTableView.emptyDataSetDelegate = self
            //noRideImage = UIImage(named: Config.noConnectionImageName)!
            //MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            
        default:
            //Look through rides for this event
            for ride in rides {
                if ride.eventId == event.id {
                    disableRideSharing()
                }
            }
        }
        
        rides.sortInPlace()
    }
    
    //UI view initializer
    private func initializeView() {
        let dateFormat = "h:mma MMMM d, yyyy"
        
        navigationItem.title = "Event Details"
        
        //Set the UI elements to the event’s corresponding value
        image.load(event.imageUrl)
        titleLabel.text = event.name
        startTimeLabel.text = GlobalUtils.stringFromDate(event.startNSDate, format: dateFormat)
        endTimeLabel.text = GlobalUtils.stringFromDate(event.endNSDate, format: dateFormat)
        descriptionView.text = event.description
        
        //insert location if there is one defined
        var locationText = "No Location Available"
        if let _ = event.location {
            locationText = event.getLocationString()
        }
        locationLabel.text = locationText
        
        //If there's no Facebook event, disable the button
        if event.url == "" {
            fbButton.enabled = false
        }
        
        //If ridesharing is not enabled, disable the buttons
        if !event.rideSharingEnabled {
            disableRideSharing()
        }
        
        //check if event is in calendar
        if let eventId = eventLocalStorageManager.getElement(event.id) {
            checkForChanges(eventId as! String)  
        }
    }
    
    private func disableRideSharing() {
        findRideButton.enabled = false
        offerRideButton.enabled = false
    }
    
    //Checks for differences between the native event and the one being displayed
    func checkForChanges(eventID: String) {
        var changed = false
        
        if let nativeEvent = calendarManager.getEvent(eventID) {
            
            if nativeEvent.location != self.event.getLocationString(){
                changed = true
            }
        
            if nativeEvent.startDate != self.event.startNSDate {
                changed = true
            }
            
            if nativeEvent.endDate != self.event.endNSDate {
                changed = true
            }
            
            if changed {
                self.reconfigureCalendarButton(EventStatus.Sync)
            }
            else {
                self.reconfigureCalendarButton(EventStatus.Added)
                print("Event exists")
            }
        }
        
        
        
    }
    
    //Sets the spacing of the buttons according to the screen size
    func setButtonConstraints(screenWidth: CGFloat) {
        let totalSpacing = screenWidth - (calendarButton.bounds.width*4) - 40
        let interval = totalSpacing/3
        
        offerLeading.constant = interval
        findRideLeading.constant = interval
    }

    
    //MARK: Actions
    
    //This action allows the user to access the event on facebook
    @IBAction func facebookLinkButton(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: (event.url))!)
    }
    
    //This action is for saving an event to the native calendar
    @IBAction func saveToCalendar(sender: UIButton) {
        calendarManager.addEventToCalendar(event, completionHandler: {
            errors, id in
            
            //if theres an error print it
            if let error = errors {
                if (error.domain == "calendar") {
                    //error code 9 means that the event you tried to add was not successful
                    if (error.code == 9) {
                        self.displayError("I'm sorry. There was an error adding that event to your calendar")
                        self.reconfigureCalendarButton(EventStatus.NotAdded)
                    }
                }
            }
            else {
                if let _ = id {
                    self.eventLocalStorageManager.addElement(self.event.id, elem: id!)
                    self.reconfigureCalendarButton(EventStatus.Added)
                }
            }
        })
    }
    
    //This function syncs the event in the database to the event that
    //already exists in the user's native calendar
    func syncToCalendar(sender: UIButton) {
        let eventIdentifier = eventLocalStorageManager.getElement(event.id)
        
        calendarManager.syncEventToCalendar(event, eventIdentifier: eventIdentifier as! String, completionHandler: {
            errors in
            
            if let error = errors {
                if (error.domain == "calendar") {
                    //error code 10 says that theres no calendar event in the calendar
                    //to remove
                    if (error.code == 10) {
                        self.displayError("That event was already synced!")
                        self.reconfigureCalendarButton(EventStatus.Added)
                    }
                }
            }
            else {
                //self.eventLocalStorageManager.removeElement(self.event.id)
                self.reconfigureCalendarButton(EventStatus.Added)
                //print("ERRORS")
            }
        })
    }
    
    //this action removes events from the calendar
    func removeFromCalendar(sender: UIButton) {
        let eventIdentifier = eventLocalStorageManager.getElement(event.id)
        
        calendarManager.removeEventFromCalendar(eventIdentifier as! String, completionHandler: {
            errors in
            
            if let error = errors {
                if (error.domain == "calendar") {
                    //error code 10 says that theres no calendar event in the calendar
                    //to remove
                    if (error.code == 10) {
                        self.displayError("That event was already removed from your calendar!")
                        self.reconfigureCalendarButton(EventStatus.NotAdded)
                    }
                }
            }
            else {
                self.eventLocalStorageManager.removeElement(self.event.id)
                self.reconfigureCalendarButton(EventStatus.NotAdded)
            }
        })
    }
    
    //reconfigures the calendar button
    private func reconfigureCalendarButton(status: EventStatus) {
        var action = "saveToCalendar:"
        var buttonImage = UIImage(named: "add-to-calendar")
        
        switch status {
        case .Added:
            action = "removeFromCalendar:"
            buttonImage = UIImage(named: "remove-from-calendar")
        case .Sync:
            action = "syncToCalendar:"
            buttonImage = UIImage(named: "sync-to-calendar")
        default: ()
        }
        
        calendarButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
        calendarButton.addTarget(self, action: Selector(action), forControlEvents: .TouchUpInside)
        calendarButton.setBackgroundImage(buttonImage, forState: .Normal)
    }

    //This function opens the ridesharing section of the application
    //from the events page
    @IBAction func linkToRideShare(sender: AnyObject) {
        
        if let button = sender as? UIButton{
            if(button.currentTitle == "offer ride"){
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("createARide") as! OfferOrEditRideViewController
                self.navigationController?.pushViewController(vc, animated: true)
                vc.event = event
                vc.isOfferingRide = true
            }
            else{
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ridesByEvent") as! FilterByEventViewController
                self.navigationController?.pushViewController(vc, animated: true)
                vc.loadRides(event)
                vc.eventVC = self
                vc.wasLinkedFromEvents = true
            }
        }
    }
    
    //displays any errors on the page as necessary
    func displayError(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
