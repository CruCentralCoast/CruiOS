//
//  DriverRideDetailViewController.swift
//  Cru
//
//  Created by Max Crane on 2/4/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class DriverRideDetailViewController: UIViewController, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var details = [EditableItem]()
    var event: Event!
    var ride: Ride!{
        didSet {
            
        }
    }
    var passengers = [Passenger]()
    let cellHeight = CGFloat(60)
    var rideVC: RidesViewController?
    var addressView: UITextView?
    var timeLabel: UITextView?
    var dateLabel: UITextView?
    var directionLabel: UITextView?
    var seatsOffered: UITextView?
    var seatsLeft: UITextView?
    var radius: UITextView?
    @IBOutlet weak var detailsTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
      
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!], for: UIControlState())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDetails()
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: Config.fontBold, size: 15)!], for: UIControlState())
        detailsTable.separatorStyle = .none
        
        detailsTable.estimatedRowHeight = 50.0 // Replace with your actual estimation
        detailsTable.rowHeight = UITableViewAutomaticDimension
  
        CruClients.getRideUtils().getPassengersByIds(ride.passengers, inserter: insertPassenger, afterFunc: {success in
            //TODO: should be handling failure here
        })
        
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(DriverRideDetailViewController.goToEditPage))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    
    
    func populateDetails(){
        details = ride.getDriverDetails()        
    }
    
    func updateData(){
        details.removeAll()
        ride.eventName = event.name
        details = ride.getDriverDetails()
        self.detailsTable.reloadData()
//        timeLabel?.text = ride.getTime()
//        dateLabel?.text = ride.getDate()
//        addressView?.text = ride.getCompleteAddress()
//        seatsOffered?.text = String(ride.seats)
//        seatsLeft?.text = String(ride.seatsLeft())
//        radius?.text = ride.getRadius()
//        self.detailsTable.reloadData()
    }
    
    
    func goToEditPage(){
        self.performSegue(withIdentifier: "editSegue", sender: self)
    }
    
    func insertPassenger(_ newPassenger: NSDictionary){
        let newPassenger = Passenger(dict: newPassenger)
        passengers.append(newPassenger)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableView functions for the passenger list
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        
        if (tableView.isEqual(detailsTable)){
            return details.count
        }
        
        
        return 0
    }
    //Set up the cell
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var chosenCell: UITableViewCell?
        
        
        if(tableView.isEqual(detailsTable)){
            let cellIdentifier = "smallCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DriverDetailCell
            
            cell.cellLabel.text = details[indexPath.row].itemName
            //cell.label.text = details[indexPath.row].itemName
            cell.value.text = details[indexPath.row].itemValue
            
            
//            var fontSize = CGFloat(19.0)
//            cell.value.font = UIFont(name: Config.fontName, size: fontSize)
//            
//            while (cell.value.contentSize.height > cell.value.frame.size.height && fontSize > 8.0) {
//                fontSize -= 1.0;
//                cell.value.font = UIFont(name: Config.fontName, size: fontSize)
//            }
            
            
            
            if (details[indexPath.row].itemName == Labels.addressLabel){
                cell.value.dataDetectorTypes = .address
                cell.value.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
                //cell.textViewValue.text = details[indexPath.row].itemValue
                addressView = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.departureTimeLabel){
                timeLabel = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.departureDateLabel){
                dateLabel = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.seatsLeftLabel){
                seatsLeft = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.seatsLabel){
                seatsOffered = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.directionLabel){
                directionLabel = cell.value
            }
            else if(details[indexPath.row].itemName == Labels.pickupRadius){
                radius = cell.value
            }
            
            chosenCell = cell
        }
        
        return chosenCell!
        
    }
    
    
    // Reload the data every time we come back to this view controller
    override func viewDidAppear(_ animated: Bool) {
        //passengerTable.reloadData()
        self.navigationItem.title = "Ride Details"
    }
    
    // MARK: - Navigation
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        Cancler.confirmCancel(self, handler: cancelConfirmed)
    }
    
    func cancelConfirmed(_ action: UIAlertAction){
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        CruClients.getRideUtils().leaveRideDriver(ride.id, handler: handleCancelResult)
    }
    
    func handleCancelResult(_ success: Bool){
        if(success){
            Cancler.showCancelSuccess(self, handler: { action in
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                    self.rideVC?.refresh(self)
                }
                
            })
        }
        else{
            Cancler.showCancelFailure(self)
        }
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue"{
            if let destVC = segue.destination as? OfferOrEditRideViewController{
                print("this hapepned")
                destVC.ride = ride
                destVC.event = event
                destVC.rideVC = self.rideVC
                destVC.rideDetailVC = self
                destVC.passengers = passengers
            }
            
        }
        else if(segue.identifier == "passengerSegue"){
            let popoverVC = segue.destination
            popoverVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.77)
            popoverVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (addressView?.frame.origin.y)! - 50.0,width: 0,height: 0)

            let controller = popoverVC.popoverPresentationController
            
            if(controller != nil){
                controller?.delegate = self
            }
            
            
            if let vc = popoverVC as? PassengersViewController{
                vc.passengers = self.passengers
            }
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
