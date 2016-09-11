//
//  CheckboxButton.swift
//  Cru
//
//  Created by Erica Solum on 9/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CheckboxButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    //MARK: Properties
    let checkedImage = UIImage(named: "tag-checked")
    let uncheckedImage = UIImage(named: "tag-unchecked")
    
    var isChecked = true {
        didSet {
            if isChecked {
                UIView.animateWithDuration(0.25, animations: {
                    self.setImage(self.checkedImage, forState: .Normal)
                })
                
            }
            else {
                UIView.animateWithDuration(0.25, animations: {
                    self.setImage(self.uncheckedImage, forState: .Normal)
                })
                
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
        isChecked = true
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked {
                isChecked = false
            }
            else {
                isChecked = true
            }
        }
    }
    
}
