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
    
    @IBAction func buttonTapped(sender: CheckboxButton) {
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Sets the text color of the label to light blue
    func setChecked() {
        UIView.transitionWithView(title, duration: 0.25, options: .TransitionCrossDissolve, animations: {
            self.title.textColor = CruColors.lightBlue
            }, completion: nil)
        
    }
    
    //Sets the text color of the label to gray
    func setUnchecked() {
        UIView.transitionWithView(title, duration: 0.25, options: .TransitionCrossDissolve, animations: {
            self.title.textColor = CruColors.gray
            }, completion: nil)
    }
    

}
