//
//  ProfileEmailCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileEmailCell: UITableViewCell {

    @IBOutlet weak var emailLabel: UILabel!
    
    func configure(with user: User?) {
        if user == nil {
            self.emailLabel.text = "someone@me.com"
        } else {
            self.emailLabel.text = user?.email ?? user?.providerData[0].email ?? "N/A"
        }
    }
}
