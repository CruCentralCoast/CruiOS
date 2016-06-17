//
//  MinistryTeamsTableViewCell.swift
//  Cru
//
//  Created by Deniz Tumer on 5/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamsTableViewCell: UITableViewCell {
    @IBOutlet weak var ministryTeamImage: UIImageView!
    @IBOutlet weak var ministryTeamName: UILabel!
    @IBOutlet weak var ministryTeamDescription: UITextView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var ministryNameLabel: UILabel!
    
    var ministryTeam: MinistryTeam! {
        didSet {
            ministryTeamImage.load(ministryTeam.imageUrl)
            ministryTeamName.text = ministryTeam.ministryName
            ministryTeamDescription.text = ministryTeam.description
        }
    }
}
