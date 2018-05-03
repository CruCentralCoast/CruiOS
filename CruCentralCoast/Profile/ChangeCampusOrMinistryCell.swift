//
//  ChangeCampusOrMinistryCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ChangeCampusOrMinistryCell: UICollectionViewCell {

    @IBOutlet weak var campusImage: UIImageView!
    @IBOutlet weak var campusNameLabel: UILabel!
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 2
    }
    
    func toggleCheckMark() {
        self.checkMarkImage.isHidden = !self.checkMarkImage.isHidden
    }
}
