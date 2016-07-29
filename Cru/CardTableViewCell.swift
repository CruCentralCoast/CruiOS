//
//  CardTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 2/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    // MARK: Properties
    /*@IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cardView: UIView! */
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var descView: UITextView!
    @IBOutlet weak var sourceLogo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    // MARK: Functions
    func cardSetup() {
        //Set up the shadows of the card and set the image boundaries
        /*let path = UIBezierPath.init(rect: cardView.bounds)
        
        cardView.alpha = 1
        cardView.layer.masksToBounds = false
        cardView.layer.shadowOffset = CGSizeMake(-0.2, 0.2)
        cardView.layer.shadowRadius = 1
        
        cardView.layer.shadowPath = path.CGPath
        cardView.layer.shadowOpacity = 0.2
        
        cardImage.contentMode = UIViewContentMode.ScaleAspectFit
        cardImage.clipsToBounds = true
        */
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set up the card's layout 
        cardSetup()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
