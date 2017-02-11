//
//  StockModalCardViewController.swift
//  WildcardSDKProject
//
//  Created by Lacy Rhoades on 10/7/15.
//

import Foundation

class StockModalCardViewController: UIViewController, UIViewControllerTransitioningDelegate, CardViewDelegate, CardPhysicsDelegate {
    var backgroundView: UIView!
    var presentedCard: Card!
    var cardVisualSource: CardViewVisualSource!
    
    var cardView: CardView!
    var cardViewVerticalConstraint: NSLayoutConstraint!
    var cardViewHorizontalConstraint: NSLayoutConstraint!
    
    var closeButton: UIButton!
    var closeButtonTopConstraint: NSLayoutConstraint!
    var currentOrientation: UIInterfaceOrientation!
    var initialOrientation: UIInterfaceOrientation!
    
    override func viewDidLoad() {
        backgroundView = UIView(frame:CGRect.zero)
        let tap = UITapGestureRecognizer(target: self, action: #selector(StockModalCardViewController.dismiss as (StockModalCardViewController) -> () -> ()))
        backgroundView.addGestureRecognizer(tap)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)
        
        cardView = CardView.createCardView(presentedCard, visualSource: cardVisualSource, preferredWidth:UIViewNoIntrinsicMetric)
        cardView.delegate = self
        cardView.physics?.enableDragging = true
        cardView.physics?.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cardView)
        
        cardViewVerticalConstraint = NSLayoutConstraint(item: cardView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        self.view.addConstraint(cardViewVerticalConstraint)
        cardViewHorizontalConstraint = NSLayoutConstraint(item: cardView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        self.view.addConstraint(cardViewHorizontalConstraint)
        
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage.loadFrameworkImage("closeIcon"), for: UIControlState())
        closeButton.tintColor = UIColor.white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        closeButtonTopConstraint = NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        self.view.addConstraint(closeButtonTopConstraint)
        
        closeButton.addTarget(self, action: #selector(StockModalCardViewController.dismiss as (StockModalCardViewController) -> () -> ()), for: .touchUpInside)
        
        self.handleOrientationChange(Notification(name: Notification.Name(rawValue: ""), object: nil))
        initialOrientation = currentOrientation
        
        let metrics = ["margin": 10];
        
        let views = ["cardView": cardView, "backgroundView": backgroundView];
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: [], metrics: metrics, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: metrics, views: views))
        
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 50))
        self.view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 50))
    }
    
    func dismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(StockModalCardViewController.handleOrientationChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func handleOrientationChange(_ notification:Notification){
        if(UIApplication.shared.statusBarOrientation != currentOrientation){
            currentOrientation = UIApplication.shared.statusBarOrientation
            
            if(UIApplication.shared.isStatusBarHidden){
                closeButtonTopConstraint.constant = 0
            }else{
                closeButtonTopConstraint.constant = 15
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return StockModalCardPresentationController(presentedViewController: presented, presenting: presenting)
        }else{
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented == self {
            return StockModalCardAnimationController(isPresenting: true)
        }else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return StockModalCardAnimationController(isPresenting: false)
        }else {
            return nil
        }
    }
    
    func cardViewRequestedAction(_ cardView: CardView, action: CardViewAction) {
        handleCardAction(cardView, action: action)
    }
    
    func cardViewDropped(_ cardView: CardView, position: CGPoint) {
        // check if the card view has been dragged "out of bounds" in the view controller view(10% of edges)
        let viewBounds = view.bounds
        
        let horizontalThreshold = 0.10 * viewBounds.width
        let verticalThreshold = 0.10 * viewBounds.height
        
        // move left, right, up, or down
        if(position.x < horizontalThreshold){
            UIView.animate(withDuration: 0.3, delay: 0.05, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                if let constraint =  self.cardViewHorizontalConstraint {
                    constraint.constant = constraint.constant - viewBounds.width
                    self.view.layoutIfNeeded()
                }
                }) { (bool:Bool) -> Void in
                    cardView.removeFromSuperview()
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }else if(position.x > (view.bounds.width - horizontalThreshold)){
            UIView.animate(withDuration: 0.3, delay: 0.05, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                if let constraint = self.cardViewHorizontalConstraint {
                    constraint.constant = constraint.constant + viewBounds.width
                    self.view.layoutIfNeeded()
                }
                }) { (bool:Bool) -> Void in
                    cardView.removeFromSuperview()
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }else if(position.y < verticalThreshold){
            UIView.animate(withDuration: 0.3, delay: 0.05, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                if let constraint =  self.cardViewVerticalConstraint{
                    constraint.constant = constraint.constant - viewBounds.height
                    self.view.layoutIfNeeded()
                }
                }) { (bool:Bool) -> Void in
                    cardView.removeFromSuperview()
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }else if(position.y > (view.bounds.height - verticalThreshold)){
            UIView.animate(withDuration: 0.3, delay: 0.05, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                if let constraint = self.cardViewVerticalConstraint{
                    constraint.constant = constraint.constant + viewBounds.height
                    self.view.layoutIfNeeded()
                }
                }) { (bool:Bool) -> Void in
                    cardView.removeFromSuperview()
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }else{
            cardView.physics?.panGestureReset()
        }
    }
}
