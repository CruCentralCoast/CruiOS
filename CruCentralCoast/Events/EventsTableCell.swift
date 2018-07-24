//
//  EventsTableCell.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@objc class EventsTableCell: UITableViewCell {
    
    @IBOutlet weak var cellMask: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageCellView: UIImageView! //named imageCellView because imageView was already a variable name used by the tableView
    @objc var event: Event! {
        didSet {
            self.dateLabel.text = event.startDate.toString(dateFormat: "MMM-dd-yyyy")
            self.descriptionLabel.text = self.event.title
            self.imageCellView.image = self.event.image
            self.locationLabel.text = self.event.locationButtonTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellMask.layer.cornerRadius = 20
        self.cellMask.layer.shadowColor = UIColor.black.cgColor
        self.cellMask.layer.shadowOpacity = 0.2
        self.cellMask.layer.shadowOffset = CGSize.zero
        self.cellMask.layer.shadowRadius = 6
        self.imageCellView.layer.cornerRadius = 20
        self.imageCellView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.imageCellView.layer.masksToBounds = true
        
        self.clipsToBounds = false
    }
}
