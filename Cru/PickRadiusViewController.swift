//
//  PickRadiusViewController.swift
//  Cru
//
//  Created by Max Crane on 5/9/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit

class PickRadiusViewController: UIViewController, MKMapViewDelegate {
    let metersInMile = 1609.344
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var radiusSlider: UISlider!
    var numMiles = 1
    var numMilesFloat: Float?
    var ride: Ride?
    var location: CLLocation?{
        didSet{
            if(map != nil){
                self.setupMap()
            }
        }
    }
    var curOverlay: MKOverlay?
    var setRadius: ((Int)->())?
    
    override func viewDidLoad() {
        numMiles = (ride?.radius)!
        numMilesFloat = Float((ride?.radius)!)
        radiusSlider.value = Float(numMiles)
        self.map.delegate = self
        if(numMiles == 1){
            radiusLabel.text = String(numMiles) + " mile"
        }
        else{
            radiusLabel.text = String(numMiles) + " miles"
        }
      
        while(location == nil){}
        setupMap()
        
        
    }
    
    @IBAction func okPressed(sender: AnyObject) {
        setRadius!(numMiles)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func radiusValChanged(sender: AnyObject) {
        
        if let slider = sender as? UISlider{
            numMiles = (Int(slider.value))
            numMilesFloat = slider.value
            if(numMiles == 1){
                radiusLabel.text = String(numMiles) + " mile"
            }
            else{
                radiusLabel.text = String(numMiles) + " miles"
            }
            if(location != nil){
                loadOverlayForRegionWithLatitude((location?.coordinate.latitude)!, andLongitude: (location?.coordinate.longitude)!)
            }
        }
    }
    
    func setupMap(){
        self.loadOverlayForRegionWithLatitude((self.location?.coordinate.latitude)!, andLongitude: (self.location?.coordinate.longitude)!)
        self.centerMapOnLocation(location!)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location!.coordinate
        dropPin.title = self.ride?.getCompleteAddress()
        self.map.addAnnotation(dropPin)
        
//        
//        var initialLocation = CLLocation()
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = ride!.getCompleteAddress()
//        
//   
//        let search = MKLocalSearch(request: request)
//        search.startWithCompletionHandler { (response, error) in
//            guard let response = response else {
//                return
//            }
//            
//            for item in response.mapItems {
//                initialLocation = item.placemark.location!
//                let dropPin = MKPointAnnotation()
//                dropPin.coordinate = initialLocation.coordinate
//                dropPin.title = self.ride?.getCompleteAddress()
//                self.location = initialLocation
//                
//                
//            }
//        }
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        print("Rendering now!")
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = CruColors.lightBlue.colorWithAlphaComponent(0.1)//UIColor.blueColor().colorWithAlphaComponent(0.1)
        circleRenderer.strokeColor = CruColors.darkBlue//UIColor.blueColor()
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    func centerMapOnLocation(location: CLLocation) {
        var regionRadius: CLLocationDistance = 500
        
        if(ride!.radius != 0){
            regionRadius = Double(numMilesFloat! * Float(metersInMile)) + 700
        }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
         regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
        map.reloadInputViews()
    }
    
    func loadOverlayForRegionWithLatitude(latitude: Double, andLongitude longitude: Double) {
        
        //1
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //2
        let circle = MKCircle(centerCoordinate: coordinates, radius: (Double(numMilesFloat!) * metersInMile))
        
        //3
        //self.map.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        //4
        
        if(curOverlay != nil){
            self.map.removeOverlay(curOverlay!)
            
        }
        
        
        curOverlay = circle
        
        if(map != nil){
            print("Map isn't nil anymore!")
            self.map.addOverlay(circle)
        }
        
        self.centerMapOnLocation(location!)
    }
    
    
    
}
