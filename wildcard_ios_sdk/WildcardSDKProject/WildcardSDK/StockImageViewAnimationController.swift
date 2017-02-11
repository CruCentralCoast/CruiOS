//
//  StockImageViewAnimationController.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 4/1/15.
//
//

import Foundation

class StockImageViewAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    
    let isPresenting :Bool
    let durationPresenting :TimeInterval = 0.5
    let durationDismissing :TimeInterval = 0.3
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if(isPresenting){
            return durationPresenting
        }else{
            return durationDismissing
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)  {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        }else{
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    func fullScreenImageSize(_ origiSize:CGSize)->CGSize{
        var destinationHeight:CGFloat = 0
        var destinationWidth:CGFloat = 0
        if(Utilities.SCREEN_WIDTH > Utilities.SCREEN_HEIGHT){
            // landscape
            destinationHeight = Utilities.SCREEN_HEIGHT
            destinationWidth = destinationHeight * origiSize.width / origiSize.height
        }else{
            // portrait
            destinationWidth = Utilities.SCREEN_WIDTH
            destinationHeight = destinationWidth * origiSize.height / origiSize.width
        }
        return CGSize(width: destinationWidth, height: destinationHeight)
    }
    
    // MARK: Private
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let stockImageController = presentedController as! StockImageViewViewController
        
        // temp image framed at where the fromImageView is
        let tempImage = WCImageView(frame: containerView.convert(stockImageController.fromImageView.frame, from: stockImageController.fromImageView.superview))
        tempImage.backgroundColor = UIColor.clear    
        tempImage.image = stockImageController.fromImageView.image
        tempImage.contentMode = stockImageController.fromImageView.contentMode
        containerView.addSubview(tempImage)
        
        // get destination dimensions
        let imageSize = stockImageController.fromImageView.image!.size
        let destinationSize = fullScreenImageSize(imageSize)
        
        // grow temp image into the destination frame. designed to be identical to what the full screen looks like at default
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            tempImage.center = containerView.center
            tempImage.bounds = CGRect(x: 0, y: 0,width: destinationSize.width, height: destinationSize.height)
            }, completion: {(completed: Bool) -> Void in
                tempImage.removeFromSuperview()
                containerView.addSubview(presentedController.view)
                stockImageController.fromImageView.image = nil
                transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let containerView = transitionContext.containerView
        let stockImageController = presentedController as! StockImageViewViewController
        
        // from image size
        let imageSize = stockImageController.imageView.image!.size
        let destinationSize = fullScreenImageSize(imageSize)
        let currentCenter = stockImageController.imageView.center
        
        // temp image framed w/ the full screen's image view
        let tempImage = WCImageView(frame: CGRect.zero)
        tempImage.bounds = CGRect(x: 0, y: 0, width: destinationSize.width, height: destinationSize.height)
        tempImage.center = currentCenter
        tempImage.backgroundColor = UIColor.clear
        tempImage.image = stockImageController.imageView.image
        tempImage.contentMode = stockImageController.fromImageView.contentMode
        tempImage.clipsToBounds = true
        containerView.addSubview(tempImage)
        
        // temporary image is added, don't need the full screen view anymore
        presentedController.view.removeFromSuperview()
        
        let destinationRect = containerView.convert(stockImageController.fromImageView.frame, from:stockImageController.fromImageView.superview)
        
        // shrink temp image into the destination frame (what the user originally clicked)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            tempImage.frame = destinationRect
            }, completion: {(completed: Bool) -> Void in
                tempImage.removeFromSuperview()
                stockImageController.fromImageView.image = stockImageController.imageView.image
                transitionContext.completeTransition(completed)
        })
        
        
    }
}
