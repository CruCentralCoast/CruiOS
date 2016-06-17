//
//  EventsTableViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 4/28/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet



class EventsTableViewController: UITableViewController, SWRevealViewControllerDelegate, DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    var events = [Event]()
    let curDate = NSDate()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: Config.noConnectionImageName)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)

        CruClients.getEventUtils().loadEvents(insertEvent, completionHandler: finishInserting)
        
        //Set the nav title & font
        navigationItem.title = "Events"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapView view: UIView!) {
        CruClients.getEventUtils().loadEvents(insertEvent, completionHandler: finishInserting)
    }

    //insert helper function for inserting event data
    private func insertEvent(dict: NSDictionary) {
        let event = Event(dict: dict)!
        
        if(event.startNSDate.compare(NSDate()) != .OrderedAscending){
            self.events.insert(event, atIndex: 0)
        }
        
    }
    
    //helper function for finishing off inserting event data
    private func finishInserting(success: Bool) {
        self.events.sortInPlace({$0.startNSDate.compare($1.startNSDate) == .OrderedAscending})
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView!.reloadData()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.event = event
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let event = events[indexPath.row]
        
        if event.imageUrl == "" {
            return 150.0
        }
        else {
            return 305.0       
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventDetails" {
            let eventDetailViewController = segue.destinationViewController as! EventDetailsViewController
            let selectedEventCell = sender as! EventTableViewCell
            let indexPath = self.tableView!.indexPathForCell(selectedEventCell)!
            let selectedEvent = events[indexPath.row]
            
            eventDetailViewController.event = selectedEvent
        }
    }
    
    //reveal controller function for disabling the current view
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if position == FrontViewPosition.Left {
            self.tableView.scrollEnabled = true
            
            for view in self.tableView.subviews {
                view.userInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.Right {
            self.tableView.scrollEnabled = false
            
            for view in self.tableView.subviews {
                view.userInteractionEnabled = false
            }
        }
    }
}
