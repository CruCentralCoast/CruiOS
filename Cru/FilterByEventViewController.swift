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

class FilterByEventViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectEventButton: UIButton!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventNameStackView: UIStackView!
    @IBOutlet weak var requestRideStackView: UIStackView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
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
                self.eventNameLabel.text = selectedEvent.name
                self.selectEventButton.isHidden = true
                self.eventNameStackView.isHidden = false
                self.mapButton.isEnabled = true
                self.tableView.isHidden = false
//                loadRides(selectedEvent)
                filterRidesByEventId(selectedEvent.id)
            }
        }
    }
    var selectedRide: Ride?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        loadCurRides()
        loadEvents()
        if self.tempEvent == nil {
            loadRides(nil)
        }
    }
    
    @IBAction func chooseEvent(_ sender: UIButton) {
        let eventsVC = UIStoryboard(name: "findride", bundle: nil).instantiateViewController(withIdentifier: "EventsModalTableViewController") as! EventsModalTableViewController
        
        eventsVC.events = Event.eventsWithRideShare(events).filter { event -> Bool in
            return event.startNSDate.isGreaterThanDate(Date())
        }
        eventsVC.fvc = self
        
        // Set the presentation style
        eventsVC.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // Set up the popover presentation controller
        eventsVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        eventsVC.popoverPresentationController?.delegate = self
        eventsVC.popoverPresentationController?.sourceView = sender
        eventsVC.popoverPresentationController?.sourceRect = sender.bounds
        
        self.present(eventsVC, animated: true)
    }
    
    @IBAction func showMap() {
        let mapVC = UIStoryboard(name: "findride", bundle: nil).instantiateViewController(withIdentifier: "MapOfRidesViewController") as! MapOfRidesViewController
        
        mapVC.rides = self.filteredRides
        mapVC.event = self.selectedEvent
        mapVC.rideTVC = self.rideVC
        mapVC.eventVC = self.eventVC
        mapVC.wasLinkedFromEvents = self.wasLinkedFromEvents
        
        self.show(mapVC, sender: self)
    }
    
    func showRideInfo() {
        let rideVC = UIStoryboard(name: "findride", bundle: nil).instantiateViewController(withIdentifier: "joinRideVC") as! JoinRideViewController
        
        rideVC.ride = self.selectedRide
        rideVC.event = self.selectedEvent
        if let eVC = self.eventVC {
            rideVC.popVC = eVC
        }
        if let rVC = self.rideVC {
            rideVC.popVC = rVC
        }
        rideVC.wasLinkedFromEvents = self.wasLinkedFromEvents
        
        self.show(rideVC, sender: self)
    }
    
    // MARK: - Table view data source
    //Load the user's current rides
    func loadCurRides() {
        CruClients.getRideUtils().getMyRides(processCurRide, afterFunc: { success in
            //Don't need to do anything
        })
    }
    
    //Insert user's current rides into rides array
    func processCurRide(_ dict : NSDictionary) {
        //create ride
        let newRide = Ride(dict: dict)
        
        //insert into ride array
        curRides.insert(newRide!, at: 0)
    }
    
    //Load the available events list
    func loadEvents(){
        CruClients.getServerClient().getData(.Event, insert: insertEvent, completionHandler: { success in
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
    
    func loadRides(_ event: Event?) {
        self.tempEvent = event
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
        if self.tempEvent != nil {
            self.selectedEvent = self.tempEvent
        }
        
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    fileprivate func filterRidesByEventId(_ eventId: String){
        self.filteredRides.removeAll()
        
        for ride in self.allRides {
            if(ride.eventId == eventId && ride.hasSeats()){
                self.filteredRides.append(ride)
            }
        }
        
        self.tableView.reloadData()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - TableView Methods
extension FilterByEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Rides"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideCell") as! OfferedRideTableViewCell
        
        cell.ride = filteredRides[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRide = filteredRides[indexPath.row]
        showRideInfo()
    }
}

// MARK: - Empty DataSet Methods
extension FilterByEventViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: Config.noRidesForEvent)
    }
}
