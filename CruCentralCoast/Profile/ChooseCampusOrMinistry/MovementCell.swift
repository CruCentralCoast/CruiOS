//
//  MovementCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 7/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MovementCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with movement: Movement, subscriptionStatus: Bool) {
        self.accessoryType = subscriptionStatus ? .checkmark : .none
        self.titleLabel.text = movement.name
    }
}
