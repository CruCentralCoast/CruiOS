//
//  LocationViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/22/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var initLocation: CLLocation?
    let regionRadius: CLLocationDistance = 1000
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set initial location in Honolulu
        if initLocation != nil {
            initLocation = CLLocation(latitude: 35.282752, longitude: -120.659616)
        }
       
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
