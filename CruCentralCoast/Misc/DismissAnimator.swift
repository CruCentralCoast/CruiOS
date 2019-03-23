//
//  DismissAnimator.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 3/10/19.
//  Copyright © 2019 Landon Gerrits. All rights reserved.
//

import Foundation

import UIKit

class DismissAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        
        print("ANIMATING")
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {fromVC.view.frame = finalFrame},
                       completion: {_ in transitionContext.completeTransition(!transitionContext.transitionWasCancelled)})
        
    }
    
    
}

