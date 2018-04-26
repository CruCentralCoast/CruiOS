//
//  EventDetailsVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var eventTitle: String?
    var eventDate: String?
    var eventLocation: String?
    var eventDesc: String?
    
    
    @IBAction func dismissDetail(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        self.presentAlert(title: "Link not set up yet!!", message: "Coming soon")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth = UIScreen.main.bounds.width
        widthConstraint.constant = screenWidth
        
        self.titleLabel.text = self.eventTitle
        self.dateLabel.text = self.eventDate
        self.locationLabel.text = self.eventLocation
        self.descriptionLabel.text = self.eventDesc
        
        self.imageView.image = #imageLiteral(resourceName: "night-at-the-oscars")
        // Do any additional setup after loading the view.
    }
    
    func configure(with cellParameters: EventCellParameters) {
        self.eventTitle = cellParameters.title
        self.eventDate = cellParameters.date
        self.eventLocation = cellParameters.location
        self.eventDesc = cellParameters.description
    }

}
