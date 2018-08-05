//
//  MinistryTeamCell.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 8/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MinistryTeamCell: UITableViewCell {

    @IBOutlet weak var cellMask: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
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

    func configure(with ministryTeam: MinistryTeam) {
        self.nameLabel.text = ministryTeam.name
        self.currentImageLink = ministryTeam.imageLink
        // Try to download the image, but only display it if this cell has not been reused
        if let imageLink = ministryTeam.imageLink {
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
