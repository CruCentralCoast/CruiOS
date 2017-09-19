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
import DZNEmptyDataSet
import MRProgress

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SWRevealViewControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {
    var items = [String]()//["Church on Sunday!", "Fall Retreat", "Bowling lessons with Pete, or was it Peter? Find out at the Event", "Idk was it peter", "Futbol"]
    var months = [String]()
    var days = [String]()
    var rides = [Ride]()
    var upcomingEvents = [Event]()
    var allEvents = [Event]()
    var ridesRowHeight = 100
    var offerVC: NewOfferRideViewController!
    var hasConnection = true

    @IBOutlet weak var offerRideButton: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var upcomingEventsSpacer: NSLayoutConstraint!
    @IBOutlet weak var upcomingRidesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var eventsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var socialBarSpace: NSLayoutConstraint!
    var noRideString: NSAttributedString!{
        didSet {
            table!.reloadData()
        }
    }
    var noEventsString: NSAttributedString!{
        didSet {
            eventsTable!.reloadData()
        }
    }
    var noConnectionRidesString: NSAttributedString!
    var noConnectionEventsString: NSAttributedString!
    
    // MARK: Actions

    @IBAction func facebookTapped(_ sender: UIButton) {
        
        UIApplication.shared.openURL(URL(string: "http://www.facebook.com/CruCalPolySLO")!)
        
    }
    
    @IBAction func instagramTapped(_ sender: UIButton) {
        
        let instagramHooks = "instagram://user?username=\(Config.instagramUsername)"
        let instagramUrl = URL(string: instagramHooks)
        if UIApplication.shared.canOpenURL(instagramUrl!)
        {
            UIApplication.shared.openURL(instagramUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "http://instagram.com/crucentralcoast")!)
        }
        
        
    }
    
    @IBAction func youtubeTapped(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "http://www.youtube.com/user/slocrusade")!)
    }
    
    @IBAction func twitterTapped(_ sender: UIButton) {
        let twitterHook = "twitter://user?screen_name=CruCentralCoast"
        let twitterUrl = URL(string: twitterHook)
        if UIApplication.shared.canOpenURL(twitterUrl!)
        {
            UIApplication.shared.openURL(twitterUrl!)
            
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(URL(string: "http://twitter.com/CruCentralCoast")!)
        }
    }
    
    
    
    @IBAction func openOfferRide(_ sender: UIButton) {
        self.navigationController?.pushViewController(offerVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontName, size: 20)!], for: UIControlState())
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: self.menuButton)
        
        //Change nav title font
        navigationItem.title = "Home"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        
        //Check for connection then load rides and events in the completion function
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        self.table!.tableFooterView = UIView()
        
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 16)!, NSForegroundColorAttributeName: UIColor.black]
        noRideString = NSAttributedString(string: "No rides for the next two weeks", attributes: attributes)
        
        noEventsString = NSAttributedString(string: "No events for the next two weeks", attributes: attributes)
        
        noConnectionRidesString = NSAttributedString(string: "Currently no rides available. Check your internet connection.", attributes: attributes)
        
        noConnectionEventsString = NSAttributedString(string: "No events available. Check your internet connection.", attributes: attributes)
        
        self.table!.emptyDataSetSource = self
        self.table!.emptyDataSetDelegate = self
        self.table!.separatorStyle = .none
        self.eventsTable!.emptyDataSetSource = self
        self.eventsTable!.emptyDataSetDelegate = self
        self.eventsTable!.separatorStyle = .none
        
        //Take this out eventually
        offerVC = NewOfferRideViewController()
        
        //Change the spacing between the events table and the social bar
        let screenSize = UIScreen.main.bounds
        
        if scrollView.frame.height <= screenSize.height {
            let totalSpace = screenSize.height - eventsTable.frame.maxY
            socialBarSpace.constant = totalSpace - 65
        }
        
    }
    
    /* This function acts after the view is loaded and appears on the phone. */
    override func viewDidAppear(_ animated: Bool) {
        self.table!.backgroundColor = Colors.googleGray
        self.eventsTable!.backgroundColor = Colors.googleGray
        
        if !hasAppLaunchedBefore() {
            self.performSegue(withIdentifier: "introSegue", sender: self)
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    //Test to make sure there is a connection then load resources
    func finishConnectionCheck(_ connected: Bool){
        if(!connected){
            hasConnection = false
            //Display a message if either of the tables are empty
            
            self.table!.reloadData()
            self.eventsTable!.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            //hasConnection = false
        }else{
            hasConnection = true
            
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            //load upcoming items
            CruClients.getRideUtils().getMyRides(insertRide, afterFunc: finishRideInsert)
            
            
        }
        
    }
    
    //Set the text to be displayed when either table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if scrollView == self.table {
            if hasConnection {
                return noRideString
            }
            return noConnectionRidesString
        }
        else {
            if hasConnection {
                return noEventsString
            }
            return noConnectionEventsString
        }
        
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return Colors.googleGray
    }
    
    func insertRide(_ dict : NSDictionary) {
        //create ride
        let newRide = Ride(dict: dict)!
        
        let curDate = Date()
        let week = curDate.addDays(14)
        
        //Check if ride hasn't already happened and is within the next week
        if (newRide.departureDate?.isGreaterThanDate(curDate.addDays(-1)))! && (newRide.departureDate?.isLessThanDate(week))! {
            rides.insert(newRide, at: 0)
            rides.sort()
        }
    }
    
    //Asynchronous function that's called to insert an event into the table
    func insertEvent(_ dict : NSDictionary) {
        //Create event
        let event = Event(dict: dict)!
        
        //Insert event into the array only if it's within the next week
        let curDate = Date()
        let week = curDate.addDays(14)
        
        if(event.startNSDate.isLessThanDate(week) && event.startNSDate.compare(Date()) != .orderedAscending){
            
            self.upcomingEvents.insert(event, at: 0)
        }
        self.allEvents.insert(event, at: 0)
    }
    
    func finishRideInsert(_ type: ResponseType){
        
        switch type{
        case .noRides:
            self.table!.emptyDataSetSource = self
            self.table!.emptyDataSetDelegate = self
            CruClients.getServerClient().getData(DBCollection.Event, insert: insertEvent, completionHandler: finishInserting)
            //noRideString = NSAttributedString(string: "Currently no rides available", attributes: [ NSFontAttributeName: UIFont(name: Config.fontName, size: 16)!, NSForegroundColorAttributeName: UIColor.blackColor()])
            
        case .noConnection:
            print("\nCould not finish inserting rides. No connection found.\n")
            //self.ridesTableView.emptyDataSetSource = self
            //self.ridesTableView.emptyDataSetDelegate = self
            //noRideImage = UIImage(named: Config.noConnectionImageName)!
            //MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            
        default:
            CruClients.getServerClient().getData(DBCollection.Event, insert: insertEvent, completionHandler: finishInserting)
        }
        
        
        rides.sort()
    }
    
    //Function that inserts the rides and events only if we get all the rides first
    func finishInserting(_ success: Bool){
        
        //MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        for ride in rides{
            months.append(ride.month)
            days.append(String(ride.day))
            items.append(ride.getDescription(getEventNameForEventId(ride.eventId)))
        }
        
        if rides.count == 0 {
            upcomingRidesHeight.constant = CGFloat(50)
            self.table!.emptyDataSetSource = self
            self.table!.emptyDataSetDelegate = self
            self.table!.reloadData()
        }
        else {
            
            upcomingRidesHeight.constant = CGFloat(ridesRowHeight)*CGFloat(rides.count)
            table?.reloadData()
        }
        
        if upcomingEvents.count == 0 {
            self.eventsTable!.emptyDataSetSource = self
            self.eventsTable!.emptyDataSetDelegate = self
            eventsTableHeight.constant = CGFloat(50)
            self.eventsTable!.reloadData()
        }
        else {
            eventsTableHeight.constant = CGFloat(100)*CGFloat(upcomingEvents.count)
            eventsTable?.reloadData()
        }

        //disable scrolling
        table.isScrollEnabled = false
        eventsTable.isScrollEnabled = false
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        
    }
    
    // prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "introSegue" {
            if let introViewController = segue.destination as? IntroViewController {
                introViewController.mainViewController = sender as? MainViewController
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Helper function for determining if the application has been launched before
    fileprivate func hasAppLaunchedBefore() -> Bool {
        let defaultSettings = UserDefaults.standard
        
        if let _ = defaultSettings.string(forKey: "hasLaunchedBefore") {
            return true
        }
        else {
            defaultSettings.set(true, forKey: "hasLaunchedBefore")
            return false
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.table) {
            return items.count
        }
        else {
            //Display the three soonest events
            return upcomingEvents.count
            
        }
    }
    
    func getEventNameForEventId(_ id : String)->String{
        
        for event in allEvents{
            if(event.id != "" && event.id == id){
                return event.name
            }
        }
        
        return ""
    }
    
    //Adds the drop shadow to the ride and event cards
    fileprivate func addDropShadow(_ rideCell: UpcomingItemCell?, eventCell: UpcomingEventCell?) {
        rideCell?.card.layer.shadowColor = UIColor.black.cgColor
        rideCell?.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        rideCell?.card.layer.shadowOpacity = 0.25
        rideCell?.card.layer.shadowRadius = 2
        
        eventCell?.card.layer.shadowColor = UIColor.black.cgColor
        eventCell?.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        eventCell?.card.layer.shadowOpacity = 0.25
        eventCell?.card.layer.shadowRadius = 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.table) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UpcomingItemCell
            
            cell.month.text = months[indexPath.row]
            cell.day.text = days[indexPath.row]
            cell.summary.text = items[indexPath.row]
            addDropShadow(cell, eventCell: nil)
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! UpcomingEventCell
            
            cell.nameLabel.text = upcomingEvents[indexPath.row].name
            cell.location.text = upcomingEvents[indexPath.row].getLocationString()
            cell.time.text = upcomingEvents[indexPath.row].getStartTime()
            cell.AMorPM.text = upcomingEvents[indexPath.row].getAmOrPm()
            cell.day.text = upcomingEvents[indexPath.row].getStartTimeForHome()
            addDropShadow(nil, eventCell: cell)
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.table) {
            return 100.0
        }
        else {
           return 100
        }
        
    }
    
    //reveal controller function for disabling the current view
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
        if position == FrontViewPosition.left {
            for view in self.view.subviews {
                view.isUserInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.right {
            for view in self.view.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func closeNotifications(_ segue: UIStoryboardSegue) {
        
    }
}

