//
//  CommunityGroupTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 7/2/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var ministryLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
