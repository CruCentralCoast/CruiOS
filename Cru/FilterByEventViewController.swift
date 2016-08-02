//
//  FilterByEventViewController.swift
//  Cru
//
//  Created by Max Crane on 2/17/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress
import DZNEmptyDataSet

class FilterByEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    
    @IBOutlet weak var rideTable: UITableView!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    var rideVC:RidesViewController?
    var eventVC: EventDetailsViewController?
    
    var events = [Event]()
    var filteredRides = [Ride]()
    var allRides = [Ride]()
    var curRides = [Ride]()
    var wasLinkedFromEvents = false
    
    //Filtering on the app side for now
    //For future: filter server side
    var tempEvent: Event?
    var selectedEvent: Event? {
        didSet {
            if let selectedEvent = selectedEvent {
                eventNameLabel.text = selectedEvent.name
                filterRidesByEventId(selectedEvent.id)
            }
        }
    }
    var selectedRide: Ride?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make pickerview and tableview recognize this class
        //as their delegate and data source
        rideTable.delegate = self
        rideTable.dataSource = self
        
        navigationItem.title = "Find Ride"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map View", style: .Plain, target: self, action: #selector(FilterByEventViewController.mapView))
        
        //Load current user's rides
        loadCurRides()
        
        loadEvents()
        if tempEvent == nil {
            loadRides(nil)
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let img =  UIImage(named: Config.noRidesForEvent)
        
        return img
    }
    
    func mapView(){
        if(selectedEvent != nil){
            self.performSegueWithIdentifier("mapView", sender: self)
        }
        else{
            let noEventAlert = UIAlertController(title: "Please select an event first", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            noEventAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(noEventAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    //Load the user's current rides
    func loadCurRides() {
        CruClients.getRideUtils().getMyRides(fillRides, afterFunc: { sucess in
            //Don't need to do anything
        })
    }
    
    //Load the available events list
    func loadEvents(){
        CruClients.getServerClient().getData(.Event, insert: insertEvent, completionHandler:
            { sucess in
                //we should be handling failure here
        })
    }
    
    //If user isn't driving/getting ride to event, insert it into the
    //available events list
    func insertEvent(dict : NSDictionary) {
        //For now, filter out events we already have rides to on the app side
        //For future, filter events on the server side
        let curEvent = Event(dict: dict)!
        var matchFound = false
        
        for ride in curRides {
            if ride.eventId == curEvent.id {
                matchFound = true
            }
        }
        
        if !matchFound {
            events.insert(Event(dict: dict)!, atIndex: 0)
        }
    }
    
    //Insert user's current rides into rides array
    func fillRides(dict : NSDictionary) {
        //create ride
        let newRide = Ride(dict: dict)
        
        //insert into ride array
        curRides.insert(newRide!, atIndex: 0)
    }
    
    
    func loadRides(event: Event?) {
        tempEvent = event
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        CruClients.getRideUtils().getRidesNotDriving(Config.gcmId(), insert: insertRide, afterFunc: loadRidesCompletionHandler)
    }
    
    private func insertRide(dict: NSDictionary) {
        let newRide = Ride(dict: dict)!
        if(newRide.seats > 0 && newRide.seatsLeft() > 0){
            allRides.append(newRide)
        }
    }
    
    private func loadRidesCompletionHandler(success: Bool) {
        if tempEvent != nil {
            selectedEvent = tempEvent
        }
        
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }
    
    private func filterRidesByEventId(eventId: String){
        rideTable.emptyDataSetDelegate = nil
        rideTable.emptyDataSetSource = nil
        filteredRides.removeAll()
        
        for ride in allRides {
            if(ride.eventId == eventId && ride.hasSeats()){
                filteredRides.append(ride)
            }
        }
        
        rideTable.emptyDataSetDelegate = self
        rideTable.emptyDataSetSource = self
        
        self.rideTable.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRides.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rideCell") as! OfferedRideTableViewCell
        
        let thisRide = filteredRides[indexPath.row]
        cell.month.text = thisRide.month
        cell.day.text = String(thisRide.day)
        cell.time.text = GlobalUtils.stringFromDate(thisRide.date, format: "h:mma")
        
        cell.seatsLeft.text = thisRide.seatsLeft() + " seats left"
        
        if(thisRide.seatsLeft() == 1){
            cell.seatsLeft.textColor = UIColor(red: 0.729, green: 0, blue: 0.008, alpha: 1.0)
 
        }
        else if(thisRide.seatsLeft() == 2){
            cell.seatsLeft.textColor = UIColor(red: 0.976, green: 0.714, blue: 0.145, alpha: 1.0)
        }
        else{
            cell.seatsLeft.textColor = UIColor(red: 0, green:  0.427, blue: 0.118, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedRide = filteredRides[indexPath.row]
            
        performSegueWithIdentifier("joinSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Function for sending the selected event to this view controller.
    // sets the selected event to the event that was selected in the event table view controller.
//    func selectVal(event: Event){
//        self.selectedEvent = event
//    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? RideJoinViewController where segue.identifier == "joinSegue" {
                    vc.ride = self.selectedRide
                    vc.event = self.selectedEvent
                    vc.rideVC = self.rideVC
                    vc.wasLinkedFromEvents = self.wasLinkedFromEvents
                    vc.eventVC = self.eventVC
        }
        
        //check if we're going to event modal
        if segue.identifier == "pickEvent" {
            if let destinationVC = segue.destinationViewController as? EventsModalTableViewController {
                destinationVC.events = Event.eventsWithRideShare(events)
                destinationVC.fvc = self
            
                let controller = destinationVC.popoverPresentationController
                if(controller != nil){
                    controller?.delegate = self
                }
            }
        }
        else if segue.identifier == "mapView"{
            if let vc = segue.destinationViewController as? MapOfRidesViewController{
                vc.rides = filteredRides
                vc.event = selectedEvent
                vc.rideTVC = self.rideVC
                vc.eventVC = self.eventVC
                vc.wasLinkedFromEvents = self.wasLinkedFromEvents
            }
        }
    }
}
