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
    @IBOutlet weak var imageCellView: UIImageView!
    @objc var event: Event! {
        didSet {
            let dateFormatter = DateFormatter()
            self.dateLabel.text = dateFormatter.string(for: self.event.startDate)
            self.descriptionLabel.text = self.event.title
            self.imageCellView.image = self.event.image
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
