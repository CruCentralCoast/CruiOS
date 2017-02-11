//
//  StockModalCardAnimationController.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/19/14.
//
//

import UIKit

class StockModalCardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting :Bool
    let duration :TimeInterval = 0.5
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
   
    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)  {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        }else{
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    // MARK: Private
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            let center = presentedView.center
            presentedView.center = CGPoint(x: center.x, y: -presentedView.bounds.size.height)
            transitionContext.containerView.addSubview(presentedView)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut,
                animations: {
                    presentedView.center = center
                }, completion: {
                    (completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        
        if let stockModalController = presentedController as? StockModalCardViewController{
            // move card up and out
            if(stockModalController.cardView != nil){
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    stockModalController.closeButton.alpha = 0
                    stockModalController.cardViewVerticalConstraint!.constant = -presentedControllerView.frame.size.height
                    stockModalController.view.layoutIfNeeded()
                    }, completion: {(completed: Bool) -> Void in
                        transitionContext.completeTransition(completed)
                })
            }
        }
     
    }
}
