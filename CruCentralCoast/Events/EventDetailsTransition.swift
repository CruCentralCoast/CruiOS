//
//  EventDetailsTransition.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import UIKit

class EventDetailsTransition : NSObject, UIViewControllerAnimatedTransitioning {
    private let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        let detailView = presenting ? toView : fromView
        
        containerView.addSubview(toView!)
        containerView.addSubview(detailView!)
        
        guard let initialFrame = presenting ? originFrame : detailView?.frame else {
            return
        }
        guard let finalFrame = presenting ? detailView?.frame : originFrame else {
            return
        }
        
        if presenting {
            detailView?.frame.size.height = (initialFrame.height)
            detailView?.frame.size.width = (initialFrame.width)
            detailView?.center = CGPoint(x: (initialFrame.midX), y: (initialFrame.midY))
            detailView?.clipsToBounds = true
            detailView?.layer.cornerRadius = 20
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            detailView?.frame.size.height = finalFrame.height
            detailView?.frame.size.width = finalFrame.width
            detailView?.center = CGPoint(x: (finalFrame.midX), y: (finalFrame.midY))
            if self.presenting {
                detailView?.layer.cornerRadius = 0
            } else {
                detailView?.layer.cornerRadius = 20
            }
            detailView?.superview?.layoutIfNeeded()
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
