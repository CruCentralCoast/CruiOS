//
//  PlacePickerViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/16/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class PlacePickerViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    
    fileprivate var mapView: GMSMapView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var offerRideVC: NewOfferRideViewController?
    var editRideVC: NewDriverRideDetailViewController?
    var searchController: UISearchController?
    let locationManager = CLLocationManager()
    fileprivate let zoomLevel = Float(12)
    fileprivate let animationDuration = CFTimeInterval(30)
    fileprivate var isAnimating = false
    /// The coordinate to animate the map around
    var coordinate = CLLocationCoordinate2D(latitude: -33.8675, longitude: 151.2070) { // Sydney
        didSet {
            updateCoordinate()
        }
    }
    
    override func loadView() {
        mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.rotateGestures = true
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.userInteractionEnabled = false
        
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            
        }
        
        updateCoordinate()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let _ = self.searchController!.view
        
        
        /*let subView = UIView(frame: CGRectMake(0, 65.0, 350.0, 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        self.view.addSubview(subView)
        searchController?.searchBar.sizeToFit()*/
        
        // Put the search bar in the navigation bar.
        
        self.navigationItem.titleView = searchController?.searchBar
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        searchController?.searchBar.sizeToFit()
        
        
        resultsViewController?.primaryTextHighlightColor = CruColors.lightBlue
        resultsViewController?.tableCellBackgroundColor = UIColor(red: 76/225, green: 72/255, blue: 73/255, alpha: 1.0)
        resultsViewController?.primaryTextColor = UIColor.white.withAlphaComponent(0.7)
        resultsViewController?.secondaryTextColor = UIColor.white.withAlphaComponent(0.5)
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        searchController?.searchBar.barStyle = .blackTranslucent
        searchController?.searchBar.tintColor = UIColor.white
    }
    
    deinit {
        let _ = self.searchController!.view          // iOS 8
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        coordinate = locValue
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Implementation
    fileprivate func updateCoordinate() {
        if let mapView = mapView {
            // Start and stop the map animating if needed.
            let wasAnimating = isAnimating
            stopAnimatingMap()
            
            // Set the camera on the map to look at the specified coordinate.
            mapView.camera = GMSCameraPosition(target: coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
            
            if wasAnimating {
                startAnimatingMap()
            }
        }
    }
    
    fileprivate func startAnimatingMap() {
        
        isAnimating = true
        
        // Grab the last coordinate which the map was centered on.
        let lastCoordinate = mapView?.camera.target ?? coordinate
        
        // Generate a random lat,lng which is near to the specified coordinate.
        //
        // NOTE: This code is not the recommended way of picking a random coordinate, but for the
        // purposes of this demo it is sufficient. As the relationship between distance and latitude
        // varies over the surface of the earth, the amount of distance between the target coordinate
        // and the center coordinate will change significantly. Another example of how this is not
        // correct for most use-cases is that it does not handle the wrapping from -180° to +180°
        // which occurs at the antimeridian.
        let targetCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + randomOffset(),
                                                      longitude: coordinate.longitude + randomOffset())
        
        // Set the target coordinate on the map layer.
        mapView?.layer.cameraLatitude = targetCoordinate.latitude
        mapView?.layer.cameraLongitude = targetCoordinate.longitude
        
        // Setup two explicit animations to animate from the last coordinate to the target coordinate.
        // This has to be two animations as we have to manipulate latitude and longitude separately.
        // Use the duration we specified at the top of the file, and use a nice timing function to get
        // a smoother transition when we start/stop the animation.
        let latAnimation = CABasicAnimation(keyPath: kGMSLayerCameraLatitudeKey)
        latAnimation.fromValue = lastCoordinate.latitude
        latAnimation.toValue = targetCoordinate.latitude
        latAnimation.duration = animationDuration
        latAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let lngAnimation = CABasicAnimation(keyPath: kGMSLayerCameraLongitudeKey)
        lngAnimation.fromValue = lastCoordinate.longitude
        lngAnimation.toValue = targetCoordinate.longitude
        lngAnimation.duration = animationDuration
        lngAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Create an animation group for the two animations.
        let group = CAAnimationGroup()
        group.animations = [latAnimation, lngAnimation]
        group.duration = animationDuration
        // Set ourselves as the delegate so that we can continue with the next step in the animation
        // when this one is done.
        group.delegate = self
        
        // Start the animations.
        mapView?.layer.add(group, forKey: nil)
    }
    
    fileprivate func randomOffset() -> CLLocationDegrees {
        // Pick a random value from -0.05 to 0.05.
        return Double(arc4random()) / Double(UINT32_MAX) * 0.1 - 0.05
    }
    
    fileprivate func stopAnimatingMap() {
        isAnimating = false
        mapView?.layer.removeAllAnimations()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Start the animation again if we're still running it.
        if isAnimating {
            startAnimatingMap()
        }
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


// Handle the user's selection.
extension PlacePickerViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        
        self.coordinate = place.coordinate
        if offerRideVC != nil {
            offerRideVC?.pickedLocation = place
        }
        else if editRideVC != nil {
            editRideVC?.pickedLocation = place
        }
        
        let marker = GMSMarker(position: place.coordinate)
        marker.title = place.name
        marker.map = mapView
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "marker-icon")
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
