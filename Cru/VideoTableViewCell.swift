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
        
        //Customize image thumbnail
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.layer.masksToBounds = true
        
        if desc.text == "" {
            desc.isHidden = true
            stackLeadingSpace.constant = 10.0
            
        }
        
    }
}
