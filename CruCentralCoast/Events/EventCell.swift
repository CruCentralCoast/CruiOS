//
//  EventCell.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class EventCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cellMask: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    let screenPadding: CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenWidth = UIScreen.main.bounds.width
        
        widthConstraint.constant = screenWidth - screenPadding
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
