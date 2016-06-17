//
//  RideAnnotation.swift
//  Cru
//
//  Created by Max Crane on 5/30/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MapKit

class RideAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let rideId: String
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, color: MKPinAnnotationColor, rideId: String)
    {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.rideId = rideId
        
        super.init()
    }
}
