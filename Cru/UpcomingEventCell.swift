//
//  UpcomingEventCell.swift
//  Cru
//
//  Created by Erica Solum on 6/28/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class UpcomingEventCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var location: UITextView!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var AMorPM: UILabel!
    @IBOutlet weak var dayAlignment: NSLayoutConstraint!
    
    @IBOutlet weak var nameSpacer: NSLayoutConstraint!
    
    @IBOutlet weak var card: UIView!
}