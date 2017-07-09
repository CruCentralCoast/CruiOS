//
//  MinistryTeamCell.swift
//  Cru
//
//  Created by Tyler Dahl on 7/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

protocol MinistryTeamSignUpDelegate {
    func signUpForMinistryTeam(_ ministryTeam: MinistryTeam)
}

class MinistryTeamCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var leaderNamesLabel: UILabel!
    @IBOutlet weak var ministryNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    var delegate: MinistryTeamSignUpDelegate?
    
    var ministryTeam: MinistryTeam! {
        didSet {
            teamNameLabel.text = ministryTeam.ministryName
            descriptionLabel.text = ministryTeam.description
            
            if ministryTeam.imageUrl == "" {
                CruClients.getServerClient().getById(.Ministry, insert: { dict in
                    let ministry = Ministry(dict: dict)
                    self.ministryNameLabel.text = ministry.name
                }, completionHandler: { _ in }, id: ministryTeam.parentMinistry)
            } else {
                imageView.load.request(with: ministryTeam.imageUrl)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight]
        
        // Rounded corners
        self.layer.cornerRadius = 5
        self.signUpButton.layer.cornerRadius = 3
        
        //Add drop shadow
        self.backgroundView?.layer.shadowColor = UIColor.black.cgColor
        self.backgroundView?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.backgroundView?.layer.shadowOpacity = 0.25
        self.backgroundView?.layer.shadowRadius = 2
    }

    @IBAction func signUpPressed() {
        delegate?.signUpForMinistryTeam(self.ministryTeam)
    }
}
