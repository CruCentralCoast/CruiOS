//
//  EventsPopoverViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class EventsPopoverViewController: UITableViewController {
    var events = [Event]()
    var vc: NewOfferRideViewController?
    var fvc: FilterByEventViewController?
    //var offerRide: OfferOrEditRideViewController?
    var offerRide: NewOfferRideViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        events.sortInPlace({$0.name < $1.name})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel!.text = events[indexPath.row].name
        cell.textLabel!.font = UIFont(name: Config.fontName, size: 18.0)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if fvc != nil{
            fvc!.eventNameLabel.text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            fvc!.selectedEvent = events[indexPath.row]
        }
        else if offerRide != nil{
            offerRide!.ride.eventId = events[indexPath.row].id
            offerRide!.ride.eventName = events[indexPath.row].name
            offerRide!.ride.eventStartDate = events[indexPath.row].startNSDate
            offerRide!.ride.eventEndDate = events[indexPath.row].endNSDate
            offerRide!.event = events[indexPath.row]
            offerRide!.eventField!.text = events[indexPath.row].name
            offerRide!.eventLine.backgroundColor = UIColor(red: 149/225, green: 147/225, blue: 145/225, alpha: 1.0)
            offerRide!.syncRideToEvent()
        }
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
