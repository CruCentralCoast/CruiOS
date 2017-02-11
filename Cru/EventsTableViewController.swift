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
    let curDate = Date()
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
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        //Initialize search stuff
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        
    }
    
    //Empty data set functions
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if hasConnection == false {
            return UIImage(named: Config.noConnectionImageName)
        }
        else {
            return UIImage(named: Config.noEventsImage)

        }
        
    }

    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
    }
    
    //Test to make sure there is a connection then load resources
    func finishConnectionCheck(_ connected: Bool){
        
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
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEvents = events.filter { event in
            return event.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    fileprivate func loadEventsWithoutMinistries(_ success: Bool) {
        CruClients.getEventUtils().loadEventsWithoutMinistries(insertEvent, completionHandler: finishInserting)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView!.reloadData()
    }
    

    //insert helper function for inserting event data
    fileprivate func insertEvent(_ dict: NSDictionary) {
        let event = Event(dict: dict)!
        if(event.startNSDate.compare(Date()) != .orderedAscending){
            self.events.insert(event, at: 0)
        }
        
    }
    
    fileprivate func done(_ success: Bool) {
        print("Done!")
    }
    
    //helper function for finishing off inserting event data
    fileprivate func finishInserting(_ success: Bool) {
        self.events.sort(by: {$0.startNSDate.compare($1.startNSDate as Date) == .orderedAscending})
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView!.reloadData()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredEvents.count
        }
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var event: Event
        if searchController.isActive && searchController.searchBar.text != "" {
             event = filteredEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.event = event
        
        cell.card.layer.shadowColor = UIColor.black.cgColor
        cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.card.layer.shadowOpacity = 0.25
        cell.card.layer.shadowRadius = 2
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let event = events[indexPath.row]
        
        if event.imageUrl == "" {
            return 150.0
        }
        else {
            return 305.0       
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetails" {
            let eventDetailViewController = segue.destination as! EventDetailsViewController
            let selectedEventCell = sender as! EventTableViewCell
            let indexPath = self.tableView!.indexPath(for: selectedEventCell)!
            
            let selectedEvent: Event
            if searchController.isActive && searchController.searchBar.text != "" {
                selectedEvent = filteredEvents[indexPath.row]
            } else {
                selectedEvent = events[indexPath.row]
            }
            
            eventDetailViewController.event = selectedEvent
        }
    }
    
    //reveal controller function for disabling the current view
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
        if position == FrontViewPosition.left {
            self.tableView.isScrollEnabled = true
            
            for view in self.tableView.subviews {
                view.isUserInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.right {
            self.tableView.isScrollEnabled = false
            
            for view in self.tableView.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
}

extension EventsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
