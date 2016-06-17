//
//  RideTableViewCell.swift
//  Cru
//
//  Created by Max Crane on 2/3/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class RideTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rideType: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
