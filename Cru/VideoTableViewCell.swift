//
//  VideoTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 3/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import YouTubePlayer

class VideoTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var date: UILabel!

    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var stackLeadingSpace: NSLayoutConstraint!
    
    var videoURL: String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if desc.text == "" {
            desc.isHidden = true
            stackLeadingSpace.constant = 10.0
            
            /*for view in subviews  {
                if let text = view as? UITextView {
                    text.removeFromSuperview()
                }
            }
            
            let verticalConstraint = NSLayoutConstraint(item: date, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: title, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            
            self.contentView.addConstraint(verticalConstraint)*/
        }
        
    }
}
