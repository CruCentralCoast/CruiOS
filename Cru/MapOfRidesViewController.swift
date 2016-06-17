//
//  MapOfRidesViewController.swift
//  Cru
//
//  Created by Max Crane on 5/29/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit

class MapOfRidesViewController: UIViewController, MKMapViewDelegate {
    var rides = [Ride]()
    var event: Event!
    var hasShowedEvent = false
    var showedFirstRide = false
    var selectedPointAnnotation : MKPointAnnotation!
    var selectedAnnotation : MKAnnotation!
    var curOverlay: MKOverlay?
    let metersInMile = 1609.344
    var eventLoc: CLLocation!{
        didSet{
            currentLoc = eventLoc
            dropPinAtLocation(eventLoc, title: event.name, subtitle: "", rideId: "")
            //centerMapOnLocation(eventLoc, loadOverlay: false, radius: 0)
        }
    }
    @IBOutlet weak var bottomLabel: UIButton!
    var currentLoc : CLLocation!
    var rideLocs = [String:CLLocation]()
    var index = 0
    var selectedTitle = ""
    var selectedRide: Ride!
    var rideTVC : RidesViewController?
    var eventVC : EventDetailsViewController?
    var wasLinkedFromEvents = false 
    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        navigationItem.title = "Offered Rides"
        bottomLabel.setTitle("ride " + String(index + 1) + " of " + String(rides.count), forState: .Normal)
        getQueryLocation(event.getLocationString(), handler: setEvent)
        
        for ride in rides{
            getRideQueryLocation(ride.id, query: ride.getCompleteAddress())
        }
        
        var first = true
        
