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
    
    weak var rideVC:RidesViewController?
    weak var eventVC: EventDetailsViewController?
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map View", style: .plain, target: self, action: #selector(FilterByEventViewController.mapView))
        
        //Load current user's rides
        loadCurRides()
        
        loadEvents()
        if tempEvent == nil {
            loadRides(nil)
        }
    }
    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: Config.noRidesForEvent)
//    }
    
    func mapView(){
        if(selectedEvent != nil){
            self.performSegue(withIdentifier: "mapView", sender: self)
        }
        else{
            let noEventAlert = UIAlertController(title: "Please select an event first", message: "", preferredStyle: UIAlertControllerStyle.alert)
            noEventAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(noEventAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    //Load the user's current rides
    func loadCurRides() {
        CruClients.getRideUtils().getMyRides(fillRides, afterFunc: { success in
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
    func insertEvent(_ dict : NSDictionary) {
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
            events.insert(Event(dict: dict)!, at: 0)
        }
    }
    
    //Insert user's current rides into rides array
    func fillRides(_ dict : NSDictionary) {
        //create ride
        let newRide = Ride(dict: dict)
        
        //insert into ride array
        curRides.insert(newRide!, at: 0)
    }
    
    
    func loadRides(_ event: Event?) {
        tempEvent = event
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        CruClients.getRideUtils().getRidesNotDriving(Config.fcmId(), insert: insertRide, afterFunc: loadRidesCompletionHandler)
    }
    
    fileprivate func insertRide(_ dict: NSDictionary) {
        let newRide = Ride(dict: dict)!
        if(newRide.seats > 0 && newRide.seatsLeft() > 0){
            allRides.append(newRide)
        }
    }
    
    fileprivate func loadRidesCompletionHandler(_ success: Bool) {
        if tempEvent != nil {
            selectedEvent = tempEvent
        }
        
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    fileprivate func filterRidesByEventId(_ eventId: String){
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideCell") as! OfferedRideTableViewCell
        
        let thisRide = filteredRides[indexPath.row]
        cell.month.text = thisRide.month
        cell.day.text = String(thisRide.day)
        cell.time.text = GlobalUtils.stringFromDate(thisRide.date, format: "h:mma")
        
        cell.seatsLeft.text = thisRide.seatsLeftAsString() + " seats left"
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedRide = filteredRides[indexPath.row]
            
        performSegue(withIdentifier: "joinSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Function for sending the selected event to this view controller.
    // sets the selected event to the event that was selected in the event table view controller.
//    func selectVal(event: Event){
//        self.selectedEvent = event
//    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? JoinRideViewController, segue.identifier == "joinSegue" {
            vc.ride = self.selectedRide
            vc.event = self.selectedEvent
            if let eVC = self.eventVC {
                vc.popVC = eVC
            }
            if let rVC = self.rideVC {
                vc.popVC = rVC
            }
            vc.wasLinkedFromEvents = self.wasLinkedFromEvents
        }
        
        //check if we're going to event modal
        if segue.identifier == "pickEvent" {
            if let destinationVC = segue.destination as? EventsModalTableViewController {
                destinationVC.events = Event.eventsWithRideShare(events)
                destinationVC.fvc = self
            
                let controller = destinationVC.popoverPresentationController
                if(controller != nil){
                    controller?.delegate = self
                }
            }
        }
        else if segue.identifier == "mapView"{
            if let vc = segue.destination as? MapOfRidesViewController{
                vc.rides = filteredRides
                vc.event = selectedEvent
                vc.rideTVC = self.rideVC
                vc.eventVC = self.eventVC
                vc.wasLinkedFromEvents = self.wasLinkedFromEvents
            }
        }
    }
}
