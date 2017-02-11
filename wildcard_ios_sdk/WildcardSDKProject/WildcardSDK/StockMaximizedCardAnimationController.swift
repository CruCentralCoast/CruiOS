//
//  StockMaximizedCardAnimationController.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/19/14.
//
//

import Foundation
import UIKit

class StockMaximizedCardAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    
    let isPresenting :Bool
    let duration :TimeInterval = 0.4
    
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
    
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let maximizedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! StockMaximizedCardViewController
        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let containerView = transitionContext.containerView
        
        let rectConvert = maximizedController.calculateMaximizedFrame()
    
        containerView.addSubview(presentedControllerView)
  
        maximizedController.view.layoutIfNeeded()
        let originalShadowOpacity = maximizedController.maximizedCardView.layer.shadowOpacity
        maximizedController.maximizedCardView.layer.shadowOpacity = 0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
    
            // move card to maximized constraints
            maximizedController.updateInternalCardConstraints(rectConvert)
            
            }, completion: {(completed: Bool) -> Void in
                maximizedController.maximizedCardView.layer.shadowOpacity = originalShadowOpacity
                transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let maximizedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! StockMaximizedCardViewController

        maximizedController.maximizedCardView?.fadeOut(duration/2, delay: 0, completion: nil)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            // move card back to initial constraints
            maximizedController.updateInternalCardConstraints(maximizedController.initialCardFrame)
        
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
}
