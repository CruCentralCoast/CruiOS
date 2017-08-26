//
//  ModalAnimationController.swift
//  Cru
//
//  Created by Tyler Dahl on 8/26/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

protocol ModalAnimationControllerDataSource: NSObjectProtocol {
    var percentCoveringView: CGFloat { get }
}

class ModalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var dataSource: ModalAnimationControllerDataSource!
    
    fileprivate var containerView: UIView!
    fileprivate var backgroundView: UIView!
    fileprivate var foregroundView: UIView!
    lazy fileprivate var maskView: UIView = {
        let view = UIView()
        view.frame = UIApplication.shared.keyWindow!.frame
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    /// The percentage of the background view that the modal should cover (from bottom to top)
    var percentCoveringView: CGFloat {
        return self.dataSource.percentCoveringView
    }
    
    let duration: TimeInterval = 1.0
    var isPresenting: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        self.backgroundView = self.isPresenting ? fromView : toView
        self.foregroundView = self.isPresenting ? toView : fromView
        
        // Make sure the mask and foreground views are on the context so they can be animated
        self.containerView.addSubview(self.maskView)
        self.containerView.addSubview(self.foregroundView)
        
        // Prepare the views for the transition
        self.setupTransition()
        
        // Perform the transition animations
        UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.isPresenting ? self.presentModal() : self.dismissModal()
        }) { completed in
            transitionContext.completeTransition(completed)
        }
    }
}

extension ModalAnimationController {
    fileprivate func setupTransition() {
        if !self.isPresenting { return }
        
        // Move modal offscreen
        self.foregroundView.frame.origin.y = self.containerView.frame.origin.y + self.containerView.frame.height
        self.maskView.alpha = 0
    }
    
    fileprivate func presentModal() {
        // Move modal onscreen
        let offset = self.containerView.frame.height * (1 - self.percentCoveringView)
        self.foregroundView.frame.origin.y = self.containerView.frame.origin.y + offset
        self.maskView.alpha = 1
    }
    
    fileprivate func dismissModal() {
        // Move modal offscreen
        self.foregroundView.frame.origin.y = self.containerView.frame.origin.y + self.containerView.frame.height
        self.maskView.alpha = 0
    }
}
