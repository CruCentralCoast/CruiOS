//
//  MissionCell.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 8/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MissionCell: UITableViewCell {

    @IBOutlet weak var cellMask: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var currentImageLink: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellMask.layer.cornerRadius = 20
        self.cellMask.layer.shadowColor = UIColor.black.cgColor
        self.cellMask.layer.shadowOpacity = 0.2
        self.cellMask.layer.shadowOffset = CGSize.zero
        self.cellMask.layer.shadowRadius = 10
        self.bannerImageView.layer.cornerRadius = 20
        self.bannerImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.bannerImageView.layer.masksToBounds = true
    }
    
    func configure(with mission: Mission) {
        self.dateLabel.text = (mission.startDate.toString(dateStyle: .medium, timeStyle: .none) + " - " + mission.endDate.toString(dateStyle: .medium, timeStyle: .none)).uppercased()
        self.nameLabel.text = mission.name
        self.currentImageLink = mission.imageLink
        // Try to download the image, but only display it if this cell has not been reused
        if let imageLink = mission.imageLink {
            ImageManager.instance.fetch(imageLink) { [weak self] image in
                if let currentImageLink = self?.currentImageLink, currentImageLink == imageLink {
                    DispatchQueue.main.async {
                        self?.bannerImageView.image = image
                    }
                }
            }
        }
    }
}
