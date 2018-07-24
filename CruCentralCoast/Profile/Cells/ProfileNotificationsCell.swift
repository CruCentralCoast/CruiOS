//
//  ProfileNotificationsCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfileNotificationsCell: UITableViewCell {
    
    @IBOutlet weak var notificationsNumberLabel: UILabel!
    @IBOutlet weak var notificationNumberContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.notificationNumberContainerView.layer.cornerRadius = self.notificationNumberContainerView.frame.height/2
        self.notificationNumberContainerView.clipsToBounds = true
    }
    
}