        for ride in rides{
            if(rideLocs[ride.id] != nil){
                
                dropPinAtLocation(rideLocs[ride.id]!, title: ride.getCompleteAddress(), subtitle: ride.getMapSubtitle(), rideId:  ride.id)
                
                if(first == true){
                    centerMapOnLocation(rideLocs[ride.id]!, loadOverlay: true, radius: ride.radius)
                    first = false
                }
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        if (rides.count >= 1 && !showedFirstRide && rideLocs[rides[0].id] != nil){
            let ride = rides[0]
            centerMapOnLocation(rideLocs[ride.id]!, loadOverlay: true, radius: ride.radius)
            dropPinAtLocation(rideLocs[ride.id]!, title: ride.getCompleteAddress(), subtitle: ride.getMapSubtitle(), rideId:  ride.id)
            showedFirstRide = true
        }
    }
    
    func getRideQueryLocation(rideId: String, query: String){
        var initialLocation = CLLocation()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                initialLocation = item.placemark.location!
                self.rideLocs[rideId] = initialLocation
                break
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = CruColors.lightBlue.colorWithAlphaComponent(0.1)//UIColor.blueColor().colorWithAlphaComponent(0.1)
        circleRenderer.strokeColor = CruColors.darkBlue//UIColor.blueColor()
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    
    
    func getQueryLocation(query: String, handler: (CLLocation)->()){
        var initialLocation = CLLocation()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
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
    
    
    func centerMapOnLocation(location: CLLocation, loadOverlay: Bool, radius: Int) {
        var regionRadius: CLLocationDistance = 500
        
        if(radius != 0){
            regionRadius = Double(radius * Int(metersInMile)) + 160
        }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: false)
        map.reloadInputViews()
        
        if(loadOverlay){
            loadOverlayForRegionWithLatitude(radius, latitude: location.coordinate.latitude, andLongitude: location.coordinate.longitude)
        }
    }
    
    
    func getMilesInView()->Float{
        
        var northEast : CLLocationCoordinate2D!
        var southWest : CLLocationCoordinate2D!
        
        northEast = map.convertPoint(CGPointMake(map.frame.size.width, 0), toCoordinateFromView: map)
        southWest = map.convertPoint(CGPointMake(0, map.frame.size.height), toCoordinateFromView: map)
        
        return Float( 69.172 * (northEast.latitude - southWest.latitude)) - 0.5
    }
    
    func dropPinAtLocation(location: CLLocation, title: String, subtitle: String, rideId: String){
        let dropPin = RideAnnotation(title: title, subtitle: subtitle, coordinate: location.coordinate, color: .Green, rideId: rideId)
        self.map.addAnnotation(dropPin)
        
        selectedTitle = title
        if(selectedAnnotation != nil){
            map.removeAnnotation(selectedAnnotation)
            map.addAnnotation(selectedAnnotation)
        }
        selectedAnnotation = dropPin
        map.selectAnnotation(dropPin, animated: true)
    }
    
    func setEvent(loc : CLLocation){
        eventLoc = loc
    }

    func selectRideButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        button.setTitle("Select", forState: .Normal)
        button.titleLabel?.font = UIFont(name: Config.fontBold, size: 18)
        button.setTitleColor(view.tintColor, forState: .Normal)
        return button
    }
    
    func findRideForAnnotation(ann : MKAnnotation)->Ride?{
        if let rAnn = ann as? RideAnnotation{
            for ride in rides{
                if (ride.id == rAnn.rideId){
                    return ride
                }
            }
        }
        
        return nil
    }
    
    @IBAction func bottomButtonPressed(sender: UIButton) {
        
        if (sender.titleForState(.Normal) == "Next"){
            index = index + 1
            if(index == rides.count){
                index = 0
            }
        }
        else{
            index = index - 1
            if(index == -1){
                index = rides.count - 1
            }
        }
        
        bottomLabel.setTitle("ride " + String(index + 1) + " of " + String(rides.count), forState: .Normal)
        let ride = rides[index]
        
        if(rideLocs[ride.id] != nil){
            currentLoc = rideLocs[ride.id]!
            
            centerMapOnLocation(rideLocs[ride.id]!, loadOverlay: true, radius: ride.radius)
            dropPinAtLocation(rideLocs[ride.id]!, title: ride.getCompleteAddress(), subtitle: ride.getMapSubtitle(), rideId:  ride.id)
            
            for an in map.annotations{
                self.mapView(map, viewForAnnotation: an)
            }
        }
        
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //completion?(location)
        
        
        
        if let ride = findRideForAnnotation(view.annotation!){
            self.selectedRide = ride
            self.performSegueWithIdentifier("joinRide", sender: self)
//            if let navigation = navigationController where navigation.viewControllers.count > 1 {
//                navigation.popViewControllerAnimated(true)
//            } else {
//                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//            }
        }
        
        
    }
    
  
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let ann = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        ann.userInteractionEnabled = true
        ann.canShowCallout = true
        
        
        switch annotation.title!!{
        case event.name:
            ann.pinColor = .Red
        case selectedTitle:
            ann.rightCalloutAccessoryView = selectRideButton()
            ann.rightCalloutAccessoryView?.userInteractionEnabled = true
            ann.pinColor = .Green
        default:
            ann.rightCalloutAccessoryView = selectRideButton()
            ann.rightCalloutAccessoryView?.userInteractionEnabled = true
            ann.pinColor = .Purple
        }
        
        
        
        return ann
    }
    
    func loadOverlayForRegionWithLatitude(radius: Int, latitude: Double, andLongitude longitude: Double) {
        
        //1
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //2
        let circle = MKCircle(centerCoordinate: coordinates, radius: (Double(radius) * metersInMile))
        //3
        //self.map.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        //4
        
        if(curOverlay != nil){
            self.map.removeOverlay(curOverlay!)
        }
        
        curOverlay = circle
        
        if(map != nil){
            self.map.addOverlay(circle)
        }
        
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "joinRide" {
            if let vc = segue.destinationViewController as? RideJoinViewController{
                vc.ride = self.selectedRide
                vc.event = self.event
                vc.rideVC = self.rideTVC
                vc.eventVC = self.eventVC
                vc.wasLinkedFromMap = true
                vc.wasLinkedFromEvents = (self.eventVC != nil)
            }
        }
    }
    

}
