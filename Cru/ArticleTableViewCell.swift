//
//  ArticleTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    var tapAction: ((UITableViewCell) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    //Action that will use function passed at runtime
    @IBAction func readMore(_ sender: UIButton) {
        tapAction?(self)
    }
    
}
