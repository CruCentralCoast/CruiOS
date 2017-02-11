//
//  CustomPresentAnimationController.swift
//  Cru
//
//  Created by Erica Solum on 9/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CustomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        let animationDuration = self .transitionDuration(using: transitionContext)
        
        let snapshotView = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        snapshotView?.center = toViewController.view.center
        containerView.addSubview(snapshotView!)
        
        fromViewController.view.alpha = 0.0
        
        let toViewControllerSnapshotView = toViewController.view.resizableSnapshotView(from: toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        containerView.insertSubview(toViewControllerSnapshotView!, belowSubview: snapshotView!)
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            //snapshotView.transform = CGAffineTransformMakeScale(0.1, 0.1)
            //snapshotView.alpha = 0.0
            snapshotView?.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width/2 - 200, y: 0)
        }, completion: { (finished) -> Void in
            toViewControllerSnapshotView?.removeFromSuperview()
            snapshotView?.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
}
