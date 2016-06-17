//
//  EventsModalTableViewController.swift
//  Cru
//
//  Created by Max Crane on 4/14/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class EventsModalTableViewController: UITableViewController {
    var events = [Event]()
    var vc: OfferRideViewController?
    var fvc: FilterByEventViewController?
    var offerRide: OfferOrEditRideViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        events.sortInPlace({$0.name < $1.name})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

         cell.textLabel!.text = events[indexPath.row].name
         cell.textLabel!.font = UIFont(name: Config.fontName, size: 18.0)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if vc != nil{
            vc!.eventName.text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            vc!.chosenEvent = events[indexPath.row]
            vc!.formHasBeenEdited = true
            
        }
        else if fvc != nil{
            fvc!.eventNameLabel.text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            fvc!.selectedEvent = events[indexPath.row]
        }
        else if offerRide != nil{
            offerRide!.ride.eventId = events[indexPath.row].id
            offerRide!.ride.eventName = events[indexPath.row].name
            offerRide!.ride.eventStartDate = events[indexPath.row].startNSDate
            offerRide!.ride.eventEndDate = events[indexPath.row].endNSDate
            offerRide!.event = events[indexPath.row]
            offerRide!.updateOptions()
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
}
