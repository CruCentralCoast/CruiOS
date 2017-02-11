//
//  MinistryTableViewCell.swift
//  Cru
//
//  Created by Deniz Tumer on 1/28/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTableViewCell: UITableViewCell {

    //Properties
    //Label for ministry name
    @IBOutlet weak var ministryNameLabel: UILabel!
    //Image for ministry image
    @IBOutlet weak var minstryImage: UIImageView!
    
    var ministry: Ministry! {
        didSet{
            ministryNameLabel.text = ministry.name
            ministryNameLabel.textColor = Config.introModalContentTextColor
            if (ministry.imageUrl != nil) {
                minstryImage.load.request(with: ministry.imageUrl)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
