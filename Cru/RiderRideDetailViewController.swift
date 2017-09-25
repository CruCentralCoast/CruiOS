//
//  RiderRideDetailViewController.swift
//  Cru
//
//  Created by Max Crane on 2/4/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit

class RiderRideDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var detailsTable: UITableView!
    let roundTrip = "round-trip"
    let roundTripDirection = "both"
    let fromEvent = "from event"
    let toEvent = "to event"
    let driver = "driver"
    let rider = "rider"
    
    var details = [EditableItem]()
    var event: Event!
    var ride: Ride?
    var rideVC: RidesViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Ride Details"
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        populateDetails()
        
        detailsTable.estimatedRowHeight = 44
        detailsTable.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func populateDetails(){
        details = ride!.getRiderDetails()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: DetailCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "smallerCell") as! DetailCell
        
        cell.textViewValue.text = details[indexPath.row].itemValue
        cell.title.text = details[indexPath.row].itemName
        
        
        if(details[indexPath.row].itemName == Labels.driverNumber){
            cell.textViewValue.text = PhoneFormatter.unparsePhoneNumber(details[indexPath.row].itemValue)
            cell.textViewValue.dataDetectorTypes = .phoneNumber
            cell.textViewValue.isUserInteractionEnabled = true
        }
        else if(details[indexPath.row].itemName == Labels.addressLabel){
            cell.textViewValue.dataDetectorTypes = .address
            cell.textViewValue.isUserInteractionEnabled = true
        }

        return cell
    }
    

    func setTime(_ td : TimeDetail){
        //date.text = td.getTime()
    }
    
    @IBAction func eventLabelPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "eventDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "eventDetailSegue"){
            let vc = segue.destination as! EventDetailsViewController
            vc.event = self.event
        }
    }
    
    func setupMap(){
        
        var initialLocation = CLLocation()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = ride!.getCompleteAddress()
        
        if(request.naturalLanguageQuery != nil){
            //request.naturalLanguageQuery = self.address.text
        }
        
        //request.region = pickupMap.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(error)")
                return
            }
            
            for item in response.mapItems {
                initialLocation = item.placemark.location!
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = initialLocation.coordinate
                //dropPin.title = self.address.text
                
                
                self.centerMapOnLocation(initialLocation)
                //self.pickupMap.addAnnotation(dropPin)
            }
        }
    }
    
    
    
    func centerMapOnLocation(_ location: CLLocation) {
        //let regionRadius: CLLocationDistance = 1000
        //let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
           // regionRadius * 2.0, regionRadius * 2.0)
        //pickupMap.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        Cancler.confirmCancel(self, handler: cancelConfirmed)
    }
    
    func cancelConfirmed(_ action: UIAlertAction){
        CruClients.getRideUtils().leaveRidePassenger(ride!, handler: { success in
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
                self.rideVC?.refresh()
            }
        })
    }
    
    func leaveRide(_ passid: String, rideid: String){
        
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
