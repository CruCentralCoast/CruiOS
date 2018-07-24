//
//  CommunityTableViewCell.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMask: UIView!
    @IBOutlet weak var bannerImage: UIImageView!
    
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var smallLabel1: UILabel!
    @IBOutlet weak var smallLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    
        self.cellMask.layer.cornerRadius = 20
        self.cellMask.layer.shadowColor = UIColor.black.cgColor
        self.cellMask.layer.shadowOpacity = 0.1
        self.cellMask.layer.shadowOffset = CGSize.zero
        self.cellMask.layer.shadowRadius = 10
    
        self.bannerImage.layer.cornerRadius = 20
        self.bannerImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.bannerImage.clipsToBounds = true
    
        self.cellMask.clipsToBounds = false
        
        
    }
    
}
