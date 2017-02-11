//
//  CardPhysics.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/10/14.
//
//

import UIKit

@objc
public protocol CardPhysicsDelegate{
    @objc optional func cardViewDragged(_ cardView:CardView, position:CGPoint)
    @objc optional func cardViewDropped(_ cardView:CardView, position:CGPoint)
    @objc optional func cardViewTapped(_ cardView:CardView)
    @objc optional func cardViewDoubleTapped(_ cardView:CardView)
}

@objc
open class CardPhysics : NSObject {
    
    // MARK: Public properties
    open var cardView:CardView
    open var delegate:CardPhysicsDelegate?

    /// Adds a pan gesture onto the card view which enables it to be dragged around the screen
    open var enableDragging: Bool {
        get {
            return cardPanGestureRecognizer != nil
        }
        set(bool) {
            if(bool){
                cardPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CardPhysics.cardPanned(_:)))
                cardView.addGestureRecognizer(cardPanGestureRecognizer!)
                originalPosition = cardView.center
            }else{
                if let gesture = cardPanGestureRecognizer{
                    cardView.removeGestureRecognizer(gesture)
                    cardPanGestureRecognizer = nil
                }
            }
        }
    }
    
    // MARK: Private properties
    var flipBoolean = false
    var cardPanGestureRecognizer:UIPanGestureRecognizer?
    var cardDoubleTapGestureRecognizer:UITapGestureRecognizer?
    var cardTapGestureRecognizer:UITapGestureRecognizer?
    var touchPosition:CGPoint = CGPoint.zero
    var originalPosition:CGPoint = CGPoint.zero
    
    // MARK: Initializers
    init(cardView:CardView){
        self.cardView = cardView
    }
    
    // MARK: Gesture Handlers
    func cardPanned(_ recognizer:UIPanGestureRecognizer!){
        if recognizer.state == UIGestureRecognizerState.began{
            self.cardView.layer.removeAllAnimations()
            touchPosition = recognizer.translation(in: cardView.superview!)
        }else if(recognizer.state == UIGestureRecognizerState.changed){
            let currentLocation = recognizer.translation(in: cardView.superview!)
            let dx = currentLocation.x - touchPosition.x
            let dy = currentLocation.y - touchPosition.y
            
            moveByAmount(CGPoint(x: dx, y: dy))
            
            let finalX = dx + originalPosition.x
            let finalY = dy + originalPosition.y
            delegate?.cardViewDragged?(cardView, position: CGPoint(x: finalX, y: finalY))
            
        }else if(recognizer.state == UIGestureRecognizerState.ended){
            let currentLocation = recognizer.translation(in: cardView.superview!)
            let velocity = recognizer.velocity(in: cardView.superview)
            
            // approximate final position
            let deccelerationRate:CGFloat = 10.0
            let dx:CGFloat = (currentLocation.x - touchPosition.x) + velocity.x / deccelerationRate
            let dy:CGFloat = (currentLocation.y - touchPosition.y) + velocity.y / deccelerationRate
            
            moveByAmount(CGPoint(x: dx,y: dy))
            
            let finalX = dx + originalPosition.x;
            let finalY = dy + originalPosition.y;
            delegate?.cardViewDropped?(cardView, position: CGPoint(x: finalX,y: finalY))
            
        }else if(recognizer.state == UIGestureRecognizerState.cancelled) {
            panGestureReset()
        }
    }
    
    func moveByAmount(_ delta:CGPoint){
        let screenRect = UIScreen.main.bounds
        let screenWidth:CGFloat = screenRect.size.width
        let screenHeight:CGFloat = screenRect.size.height
        let deltaX:CGFloat = min(max(delta.x, -screenWidth), screenWidth);
        let deltaY:CGFloat = min(max(delta.y, -screenHeight), screenHeight);
        let translation:CGAffineTransform = CGAffineTransform(translationX: deltaX, y: deltaY)
        let MAX_ANGLE:CGFloat = 45;
        let squaredSum:CGFloat = (deltaX * deltaX + deltaY * deltaY)
        let degrees:CGFloat = MAX_ANGLE * ((deltaX * deltaY) * 2 / squaredSum) * (sqrt(squaredSum) / sqrt(screenWidth * screenWidth + screenHeight * screenHeight))
        let M_PI_CGFLOAT:CGFloat = CGFloat(M_PI)
        let rotation:CGAffineTransform = CGAffineTransform(rotationAngle: M_PI_CGFLOAT * (-degrees/180.0))
        cardView.transform = rotation.concatenating(translation)
    }
   
    func panGestureReset()
    {
        cardPanGestureRecognizer?.isEnabled = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.cardView.transform = CGAffineTransform.identity
            }, completion: { (bool:Bool) -> Void in
                self.cardPanGestureRecognizer?.isEnabled = true
                return
        })
    }
    
    func cardDoubleTapped(_ recognizer:UITapGestureRecognizer!){
        WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"cardDoubleTapped"], with: cardView.backingCard)
        delegate?.cardViewDoubleTapped?(cardView)
        
        if(cardView.back != nil){
            // these built in transitions automatically re assign super views, so gotta re constrain every time
            if(!flipBoolean){
                cardView.addSubview(cardView.back!)
                cardView.back!.constrainToSuperViewEdges()
                UIView.transition(from: cardView.containerView, to:cardView.back!, duration: 0.4, options: UIViewAnimationOptions.transitionFlipFromLeft) { (bool:Bool) -> Void in
                    self.flipBoolean = true
                }
            }else{
                cardView.addSubview(cardView.containerView)
                cardView.containerView.constrainToSuperViewEdges()
                UIView.transition(from: cardView.back!, to:cardView.containerView, duration: 0.4, options: UIViewAnimationOptions.transitionFlipFromRight) { (bool:Bool) -> Void in
                    self.flipBoolean = false
                }
            }
        }
    }
    
    func cardTapped(_ recognizer:UITapGestureRecognizer!){
        WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"cardTapped"], with: cardView.backingCard)
        delegate?.cardViewTapped?(cardView)
        
        // full card is tapped, depending on the layout we can do different things
        if cardView.visualSource is SummaryCardTwitterTweetVisualSource{
            cardView.handleViewOnWeb(cardView.backingCard.webUrl)
        }else if cardView.visualSource is SummaryCardTwitterProfileVisualSource{
            cardView.handleViewOnWeb(cardView.backingCard.webUrl)
        }
       
    }
    
    // MARK: Instance
    func setup(){
        cardDoubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardPhysics.cardDoubleTapped(_:)))
        cardDoubleTapGestureRecognizer?.numberOfTapsRequired = 2
        cardView.addGestureRecognizer(cardDoubleTapGestureRecognizer!)
        
        cardTapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(CardPhysics.cardTapped(_:)))
        cardTapGestureRecognizer?.numberOfTapsRequired = 1
        cardView.addGestureRecognizer(cardTapGestureRecognizer!)
    }
    
}
