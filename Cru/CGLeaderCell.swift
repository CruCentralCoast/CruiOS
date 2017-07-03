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
    
    func setLeader(_ leader: CommunityGroupLeader) {
        name.text = leader.name
        let number = leader.phone
        phone.text = number
        email.text = leader.email
    }
    
}
