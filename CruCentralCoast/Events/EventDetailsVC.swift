//
//  EventDetailsVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import EventKit //used for the add to calendar button

struct EventCellParameters {
    let title : String
    let date : String
    let location : String
    let description : String
}

class EventDetailsVC: UIViewController {
    var event : Event?

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

    @IBAction func addToCalendarButtonPressed(_ sender: Any) {
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = self.event?.title
                event.startDate = self.event?.startDate
                if self.event?.endDate != nil {
                    event.endDate = self.event?.endDate
                }
                event.notes = self.event?.description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event,span: .thisEvent)
                } catch let error as NSError {
                    print("Error : \(error)")
                }
                print("Save Event")
            } else {
                print("error : \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.eventTitle
        self.dateLabel.text = self.eventDate
        self.locationLabel.text = self.eventLocation
        self.descriptionLabel.text = self.eventSummary
        self.imageView.image = self.eventImage
    }
    
    func configure(with cellParameters: Event) {
        self.event = cellParameters
        self.eventImage = cellParameters.image
        self.eventTitle = cellParameters.title
        self.eventDate = cellParameters.startDate.toString(dateFormat: "MMM-dd-yyyy")
        self.eventLocation = cellParameters.location
        self.eventSummary = cellParameters.summary
    }
}
