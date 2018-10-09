//
//  EventDetailsVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import EventKit //used for the add to calendar button
import SafariServices //used for the facebookButton
import MapKit

class EventDetailsVC: UIViewController {
    var event : Event?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    private var currentImageLink: String?
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.event?.title
        self.dateLabel.text = self.event?.startDate.toString(dateStyle: .medium, timeStyle: .none).uppercased()
        self.descriptionLabel.text = self.event?.summary
        self.locationButton.setTitle(self.event?.locationString, for: .normal)
        self.currentImageLink = self.event?.imageLink
        if let imageLink = self.event?.imageLink {
            ImageManager.instance.fetch(imageLink) { [weak self] image in
                if let currentImageLink = self?.currentImageLink, currentImageLink == imageLink {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func dismissDetail(_ sender: Any) {
        self.topConstraint.constant = -20
        closeButton.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        guard let eventLocation = self.event?.locationString else { return }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(eventLocation) { (placemarks, error) in
            guard let clPlacemark = placemarks?.first
            else {
                print("location not found")
                //handle no location found
                return
            }
            
            guard let lat = clPlacemark.location?.coordinate.latitude,
                let lon = clPlacemark.location?.coordinate.longitude
            else {
                return
            }
            
            let regionDistance: CLLocationDistance = 1000
            let coordinates = CLLocationCoordinate2DMake(lat, lon)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let mkPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: mkPlacemark)
//            mapItem.name = self.event?.locationString
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    //found at https://www.hackingwithswift.com/read/32/3/how-to-use-sfsafariviewcontroller-to-browse-a-web-page
    @IBAction func facebookButtonPressed(_ sender: Any) {
        guard let facebookURL = event?.facebookUrl else { return }
        
        if let url = URL(string: facebookURL) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            self.present(vc, animated: true)
        }
    }

    @IBAction func addToCalendarButtonPressed(_ sender: Any) {
        let eventStore: EKEventStore = EKEventStore()
        
        let event: EKEvent = EKEvent(eventStore: eventStore)
        event.title = self.event?.title
        event.startDate = self.event?.startDate
        event.endDate = self.event?.endDate
        event.notes = self.event?.description
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if let error = error {
                print(error)
                return
            }
            if !granted {
                print("Calender access denied.")
                return
            }
            do {
                try eventStore.save(event, span: .thisEvent)
                self.presentAlert(title: "Calendar", message: "Event Successfully added to calendar")
            } catch let error as NSError {
                print(error)
            }
            print("Save Event")
        }
    }
    
    func configure(with event: Event) {
        self.event = event
    }
}
