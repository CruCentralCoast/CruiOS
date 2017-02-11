//
//  CGLeaderCell.swift
//  Cru
//
//  Created by Peter Godkin on 5/26/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CGLeaderCell: UITableViewCell {
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var email: UITextView!
    @IBOutlet weak var phone: UITextView!
    
    func setUser(_ user: User) {
        name.text = user.name
        let number = user.phone
        phone.text = number
        email.text = user.email
    }
    
}
