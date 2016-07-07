//
//  MinistryTeamNoPictureTableViewCell.swift
//  Cru
//
//  Created by Deniz Tumer on 5/17/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamNoPictureTableViewCell: UITableViewCell {
    @IBOutlet weak var ministryTeamNameLabel: UILabel!
    @IBOutlet weak var ministryDescriptionLabel: UITextView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var ministryNameLabel: UILabel!
    @IBOutlet weak var card: UIView!
    
    var ministryTeam: MinistryTeam! {
        didSet {
            ministryTeamNameLabel.text = ministryTeam.ministryName
            ministryDescriptionLabel.text = ministryTeam.description
            
            CruClients.getServerClient().getById(.Ministry, insert: {
                dict in
                let ministry = Ministry(dict: dict)
                self.ministryNameLabel.text = ministry.name
                }, completionHandler: {_ in }, id: ministryTeam.parentMinistry)
        }
    }
}
