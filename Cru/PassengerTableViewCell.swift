//
//  PassengerTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 2/17/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class PassengerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UITextView!
    @IBOutlet weak var dropButton: UIButton!
    var someColor : UIColor!
    var parentTable: PassengersViewController!
    var passenger: Passenger!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func dropPassengerSelected(sender: AnyObject) {
        if (dropButton.titleLabel?.text == "drop"){
            dropButton.setTitle("will drop", forState: .Normal)
            someColor = dropButton.backgroundColor
            dropButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            dropButton.backgroundColor = UIColor.redColor()
            parentTable.removePass(passenger)
            
        }
        else{
            dropButton.setTitle("drop", forState: .Normal)
            dropButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            dropButton.backgroundColor = someColor
            parentTable.reAddPass(passenger)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
