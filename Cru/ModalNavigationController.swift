//
//  ModalNavigationController.swift
//  Cru
//
//  Created by Tyler Dahl on 8/26/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController, ModalAnimationControllerDataSource {
    
    var percentCoveringView: CGFloat = 0.7
    
    lazy fileprivate var modalTransitionController: ModalTransitionController = {
        let controller = ModalTransitionController()
        controller.animationDataSource = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round top left and right corners
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: self.view.frame, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.view.layer.mask = mask
        
        // Configure presentation style
        self.modalPresentationStyle = .overCurrentContext
        self.transitioningDelegate = self.modalTransitionController
    }
}
