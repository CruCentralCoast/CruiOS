//
//  ProfileDetailCell.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfileDetailCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    func configure(with text: String) {
        self.label.text = text
    }
}
