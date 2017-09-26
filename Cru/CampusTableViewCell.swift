//
//  CampusTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 9/15/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CampusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var campusImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var imageUrl: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
