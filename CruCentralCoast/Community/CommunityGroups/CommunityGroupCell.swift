//
//  CommunityGroupCell.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityGroupCell: UITableViewCell {

    @IBOutlet weak var cellMask: UIView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    private var currentImageLink: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with communityGroup: CommunityGroup) {
        self.genderLabel.text = communityGroup.gender.rawValue.uppercased()
        self.timeLabel.text = communityGroup.time 
        self.nameLabel.text = communityGroup.name
        self.currentImageLink = communityGroup.imageLink
        self.yearLabel.text = communityGroup.year.rawValue.uppercased()
    }
        
//        // TODO: image dowload handling once we're ready to handle leader images
//        self.setImageVisibility(communityGroup.imageLink != nil && !communityGroup.imageLink!.isEmpty)
//        // Try to download the image, but only display it if this cell has not been reused
//        if let imageLink = communityGroup.imageLink {
//            ImageManager.instance.fetch(imageLink) { [weak self] image in
//                if let currentImageLink = self?.currentImageLink, currentImageLink == imageLink {
//                    DispatchQueue.main.async {
//                        self?.bannerImageView.image = image
//                    }
//                }
//            }
//        }
//    }
//
//    private func setImageVisibility(_ isVisible: Bool) {
//        if isVisible {
//            // If image size constraint doesn't exist, recreate it
//            if self.imageViewAspectRatioConstraint == nil {
//                self.imageViewAspectRatioConstraint = NSLayoutConstraint(item: self.bannerImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.bannerImageView, attribute: NSLayoutAttribute.height, multiplier: 16/9, constant: 1)
//                self.imageViewAspectRatioConstraint.isActive = true
//            }
//        } else {
//            // If image size constraint exists, remove it
//            if self.imageViewAspectRatioConstraint != nil {
//                self.imageViewAspectRatioConstraint.isActive = false
//            }
//        }
//    }
}
