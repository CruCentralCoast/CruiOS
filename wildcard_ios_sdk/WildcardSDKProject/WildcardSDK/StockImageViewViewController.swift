//
//  StockImageViewViewController.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/31/15.
//
//

import UIKit

class StockImageViewViewController: UIViewController,UIViewControllerTransitioningDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var scrollView:UIScrollView!
    var imageView:WCImageView!
    var fromCardView:CardView!
    var fromImageView:WCImageView!
    var tapGesture:UITapGestureRecognizer!
    var imagePanGesture:UIPanGestureRecognizer!
    var initialTouchPoint:CGPoint = CGPoint.zero
    var finalTouchPoint:CGPoint = CGPoint.zero
    let PAN_TO_DIMISS_THRESHOLD:CGFloat = 90.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        // scroll view for zooming
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        scrollView.isMultipleTouchEnabled = true
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 5;
        scrollView.minimumZoomScale = 1;
        view.addSubview(scrollView)
        scrollView.constrainToSuperViewEdges()

        // main image view
        imageView = WCImageView(frame: CGRect.zero)
        imageView.image = fromImageView.image
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        scrollView.addSubview(imageView)
        imageView.constrainToSuperViewEdges()
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0))
        
        // gesture recognizers
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(StockImageViewViewController.tapped))
        scrollView.addGestureRecognizer(tapGesture!)
        
        imagePanGesture = UIPanGestureRecognizer(target: self, action: #selector(StockImageViewViewController.imagePanned))
        imagePanGesture.delegate = self
        scrollView.addGestureRecognizer(imagePanGesture)
        
        view.layoutIfNeeded()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func tapped(){
        if(self.scrollView.zoomScale != 1.0){
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.scrollView.zoomScale = 1.0
            })
        }else{
            fromCardView.delegate?.cardViewRequestedAction?(fromCardView, action: CardViewAction(type: .imageWillExitFullScreen, parameters:nil))
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == imagePanGesture && !otherGestureRecognizer.isKind(of: UIPinchGestureRecognizer.self)){
            return true
        }else{
            return false
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer == imagePanGesture){
            if(scrollView.zoomScale == 1.0){
                return true
            }else{
                return false
            }
        }else{
            return true
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return StockImageViewPresentationController(presentedViewController: presented, presenting: presenting)
        }else{
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return StockImageViewAnimationController(isPresenting: true)
        }else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return StockImageViewAnimationController(isPresenting: false)
        }else {
            return nil
        }
    }
    
    // MARK: Private
    func imagePanned(){
        // drags the image around when we are not zoomed
        let translation = imagePanGesture.translation(in: scrollView)
        if(imagePanGesture.state == .began){
            initialTouchPoint = imagePanGesture.location(in: scrollView)
        }else if(imagePanGesture.state == .changed){
            let newCenter = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            imageView.center = newCenter
            imagePanGesture.setTranslation(CGPoint.zero, in: scrollView)
        }else{
            finalTouchPoint = imagePanGesture.location(in: scrollView)
            let distance = distanceFromPoint(finalTouchPoint, toOtherPoint: initialTouchPoint)
            if(distance > PAN_TO_DIMISS_THRESHOLD){
                fromCardView.delegate?.cardViewRequestedAction?(fromCardView, action: CardViewAction(type: .imageWillExitFullScreen, parameters:nil))
                presentingViewController?.dismiss(animated: true, completion: nil)
            }else{
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.imageView.frame = self.view.frame
                })
            }
        }
    }
    
    func distanceFromPoint(_ p1:CGPoint, toOtherPoint p2:CGPoint)->CGFloat{
        let xDist = (p2.x - p1.x);
        let yDist = (p2.y - p1.y);
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        return distance;
    }

}
