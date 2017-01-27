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
    let searchController = UISearchController(searchResultsController: nil)
    var filteredEvents = [Event]()
    var hasConnection = true
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)
        
        //Check for connection then load events in the completion function
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)

        //Set the nav title & font
        navigationItem.title = "Events"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //Initialize search stuff
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        
    }
    
    //Empty data set functions
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        if hasConnection == false {
            return UIImage(named: Config.noConnectionImageName)
        }
        else {
            return UIImage(named: Config.noEventsImage)

        }
        
    }

    
    func emptyDataSet(scrollView: UIScrollView!, didTapView view: UIView!) {
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
    }
    
    //Test to make sure there is a connection then load resources
    func finishConnectionCheck(connected: Bool){
        
        if(!connected){
            hasConnection = false
            //Display a message if either of the tables are empty

            self.tableView!.reloadData()
            //MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            //hasConnection = false
        }else{
            hasConnection = true
            
            //MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
            //load upcoming items
            CruClients.getEventUtils().loadEvents(insertEvent, completionHandler: loadEventsWithoutMinistries)
            
        }
        
    }
    
    //Search function
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredEvents = events.filter { event in
            return event.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    private func loadEventsWithoutMinistries(success: Bool) {
        CruClients.getEventUtils().loadEventsWithoutMinistries(insertEvent, completionHandler: finishInserting)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView!.reloadData()
    }
    

    //insert helper function for inserting event data
    private func insertEvent(dict: NSDictionary) {
        let event = Event(dict: dict)!
        if(event.startNSDate.compare(NSDate()) != .OrderedAscending){
            self.events.insert(event, atIndex: 0)
        }
        
    }
    
    private func done(success: Bool) {
        print("Done!")
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
        if searchController.active && searchController.searchBar.text != "" {
            return filteredEvents.count
        }
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var event: Event
        if searchController.active && searchController.searchBar.text != "" {
             event = filteredEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.event = event
        
        cell.card.layer.shadowColor = UIColor.blackColor().CGColor
        cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.card.layer.shadowOpacity = 0.25
        cell.card.layer.shadowRadius = 2
        
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
            
            let selectedEvent: Event
            if searchController.active && searchController.searchBar.text != "" {
                selectedEvent = filteredEvents[indexPath.row]
            } else {
                selectedEvent = events[indexPath.row]
            }
            
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

extension EventsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
