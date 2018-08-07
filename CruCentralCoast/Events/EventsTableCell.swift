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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var imageCellView: UIImageView! //named imageCellView because imageView was already a variable name used by the tableView
    
    private var currentImageLink: String?
    @objc var event: Event! {
        didSet {
            self.dateLabel.text = event.startDate.toString(dateFormat: "MMM-dd-yyyy")
            self.titleLabel.text = self.event.title
            self.shortDescription.text = self.event.summary
            self.currentImageLink = self.event.imageLink
            self.imageCellView.image = nil
            // Try to download the image, but only display it if this cell has not been reused
            if let imageLink = self.event.imageLink {
                ImageManager.instance.fetch(imageLink) { [weak self] image in
                    if let currentImageLink = self?.currentImageLink, currentImageLink == imageLink {
                        DispatchQueue.main.async {
                            self?.imageCellView.image = image
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellMask.layer.cornerRadius = 20
        self.cellMask.layer.shadowColor = UIColor.black.cgColor
        self.cellMask.layer.shadowOpacity = 0.2 // used to be 0.2
        self.cellMask.layer.shadowOffset = CGSize.zero
        self.cellMask.layer.shadowRadius = 10 // used to be 6
        self.imageCellView.layer.cornerRadius = 20
        self.imageCellView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.imageCellView.layer.masksToBounds = true
        
        self.clipsToBounds = false
    }
}
