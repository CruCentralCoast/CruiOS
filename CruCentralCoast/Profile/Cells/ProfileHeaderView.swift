//
//  ProfileHeaderView.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        self.imageView.clipsToBounds = true
    }
    
    func configure(with user: User?) {
        if user == nil {
            self.imageView.image = #imageLiteral(resourceName: "profile_icon")
            self.nameLabel.text = "Guest"
        } else {
            self.imageView.downloadedFrom(url: user?.photoURL)
            self.nameLabel.text = user?.displayName
        }
    }
}
