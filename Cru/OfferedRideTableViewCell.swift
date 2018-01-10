//
//  OfferedRideTableViewCell.swift
//  Cru
//
//  Created by Max Crane on 2/17/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class OfferedRideTableViewCell: UITableViewCell {
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var seatsLeft: UILabel!
    
    var ride: Ride? {
        didSet {
            if let ride = self.ride {
                self.month.text = ride.month
                self.day.text = String(ride.day)
                self.time.text = GlobalUtils.stringFromDate(ride.date, format: "h:mma")
                self.seatsLeft.text = ride.seatsLeftAsString() + " seats left"
                
                if ride.seatsLeft() == 1 {
                    self.seatsLeft.textColor = UIColor(red: 0.729, green: 0, blue: 0.008, alpha: 1.0)
                } else if ride.seatsLeft() == 2 {
                    self.seatsLeft.textColor = UIColor(red: 0.976, green: 0.714, blue: 0.145, alpha: 1.0)
                } else {
                    self.seatsLeft.textColor = UIColor(red: 0, green:  0.427, blue: 0.118, alpha: 1.0)
                }
            }
        }
    }
}
