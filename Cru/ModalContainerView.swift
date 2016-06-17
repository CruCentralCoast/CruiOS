//
//  ModalContainerView.swift
//  Cru
//
//  Created by Deniz Tumer on 1/15/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ModalContainerView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
         self.layer.cornerRadius = 15.0
    }

}
