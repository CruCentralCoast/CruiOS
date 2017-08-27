//
//  ModalTransitionController.swift
//  Cru
//
//  Created by Tyler Dahl on 8/26/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ModalTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    weak var animationDataSource: ModalAnimationControllerDataSource?
    
    lazy var animationController: ModalAnimationController = {
        let controller = ModalAnimationController()
        controller.dataSource = self.animationDataSource
        return controller
    }()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationController.isPresenting = true
        return self.animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationController.isPresenting = false
        return self.animationController
    }
}
