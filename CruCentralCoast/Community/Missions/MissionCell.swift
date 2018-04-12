//
//  MissionCell.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 2/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MissionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var missionTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cellMask: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
