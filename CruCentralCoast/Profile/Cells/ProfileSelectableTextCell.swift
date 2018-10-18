//
//  ProfileLoginLogoutCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfileSelectableTextCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with text: String?) {
        self.titleLabel.text = text
    }
}
