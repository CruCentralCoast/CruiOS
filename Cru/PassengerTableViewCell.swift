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

    @IBAction func dropPassengerSelected(_ sender: AnyObject) {
        if (dropButton.titleLabel?.text == "drop"){
            dropButton.setTitle("will drop", for: UIControlState())
            someColor = dropButton.backgroundColor
            dropButton.setTitleColor(UIColor.black, for: UIControlState())
            dropButton.backgroundColor = UIColor.red
            parentTable.removePass(passenger)
            
        }
        else{
            dropButton.setTitle("drop", for: UIControlState())
            dropButton.setTitleColor(UIColor.red, for: UIControlState())
            dropButton.backgroundColor = someColor
            parentTable.reAddPass(passenger)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
