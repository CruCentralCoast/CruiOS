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
                UIView.animate(withDuration: 0.25, animations: {
                    self.setImage(self.checkedImage, for: UIControlState())
                })
                
            }
            else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.setImage(self.uncheckedImage, for: UIControlState())
                })
                
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        isChecked = true
    }
    
    func buttonClicked(_ sender: UIButton) {
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
