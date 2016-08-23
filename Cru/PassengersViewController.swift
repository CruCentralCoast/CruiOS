//
//  PassengersViewController.swift
//  Cru
//
//  Created by Max Crane on 5/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class PassengersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
  DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    var passengers = [Passenger]()
    var passengersToDrop = [Passenger]()
    var editable = false
    var parentEditVC: OfferOrEditRideViewController!
    var editVC: NewDriverRideDetailViewController!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        table.emptyDataSetDelegate = self
        table.emptyDataSetSource = self
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: Config.noPassengersImage)
    }
    override func viewWillDisappear(animated: Bool) {
        var remainingPassengers = [Passenger]()
        var remainingPassString = [String]()
        
        if editable {
            for pass in passengers{
                if (!passengersToDrop.contains(pass)){
                    remainingPassengers.append(pass)
                    remainingPassString.append(pass.id)
                }
            }
            
            //parentEditVC.passengers = remainingPassengers
            //parentEditVC.ride.passengers = remainingPassString
            
            editVC.passengers = remainingPassengers
            editVC.ride.passengers = remainingPassString
            
            for pass in self.passengersToDrop{
                //parentEditVC.passengersToDrop.append(pass)
                editVC.passengersToDrop.append(pass)
            }
            //parentEditVC.updateOptions()
            editVC.fillRideInfo()
        }
    }
    
    func removePass(pass: Passenger){
        passengersToDrop.append(pass)
    }
    
    func reAddPass(pass: Passenger){
        if let index = passengersToDrop.indexOf(pass) {
            passengersToDrop.removeAtIndex(index)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passengers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PassengerTableViewCell!
        
        
        if editable{
            cell = tableView.dequeueReusableCellWithIdentifier("updatePassengerCell") as? PassengerTableViewCell
            cell.dropButton.layer.cornerRadius = 10
            cell.dropButton.layer.borderWidth = 1
            cell.dropButton.layer.borderColor = UIColor.blackColor().CGColor
        }
        else{
            cell = tableView.dequeueReusableCellWithIdentifier("cell") as? PassengerTableViewCell
        }
        
        cell.parentTable = self
        cell.passenger = passengers[indexPath.row]
        cell.nameLabel.text = passengers[indexPath.row].name
        cell.phoneLabel.text = PhoneFormatter.unparsePhoneNumber(passengers[indexPath.row].phone)
        
        
        let mod = indexPath.row % 4
        var color: UIColor?
        
        
        if(mod == 0) {
            color = CruColors.darkBlue
        }
        else if(mod == 1) {
            color = CruColors.lightBlue
        }
        else if(mod == 2) {
            color = CruColors.yellow
        }
        else if(mod == 3) {
            color = CruColors.orange
        }
        
        cell.nameLabel.textColor = color
        cell.phoneLabel.tintColor = color
        
        
        return cell!
    }
    @IBAction func okPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
