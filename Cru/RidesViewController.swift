//
//  RidesViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 4/14/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress
import DZNEmptyDataSet


class RidesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SWRevealViewControllerDelegate {
    let roundTrip = "round-trip"
    let roundTripDirection = "both"
    let fromEvent = "from event"
    let toEvent = "to event"
    let driver = "driver"
    let rider = "rider"
    var refreshControl: UIRefreshControl!
    var rides = [Ride]()
    var ridesDroppedFrom = [Ride]()
    var events = [Event]()
    var tappedRide = Ride?()
    var tappedEvent = Event?()
    var noRideImage: UIImage?{
        didSet{
            ridesTableView.reloadData()
        }
    }
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var ridesTableView: UITableView!
    @IBOutlet weak var findRideButton: UIButton!
    @IBOutlet weak var offerRideButton: UIButton!
    var passMap: LocalStorageManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.ridesPage = self
        
        ridesTableView.separatorStyle = .None
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)

        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.ridesTableView.addSubview(self.refreshControl)
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        CruClients.getRideUtils().getMyRides(insertRide, afterFunc: finishRideInsert)
        
        noRideImage = UIImage(named: Config.noRidesImageName)!
        
        
        passMap = RideUtils.getMyPassengerMaps()
        
        
        self.ridesTableView.tableFooterView = UIView()
        ridesTableView.rowHeight = UITableViewAutomaticDimension
        ridesTableView.estimatedRowHeight = 75
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return noRideImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleOfferRide(sender: AnyObject){
        self.performSegueWithIdentifier("offerridesegue", sender: self)
        
    }
    
    @IBAction func handleFindRide(sender: AnyObject){
        self.performSegueWithIdentifier("findridesegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "offerridesegue"{
            //let destVC = segue.destinationViewController as! OfferOrEditRideViewController
            let destVC = segue.destinationViewController as! NewOfferRideViewController
            destVC.events = self.events
            destVC.rideVC = self
            
        }
        if segue.identifier == "findridesegue"{
            let destVC = segue.destinationViewController as? FilterByEventViewController
            destVC?.rideVC = self
        }
        if(segue.identifier == "riderdetailsegue") {
            
            let yourNextViewController = (segue.destinationViewController as! RiderRideDetailViewController)
            
            yourNextViewController.ride = tappedRide
            yourNextViewController.event = tappedEvent
            yourNextViewController.rideVC = self
            
        }
        
        if(segue.identifier == "driverdetailsegue") {
            
            //let yourNextViewController = (segue.destinationViewController as! DriverRideDetailViewController)
            
            let yourNextViewController = (segue.destinationViewController as! NewDriverRideDetailViewController)
            
            yourNextViewController.ride = tappedRide
            yourNextViewController.event = tappedEvent
            yourNextViewController.rideVC = self
        }
    }
    
    func refresh(){
        self.refresh(self)
    }
    
    func refresh(sender:AnyObject)
    {
        rides.removeAll()
        ridesTableView.emptyDataSetDelegate = nil
        ridesTableView.emptyDataSetSource = nil
        ridesTableView.reloadData()
        CruClients.getRideUtils().getMyRides(insertRide, afterFunc: finishRideInsert)
        passMap = RideUtils.getMyPassengerMaps()
    }
    
    func finishRideInsert(type: ResponseType){
        if(self.refreshControl.refreshing){
            self.refreshControl?.endRefreshing()
        }
        
        switch type{
            case .NoRides:
                self.ridesTableView.emptyDataSetSource = self
                self.ridesTableView.emptyDataSetDelegate = self
                noRideImage = UIImage(named: Config.noRidesImageName)!
                CruClients.getServerClient().getData(.Event, insert: insertEvent, completionHandler: finishInserting)
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
            
            case .NoConnection:
                self.ridesTableView.emptyDataSetSource = self
                self.ridesTableView.emptyDataSetDelegate = self
                noRideImage = UIImage(named: Config.noConnectionImageName)!
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
                offerRideButton.userInteractionEnabled = false
                findRideButton.userInteractionEnabled = false
            
            default:
                self.ridesTableView.emptyDataSetSource = nil
                self.ridesTableView.emptyDataSetDelegate = nil
                CruClients.getServerClient().getData(.Event, insert: insertEvent, completionHandler: finishInserting)
        }
        
        rides.sortInPlace()
        self.ridesTableView.reloadData()
    }
    
    
    func insertRide(dict : NSDictionary) {
        let newRide = Ride(dict: dict)
        
        if let pMap = passMap as? MapLocalStorageManager{
            if(newRide!.gcmId != Config.gcmId()){
                if let passId = pMap.getElement(newRide!.id) as? String{
                    
                    //if dropped from ride
                    if(!newRide!.isPassengerInRide(passId)){
                        ridesDroppedFrom.append(newRide!)
                        pMap.removeElement(newRide!.id)
                        passMap = RideUtils.getMyPassengerMaps()
                    }
                        
                    //if passenger in ride
                    else{
                        rides.insert(newRide!, atIndex: 0)
                        self.ridesTableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Middle)
                    }
                }
            }
            else{
                
                //if driving a ride
                rides.insert(newRide!, atIndex: 0)
                self.ridesTableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Middle)
            }
        }
        
        rides.sortInPlace()
    }
    
    
    func finishInserting(success: Bool){
        showDroppedRides()
        
        self.ridesTableView.beginUpdates()
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)        
        self.ridesTableView.reloadData()
        self.ridesTableView.endUpdates()
    }
    
    func showDroppedRides(){
        if(ridesDroppedFrom.count > 0){
            var droppedMsg = ""
            
            if(ridesDroppedFrom.count == 1){
                droppedMsg += "Sorry, It looks like you were dropped from a ride to the following event: "
            }else{
                droppedMsg += "Sorry, It looks like you were dropped from a ride to the following events: "
            }
            
            for ride in ridesDroppedFrom{
                droppedMsg += getEventNameForEventId(ride.eventId) + "\n"
            }
            ridesDroppedFrom.removeAll()
            
            let droppedAlert = UIAlertController(title: droppedMsg, message: "", preferredStyle: UIAlertControllerStyle.Alert)
            droppedAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(droppedAlert, animated: true, completion: nil)
            
        }
        
        self.ridesTableView.emptyDataSetSource = self
        self.ridesTableView.emptyDataSetDelegate = self
        noRideImage = UIImage(named: Config.noRidesImageName)!
    }
    
    func insertEvent(dict : NSDictionary) {
        //create event
        let event = Event(dict: dict)
        
        //insert into event array
        if(event?.rideSharingEnabled == true){
            events.insert(event!, atIndex: 0)
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
    
    func getEventForEventId(id : String)->Event{
        
        for event in events{
            if(event.id != "" && event.id == id){
                return event
            }
        }
        
        return Event()!
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = " My Rides"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //load cell and ride associated with that cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ride", forIndexPath: indexPath) as! RideTableViewCell
        let ride = rides[indexPath.row]
        
        
        
        cell.day.text = String(ride.day)
        cell.month.text = ride.month
        
        
        if(ride.gcmId == Config.gcmId()){
            cell.rideType.text = driver
            cell.icon.image  = UIImage(named: driver)
        }
        else
        {
            cell.rideType.text = rider
            cell.icon.image = UIImage(named: rider)
        }
        
        
        
        cell.eventTitle.text = getEventNameForEventId(ride.eventId)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tappedRide = rides[indexPath.row]
        tappedEvent = getEventForEventId((tappedRide?.eventId)!)
        tappedRide!.eventName = (tappedEvent?.name)!
        
        if(tappedRide?.gcmId == Config.gcmId()){
            self.performSegueWithIdentifier("driverdetailsegue", sender: self)
        }
        else{
            self.performSegueWithIdentifier("riderdetailsegue", sender: self)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
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
