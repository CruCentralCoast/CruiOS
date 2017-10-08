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
    @IBOutlet weak var location2: UITextView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var detailsScroller: UIScrollView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var findRideButton: UIButton!
    @IBOutlet weak var offerRideButton: UIButton!
    @IBOutlet weak var offerLeading: NSLayoutConstraint!
    @IBOutlet weak var findRideLeading: NSLayoutConstraint!
    //passed in prepareForSegue
    var event: Event!
    var eventLocalStorageManager: MapLocalStorageManager<String>!
    var calendarManager: CalendarManager!
    var rides = [Ride]()
    
    //function called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable ride sharing for release 1.4
        // Issue #135 - Enable Ridesharing
        #if RELEASE
        self.disableRideSharing()
        #endif
        
        //setup local storage manager for events
        eventLocalStorageManager = MapLocalStorageManager(key: Config.eventStorageKey)
        
        //setup calendar maanger
        calendarManager = CalendarManager()
        
        //initialize the view
        initializeView()
        setButtonConstraints(UIScreen.main.bounds.width)
        calendarButton.imageView?.contentMode = .scaleAspectFit
        findRideButton.imageView?.contentMode = .scaleAspectFit
        offerRideButton.imageView?.contentMode = .scaleAspectFit
        fbButton.imageView?.contentMode = .scaleAspectFit
        
        //Disable the ride sharing buttons if user is already driving/is passenger
        CruClients.getRideUtils().getMyRides(insertRide, afterFunc: finishRideInsert)
    }
    
    func insertRide(_ dict : NSDictionary) {
        //create ride
        let newRide = Ride(dict: dict)
        
        //insert into ride array
        rides.insert(newRide!, at: 0)
    }
    
    func finishRideInsert(_ type: ResponseType){
        
        switch type{
            
            
        case .noConnection:
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
        
        rides.sort()
    }
    
    //UI view initializer
    fileprivate func initializeView() {
        let dateFormat = "h:mma MMMM d, yyyy"
        let dateFormatter = "MMM d, yyyy"
        let timeFormatter = "h:mma"
        
        //Set nav title & font
        navigationItem.title = "Event Details"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        //Set the UI elements to the event’s corresponding value
        if event.imageUrl != "" {
            image.load.request(with: event.imageUrl)
        }
        
        titleLabel.text = event.name
        startTimeLabel.text = GlobalUtils.stringFromDate(event.startNSDate, format: dateFormat)
        endTimeLabel.text = GlobalUtils.stringFromDate(event.endNSDate, format: dateFormat)
        
        let startDate = GlobalUtils.stringFromDate(event.startNSDate, format: dateFormatter)
        let startTime = GlobalUtils.stringFromDate(event.startNSDate, format: timeFormatter)
        let endDate = GlobalUtils.stringFromDate(event.endNSDate, format: dateFormatter)
        let endTime = GlobalUtils.stringFromDate(event.endNSDate, format: timeFormatter)
        
        if startDate != endDate {
            startTimeLabel.text = startDate + " - " + endDate
        }
        else {
            startTimeLabel.text = startDate
        }
        
        endTimeLabel.text = startTime + " - " + endTime
        
        
        
        descriptionView.text = event.description
        
        //insert location if there is one defined
        var locationText = "No Location Available"
        if let _ = event.location {
            locationText = event.getLocationString()
        }
        location2.text = locationText
        location2.textContainerInset = UIEdgeInsets.zero
        location2.textContainer.lineFragmentPadding = 0
        
        //If there's no Facebook event, disable the button
        if event.url == "" {
            fbButton.isEnabled = false
        }
        
        //If ridesharing is not enabled, disable the buttons
        if !event.rideSharingEnabled {
            disableRideSharing()
        }
        
        //check if event is in calendar
        if let eventId = eventLocalStorageManager.object(forKey: event.id) {
            checkForChanges(eventId as! String)  
        }
    }
    
    fileprivate func disableRideSharing() {
        findRideButton.isEnabled = false
        offerRideButton.isEnabled = false
    }
    
    //Checks for differences between the native event and the one being displayed
    func checkForChanges(_ eventID: String) {
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
                self.reconfigureCalendarButton(EventStatus.sync)
            }
            else {
                self.reconfigureCalendarButton(EventStatus.added)
                print("Event exists")
            }
        }
        
        
        
    }
    
    //Sets the spacing of the buttons according to the screen size
    func setButtonConstraints(_ screenWidth: CGFloat) {
        let totalSpacing = screenWidth - (calendarButton.bounds.width*4) - 40
        let interval = totalSpacing/3
        
        offerLeading.constant = interval
        findRideLeading.constant = interval
    }

    
    //MARK: Actions
    
    //This action allows the user to access the event on facebook
    @IBAction func facebookLinkButton(_ sender: UIButton){
        var urlString = event.url
        if !(urlString.hasPrefix("https://www.") || urlString.hasPrefix("http://www.")){
            urlString = "http://www." + urlString
        }
        
        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.openURL(url)
    }
    
    //This action is for saving an event to the native calendar
    @IBAction func saveToCalendar(_ sender: UIButton) {
        calendarManager.addEventToCalendar(event, completionHandler: {
            errors, id in
            
            //if theres an error print it
            if let error = errors {
                if (error.domain == "calendar") {
                    //error code 9 means that the event you tried to add was not successful
                    if (error.code == 9) {
                        self.displayError("I'm sorry. There was an error adding that event to your calendar")
                        self.reconfigureCalendarButton(EventStatus.notAdded)
                    }
                }
            }
            else {
                if let _ = id {
                    self.eventLocalStorageManager.save(id!, forKey: self.event.id)
                    self.reconfigureCalendarButton(EventStatus.added)
                }
            }
        })
    }
    
    //This function syncs the event in the database to the event that
    //already exists in the user's native calendar
    func syncToCalendar(_ sender: UIButton) {
        let eventIdentifier = eventLocalStorageManager.object(forKey: event.id)
        
        calendarManager.syncEventToCalendar(event, eventIdentifier: eventIdentifier as! String, completionHandler: {
            errors in
            
            if let error = errors {
                if (error.domain == "calendar") {
                    //error code 10 says that theres no calendar event in the calendar
                    //to remove
                    if (error.code == 10) {
                        self.displayError("That event was already synced!")
                        self.reconfigureCalendarButton(EventStatus.added)
                    }
                }
            }
            else {
                //self.eventLocalStorageManager.removeElement(self.event.id)
                self.reconfigureCalendarButton(EventStatus.added)
                //print("ERRORS")
            }
        })
    }
    
    //this action removes events from the calendar
    func removeFromCalendar(_ sender: UIButton) {
        let eventIdentifier = eventLocalStorageManager.object(forKey: event.id)
        
        calendarManager.removeEventFromCalendar(eventIdentifier as! String, completionHandler: {
            errors in
            
            if let error = errors {
                if (error.domain == "calendar") {
                    //error code 10 says that theres no calendar event in the calendar
                    //to remove
                    if (error.code == 10) {
                        self.displayError("That event was already removed from your calendar!")
                        self.reconfigureCalendarButton(EventStatus.notAdded)
                    }
                }
            }
            else {
                self.eventLocalStorageManager.removeElement(self.event.id)
                self.reconfigureCalendarButton(EventStatus.notAdded)
            }
        })
    }
    
    //reconfigures the calendar button
    fileprivate func reconfigureCalendarButton(_ status: EventStatus) {
        var action = "saveToCalendar:"
        var buttonImage = UIImage(named: "add-to-calendar")
        
        switch status {
        case .added:
            action = "removeFromCalendar:"
            buttonImage = UIImage(named: "remove-from-calendar")
        case .sync:
            action = "syncToCalendar:"
            buttonImage = UIImage(named: "sync-to-calendar")
        default: ()
        }
        
        calendarButton.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        calendarButton.addTarget(self, action: Selector(action), for: .touchUpInside)
        calendarButton.setImage(buttonImage, for: UIControlState())
    }

    //This function opens the ridesharing section of the application
    //from the events page
    @IBAction func linkToRideShare(_ sender: AnyObject) {
        if let button = sender as? UIButton{
            if button.currentTitle == "offer ride" {
                let vc = UIStoryboard(name: "newofferride", bundle: nil).instantiateViewController(withIdentifier: "newOfferRide") as! NewOfferRideViewController
                self.navigationController?.pushViewController(vc, animated: true)
                vc.event = event
                //vc.isOfferingRide = true
                vc.fromEventDetails = true
            } else{
                let vc = UIStoryboard(name: "findride", bundle: nil).instantiateViewController(withIdentifier: "ridesByEvent") as! FilterByEventViewController
                self.navigationController?.pushViewController(vc, animated: true)
                vc.loadRides(event)
                vc.eventVC = self
                vc.wasLinkedFromEvents = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offerRide"{
            //let destVC = segue.destinationViewController as! OfferOrEditRideViewController
            let vc = segue.destination as! NewOfferRideViewController
            vc.event = event
            vc.fromEventDetails = true
            
        }
    }
    
    //displays any errors on the page as necessary
    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
