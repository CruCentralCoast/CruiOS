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
    
    override func viewDidAppear(_ animated: Bool) {
        table.emptyDataSetDelegate = self
        table.emptyDataSetSource = self

        table.reloadData()
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: Config.noPassengersImage)
    }
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func removePass(_ pass: Passenger){
        passengersToDrop.append(pass)
    }
    
    func reAddPass(_ pass: Passenger){
        if let index = passengersToDrop.index(of: pass) {
            passengersToDrop.remove(at: index)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passengers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PassengerTableViewCell!
        
        
        if editable{
            cell = tableView.dequeueReusableCell(withIdentifier: "updatePassengerCell") as? PassengerTableViewCell
            cell.dropButton.layer.cornerRadius = 10
            cell.dropButton.layer.borderWidth = 1
            cell.dropButton.layer.borderColor = UIColor.black.cgColor
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PassengerTableViewCell
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
    @IBAction func okPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
