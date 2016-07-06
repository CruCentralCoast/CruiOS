//
//  MainViewController.swift
//  Cru
//
//  This view controller represents the main controller for the home view and the launch screen of the Cru Central Coast Application
//
//  Created by Deniz Tumer on 11/5/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import SideMenu

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate {
    var items = [String]()//["Church on Sunday!", "Fall Retreat", "Bowling lessons with Pete, or was it Peter? Find out at the Event", "Idk was it peter", "Futbol"]
    var months = [String]()
    var days = [String]()
    var rides = [Ride]()
    var events = [Event]()
    var ridesRowHeight = 100
    @IBOutlet weak var table: UITableView?
    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var upcomingEventsSpacer: NSLayoutConstraint!
    @IBOutlet weak var upcomingRidesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontName, size: 20)!], forState: .Normal)
        
        if self.revealViewController() != nil{
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().delegate = self
        }
        
        //Change nav title font
        navigationItem.title = "Home"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        //load upcoming items
        CruClients.getRideUtils().getMyRides(insertRide, afterFunc: finishRideInsert)
        
    }
    
    /* This function acts after the view is loaded and appears on the phone. */
    override func viewDidAppear(animated: Bool) {
        if !hasAppLaunchedBefore() {
            self.performSegueWithIdentifier("introSegue", sender: self)
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    }
    
    func insertRide(dict : NSDictionary) {
        //create ride
        print("\nInsertRide gets called!!\n")
        let newRide = Ride(dict: dict)
        
        //insert into ride array
        rides.insert(newRide!, atIndex: 0)
        
        rides.sortInPlace()
        
    }
    
    
    func insertEvent(dict : NSDictionary) {
        //Create event
        let event = Event(dict: dict)!
        
        //Insert event into the array
        if(event.startNSDate.compare(NSDate()) != .OrderedAscending){
            self.events.insert(event, atIndex: 0)
        }
    }
    
    func finishRideInsert(type: ResponseType){
        
        switch type{

            
        case .NoConnection:
            print("\nCould not finish inserting rides. No connection found.\n")
            //self.ridesTableView.emptyDataSetSource = self
            //self.ridesTableView.emptyDataSetDelegate = self
            //noRideImage = UIImage(named: Config.noConnectionImageName)!
            //MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            
        default:
            CruClients.getServerClient().getData(DBCollection.Event, insert: insertEvent, completionHandler: finishInserting)
        }
        
        rides.sortInPlace()
    }
    
    //Function that inserts the rides and events only if we get all the rides first
    func finishInserting(success: Bool){
        
        //MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        for ride in rides{
            
            months.append(ride.month)
            days.append(String(ride.day))
            items.append(ride.getDescription(getEventNameForEventId(ride.eventId)))
        }
        if rides.count == 0 {
            upcomingEventsSpacer.constant = 25
        }
        
        upcomingRidesHeight.constant = CGFloat(ridesRowHeight)*CGFloat(rides.count)
        
        table?.reloadData()
        eventsTable?.reloadData()
        
    }
    
    // prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "introSegue" {
            if let introViewController = segue.destinationViewController as? IntroViewController {
                introViewController.mainViewController = sender as? MainViewController
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Helper function for determining if the application has been launched before
    private func hasAppLaunchedBefore() -> Bool {
        let defaultSettings = NSUserDefaults.standardUserDefaults()
        
        if let _ = defaultSettings.stringForKey("hasLaunchedBefore") {
            return true
        }
        else {
            defaultSettings.setBool(true, forKey: "hasLaunchedBefore")
            return false
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.table) {
            return items.count
        }
        else {
            //Display the three soonest events
            return events.count
            
        }
    }
    
    func getEventNameForEventId(id : String)->String{
        
        for event in events{
            if(event.id != "" && event.id == id){
                return event.name
            }
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.table) {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UpcomingItemCell
            
            cell.month.text = months[indexPath.row]
            cell.day.text = days[indexPath.row]
            cell.summary.text = items[indexPath.row]
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! UpcomingEventCell
            
            cell.nameLabel.text = events[indexPath.row].name
            cell.location.text = events[indexPath.row].getLocationString()
            cell.time.text = events[indexPath.row].getStartTime()
            cell.AMorPM.text = events[indexPath.row].getAmOrPm()
            cell.day.text = events[indexPath.row].getWeekday()
            
            //Change the alignment so that the day is in the center of the time+am
            let position = (cell.time.bounds.width + cell.AMorPM.bounds.width)/2
            let newConstant = position - cell.time.bounds.width/2
            cell.dayAlignment.constant = newConstant
            
            //If the address is only 1 line, add more space to the top of the name label
            let length = cell.location.text.characters.count
            
            if length < 29 {
                cell.nameSpacer.constant = 18
            }
            
            return cell
            
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.table) {
            return 100.0
        }
        else {
           return 100
        }
        
    }
    
    //reveal controller function for disabling the current view
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if position == FrontViewPosition.Left {
            for view in self.view.subviews {
                view.userInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.Right {
            for view in self.view.subviews {
                view.userInteractionEnabled = false
            }
        }
    }
}

