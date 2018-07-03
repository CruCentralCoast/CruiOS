//
//  EventDetailsVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import EventKit

struct EventCellParameters {
    let title : String
    let date : String
    let location : String
    let description : String
}

class EventDetailsVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var eventTitle: String?
    var eventDate: String?
    var eventLocation: String?
    var eventSummary: String?
    var eventImage: UIImage?
    
    var statusBarIsHidden: Bool = true {
        didSet{
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        get {
            return self.statusBarIsHidden
        }
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    @IBAction func dismissDetail(_ sender: Any) {
        self.statusBarIsHidden = false
        self.topConstraint.constant = -20
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        self.presentAlert(title: "Link not set up yet!!", message: "Coming soon")
    }

    /* future function for calendar button on events Details Screen
    @IBAction func calendarButtonPressed(_ sender: Any) {
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = self.titleLabel.text
            }
            
        })
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.eventTitle
        self.dateLabel.text = self.eventDate
        self.locationLabel.text = self.eventLocation
        self.descriptionLabel.text = self.eventSummary
        self.imageView.image = self.eventImage
    }
    
    func configure(with cellParameters: Event) {
        self.eventImage = cellParameters.image
        self.eventTitle = cellParameters.title
        self.eventDate = cellParameters.startDate.toString(dateFormat: "MMM-dd-yyyy")
        self.eventLocation = cellParameters.location
        self.eventSummary = cellParameters.summary
    }
}
