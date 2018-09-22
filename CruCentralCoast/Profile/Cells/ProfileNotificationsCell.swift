//
//  ProfileNotificationsCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfileNotificationsCell: UITableViewCell {
    
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var notificationCountContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.notificationCountContainerView.layer.cornerRadius = self.notificationCountContainerView.frame.height/2
        self.notificationCountContainerView.clipsToBounds = true
    }
    
    func configure(with notificationCount: Int) {
        self.notificationCountLabel.text = "\(notificationCount)"
        self.notificationCountContainerView.isHidden = notificationCount == 0
    }
}
