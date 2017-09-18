//
//  JoinRideViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/12/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import Alamofire
import SwiftyJSON
import MRProgress

class JoinRideViewController: UIViewController, JoinRideDelegate, AlertDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var dirLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var toRideView: UIView!
    @IBOutlet weak var fromRideView: UIView!
    @IBOutlet weak var toRideSeparator: UIView!
    @IBOutlet weak var fromRideSeparator: UIView!
    @IBOutlet weak var directionIcon: UIImageView!
    
    // MARK: - To Ride View Outlets
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var toAMPMLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var eventArrTimeLabel: UILabel!
    @IBOutlet weak var eventArrAMPMLabel: UILabel!
    @IBOutlet weak var eventArrDateLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var toCityLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventCityLabel: UILabel!
    
    // MARK: - From Ride View Outlets
    
    @IBOutlet weak var homeArrTimeLabel: UILabel!
    @IBOutlet weak var homeArrAMPMLabel: UILabel!
    @IBOutlet weak var homeArrDateLabel: UILabel!
    @IBOutlet weak var eventDeptTimeLabel: UILabel!
    @IBOutlet weak var eventDeptAMPMLabel: UILabel!
    @IBOutlet weak var eventDeptDateLabel: UILabel!
    @IBOutlet weak var homeArrAddressLabel: UILabel!
    @IBOutlet weak var homeArrCityLabel: UILabel!
    @IBOutlet weak var eventDeptAddressLabel: UILabel!
    @IBOutlet weak var eventDeptCityLabel: UILabel!
    
    // MARK: - Properties
    var ride: Ride!
    var event: Event!
    var wasLinkedFromEvents = false
    var wasLinkedFromMap = false
    var rideStartLocation: CLLocation!
    var eventLoc: CLLocation!
    weak var popVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        //Set up the Google map with markers and route
        setupMapView()
        
        //Set general ride info
        setupRideInfo()
        
        //Set up To-Ride view
        setupToRideView()
        
        //Set up From-Ride view
        setupFromRideView()
        
        //Set navbar title
        navigationItem.title = "Ride to \(event.name)"
    }

    // MARK: - Setup Functions
    private func setupMapView() {
        
        DispatchQueue.global(qos: .userInitiated).async { // 1
            //var storedError: NSError?
            let downloadGroup = DispatchGroup() // 2
            downloadGroup.enter()
            self.getQueryLocation(self.ride.getCompleteAddress(), handler: {loc in
                self.rideStartLocation = loc
                downloadGroup.leave()
            })
            
            downloadGroup.enter()
            self.getQueryLocation(self.event.getLocationString(), handler: {loc in
                self.eventLoc = loc
                downloadGroup.leave()
            })
            
            downloadGroup.wait() // 5
            DispatchQueue.main.async { // 6
                
                let marker = GMSMarker()
                marker.position = self.rideStartLocation.coordinate
                marker.map = self.mapView
                
                let eventMarker = GMSMarker()
                eventMarker.position = self.eventLoc.coordinate
                eventMarker.map = self.mapView
                self.centerMap()
                self.drawPath()
            }
        }
        
        //getRideQueryLocation(ride.id, query: ride.getCompleteAddress())
        
        //getQueryLocation(event.getLocationString(), handler: setEvent)
        
    }
    
    private func setupToRideView() {
        print(ride.getDirection())
        if ride.getDirection() == "from" {
            toRideView.isHidden = true
            toRideSeparator.isHidden = true
            directionIcon.image = #imageLiteral(resourceName: "from-event-sign")
        }
        else {
            self.toTimeLabel.text = ride.getDeptTimeNoAMPM()
            self.toAMPMLabel.text = ride.getDeptAMPM()
            self.toDateLabel.text = ride.getShortDepartureDay().uppercased()
            self.eventArrTimeLabel.text = event.getStartTime()
            self.eventArrAMPMLabel.text = event.getAmOrPm()
            self.eventArrDateLabel.text = event.getShortStartDay().uppercased()
            self.toAddressLabel.text = ride.getStreetString()
            self.toCityLabel.text = ride.getSuburbString()
            self.eventAddressLabel.text = event.getStreetString()
            self.eventCityLabel.text = event.getSuburbString()
        }
    }
    
    private func setupFromRideView() {
        if ride.getDirection() == "to" {
            fromRideView.isHidden = true
            fromRideSeparator.isHidden = true
            directionIcon.image = #imageLiteral(resourceName: "to-event-sign")
        }
        else {
            // Calculate home arrival time
            let startRideDate = ride.departureDate
            let endRideDate = event.startNSDate
            let hours = endRideDate.hours(from: startRideDate!)
            let mins = endRideDate.minutes(from: startRideDate!)
            
            var homeArrTime = event.endNSDate.addHours(hours)
            homeArrTime.addTimeInterval(Double(mins) * 60.0)
            
            self.homeArrTimeLabel.text = GlobalUtils.stringFromDate(homeArrTime, format: "h:mm")
            self.homeArrAMPMLabel.text = GlobalUtils.stringFromDate(homeArrTime, format: "a")
            self.homeArrDateLabel.text = GlobalUtils.stringFromDate(homeArrTime, format: "MMM d").uppercased()
            
            self.eventDeptTimeLabel.text = event.getEndTime()
            self.eventDeptAMPMLabel.text = event.getEndAmOrPm()
            self.eventDeptDateLabel.text = GlobalUtils.stringFromDate(event.endNSDate, format: "MMM d").uppercased()
            
            self.homeArrAddressLabel.text = ride.getStreetString()
            self.homeArrCityLabel.text = ride.getSuburbString()
            self.eventDeptAddressLabel.text = event.getStreetString()
            self.eventDeptCityLabel.text = event.getSuburbString()
        }
    }
    
    private func setupRideInfo() {
        self.driverLabel.text = ride.driverName
        
        if ride.seatsLeft() == 1 {
            self.seatsLabel.text = "\(ride.seatsLeftAsString()) seat left"
        }
        else {
            self.seatsLabel.text = "\(ride.seatsLeftAsString()) seats left"
        }
        
        self.dirLabel.text = ride.getDisplayableDirection()
        
        if ride.getDirection() == "to" {
            self.directionIcon.image = #imageLiteral(resourceName: "to-event-sign")
        }
        else if ride.getDirection() == "from" {
            self.directionIcon.image = #imageLiteral(resourceName: "from-event-sign")
        }
        
        if ride.radius == 1 {
            self.radiusLabel.text = "Pickup within \(ride.radius) mile"
        }
        else {
            self.radiusLabel.text = "Pickup within \(ride.radius) miles"
        }
    }
    
    func getQueryLocation(_ query: String, handler: @escaping (CLLocation)->()){
        var initialLocation = CLLocation()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                initialLocation = item.placemark.location!
                handler(initialLocation)
                break
            }
        }
    }
    
    func centerMap() {
        let bounds = GMSCoordinateBounds(coordinate: eventLoc.coordinate, coordinate: rideStartLocation.coordinate)
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    func drawPath() {
        let origin = "\(self.rideStartLocation.coordinate.latitude),\(self.rideStartLocation.coordinate.longitude)"
        let destination = "\(self.eventLoc.coordinate.latitude),\(self.eventLoc.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Config.googleAPIKey)"
        
        Alamofire.request(url).responseJSON { response in
            print(response.request!)  // original URL request
            print("response: \(response.response!)") // HTTP URL response
            print("data: \(response.data!)")     // server data
            print("result: \(response.result)")   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.map = self.mapView
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func joinRide(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "findride", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "submitDialog") as! SubmitRideInfoViewController
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Join Ride Delegate
    func didFinishTask(name: String, phone: String) {
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        CruClients.getRideUtils().joinRide(name, phone: phone, direction: ride.getServerDirection(),  rideId: ride.id, eventId: event.id, handler: successfulJoin)
    }
    
    func successfulJoin(_ success: Bool){
        //var successAlert :UIAlertController?
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        let storyboard = UIStoryboard(name: "findride", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "alertVC") as! AlertViewController
        controller.alertTitle = "Ride Signup"
        controller.delegate = self
        
        if success {
            controller.buttonTitle = "Great"
            controller.message = "You successfully joined the ride! Contact your driver for more details about the ride."
        }
        else {
            controller.buttonTitle = "Darn"
            controller.message = "Sorry, looks like you couldn't join the ride. Try again later!"
        }
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    // MARK: - Alert View Controller Delegate Function
    func closeAlertAction(_ button: UIButton) {
        if let navController = self.navigationController {
            
            if let vc = popVC {
                navController.popToViewController(vc, animated: true)
            }
        }
    }
    
    //Go back to MyRides with new ride added to the list
    func unwindToRideList(_ action: UIAlertAction){
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol JoinRideDelegate {
    func didFinishTask(name: String, phone: String)
}
