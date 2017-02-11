//
//  ModalMaximizedCardViewController.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/18/14.
//
//

import UIKit
import StoreKit

class StockMaximizedCardViewController: UIViewController, CardPhysicsDelegate, CardViewDelegate,UIViewControllerTransitioningDelegate, SKStoreProductViewControllerDelegate {
    
    var presentingCardView:CardView!
    var maximizedCard:Card!
    var maximizedCardView:CardView!
    var maximizedCardVisualSource:MaximizedCardViewVisualSource!
    
    var cardViewTopConstraint:NSLayoutConstraint?
    var cardViewBottomConstraint:NSLayoutConstraint?
    var cardViewLeftConstraint:NSLayoutConstraint?
    var cardViewRightConstraint:NSLayoutConstraint?
    
    var initialCardFrame:CGRect!
    var finishedLoadAnimation = false
    var currentOrientation:UIInterfaceOrientation!
    
    func cardViewRequestedAction(_ cardView: CardView, action: CardViewAction) {
        if(action.type == .collapse){
            // before collapse, re calc original frame
            initialCardFrame = self.view.convert(presentingCardView.frame, from: presentingCardView.superview)
        }
        handleCardAction(cardView, action: action)
    }
    
    // MARK:UIViewController
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maximizedCardView = CardView.createCardView(maximizedCard, visualSource: maximizedCardVisualSource, preferredWidth:UIViewNoIntrinsicMetric)
        maximizedCardView.delegate = self
        
        view.addSubview(maximizedCardView!)
        
        initialCardFrame = presentingViewController!.view.convert(presentingCardView.frame, from: presentingCardView.superview)
        
        //initiailize constraints
        cardViewLeftConstraint = maximizedCardView?.constrainLeftToSuperView(initialCardFrame.origin.x)
        cardViewTopConstraint = maximizedCardView?.constrainTopToSuperView(initialCardFrame.origin.y)
        cardViewRightConstraint = maximizedCardView?.constrainRightToSuperView(view.frame.size.width - initialCardFrame.origin.x - initialCardFrame.size.width)
        cardViewBottomConstraint = maximizedCardView?.constrainBottomToSuperView(view.frame.size.height - initialCardFrame.origin.y - initialCardFrame.size.height)
        maximizedCardView?.fadeOut(0, delay: 0, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!finishedLoadAnimation){
            maximizedCardView?.fadeIn(0.3, delay: 0, completion: nil)
            finishedLoadAnimation = true
        }
        
        currentOrientation = UIApplication.shared.statusBarOrientation
        NotificationCenter.default.addObserver(self, selector: #selector(StockMaximizedCardViewController.handleOrientationChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func handleOrientationChange(_ notification:Notification){
        if(UIApplication.shared.statusBarOrientation != currentOrientation){
            currentOrientation = UIApplication.shared.statusBarOrientation
            maximizedCardView?.reloadWithCard(maximizedCard, visualSource: maximizedCardVisualSource, preferredWidth:UIViewNoIntrinsicMetric)
            let destination = calculateMaximizedFrame()
            updateInternalCardConstraints(destination)
        }
    }
    
    func calculateMaximizedFrame() -> CGRect{
        // insets relative to the application frame
        let applicationInsets = maximizedCardVisualSource.applicationFrameEdgeInsets()
        let applicationFrame = UIScreen.main.applicationFrame
        
        // this is the card frame in the coordinate space of the application frame / main screen
        let cardFrame = CGRect(x: applicationFrame.origin.x + applicationInsets.left, y: applicationFrame.origin.y + applicationInsets.top, width: applicationFrame.width - applicationInsets.left - applicationInsets.right, height: applicationFrame.height - applicationInsets.top - applicationInsets.bottom)
        
        // convert to a rectangle in view controller space
        let rectConvert = view.convert(cardFrame, from: UIScreen.main.coordinateSpace)
        return rectConvert
    }
    
    func updateInternalCardConstraints(_ destination:CGRect){
        cardViewLeftConstraint?.constant = destination.origin.x
        cardViewTopConstraint?.constant = destination.origin.y
        cardViewRightConstraint?.constant = view.frame.size.width - destination.origin.x - destination.width
        cardViewBottomConstraint?.constant = view.frame.size.height - destination.origin.y - destination.height
        view.layoutIfNeeded()
    }
    
    // MARK: SKStoreProductViewControllerDelegate
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            let presentationController = StockMaximizedCardPresentationController(presentedViewController: presented, presenting: presenting)
            presentationController.presentingCardView = presentingCardView
            return presentationController
        }else{
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return StockMaximizedCardAnimationController(isPresenting: true)
        }else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return StockMaximizedCardAnimationController(isPresenting: false)
        }else {
            return nil
        }
    }
}
