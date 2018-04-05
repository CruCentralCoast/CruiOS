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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 20
    }

}
