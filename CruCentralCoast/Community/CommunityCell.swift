//
//  MinistryTeamCellCollectionViewCell.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cellMask: UIView!
    
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var smallLabel1: UILabel!
    @IBOutlet weak var smallLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                
        self.cellMask.layer.cornerRadius = 20
        self.cellMask.layer.shadowColor = UIColor.black.cgColor
        self.cellMask.layer.shadowOpacity = 0.2
        self.cellMask.layer.shadowOffset = CGSize.zero
        self.cellMask.layer.shadowRadius = 6
        
        self.imageView.layer.cornerRadius = 20
        self.imageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.clipsToBounds = false
    }

}
