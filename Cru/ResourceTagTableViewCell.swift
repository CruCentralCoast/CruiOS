//
//  ResourceTagTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 9/11/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ResourceTagTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var checkbox: CheckboxButton!
    
    @IBOutlet weak var title: UILabel!
    var resourceTag = ResourceTag()!
    
    //MARK: Actions
    
    @IBAction func buttonTapped(_ sender: CheckboxButton) {
        if sender.isChecked == true{
            setUnchecked()
        }
        else {
            setChecked()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print("Selected cell in cell class")
        // Configure the view for the selected state
    }
    
    //Sets the text color of the label to light blue
    func setChecked() {
        self.resourceTag.selected = true
        UIView.transition(with: title, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.title.textColor = CruColors.lightBlue
            }, completion: nil)
        
    }
    
    //Sets the text color of the label to gray
    func setUnchecked() {
        self.resourceTag.selected = false
        UIView.transition(with: title, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.title.textColor = CruColors.gray
            }, completion: nil)
    }
    

}
