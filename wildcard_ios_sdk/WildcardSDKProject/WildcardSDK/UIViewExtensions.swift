//
//  Extensions.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//
//

import Foundation

public extension UIView{
    
    class func loadFromNibNamed(_ nibNamed: String) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: Bundle.wildcardSDKBundle()
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    /// For any view with a superview, constrain all edges flush with superview. e.g. Leading, Top, Bottom, Right all 0
    public func constrainToSuperViewEdges(){
        translatesAutoresizingMaskIntoConstraints = false
        constrainLeftToSuperView(0)
        constrainRightToSuperView(0)
        constrainTopToSuperView(0)
        constrainBottomToSuperView(0)
    }
    
    /// Given a reference view, constrain this view to be exactly the same size and position (Useful for overlays that aren't child views). Superviews must be the same
    public func constrainExactlyToView(_ view:UIView){
        if(hasSuperview() && (superview == view.superview)){
            translatesAutoresizingMaskIntoConstraints = false
            superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0))
            superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0))
        }
    }
    
    /// Given a reference view, align left. Superviews must be the same.
    public func alignLeftToView(_ view:UIView){
        if(hasSuperview() && (superview == view.superview)){
            translatesAutoresizingMaskIntoConstraints = false
            let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
            superview?.addConstraint(constraint)
        }
    }
    
    /// Given a reference view, align right. Superviews must be the same.
    public func alignRightToView(_ view:UIView){
        if(hasSuperview() && (superview == view.superview)){
            translatesAutoresizingMaskIntoConstraints = false
            let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
            superview?.addConstraint(constraint)
        }
    }
    
    /// Given a reference view, align top. Superviews must be the same.
    public func alignTopToView(_ view:UIView){
        if(hasSuperview() && (superview == view.superview)){
            translatesAutoresizingMaskIntoConstraints = false
            let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
            superview?.addConstraint(constraint)
        }
    }
    
    /// Given a reference view, align bottom. Superviews must be the same.
    public func alignBottomToView(_ view:UIView){
        if(hasSuperview() && (superview == view.superview)){
            translatesAutoresizingMaskIntoConstraints = false
            let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
            superview?.addConstraint(constraint)
        }
    }
    
    public func constrainLeftToSuperView(_ offset:CGFloat)->NSLayoutConstraint{
        translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: offset)
        superview?.addConstraint(leftConstraint)
        return leftConstraint
    }
    
    public func constrainRightToSuperView(_ offset:CGFloat)->NSLayoutConstraint{
        translatesAutoresizingMaskIntoConstraints = false
        let rightConstraint = NSLayoutConstraint(item: self.superview!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: offset)
        superview?.addConstraint(rightConstraint)
        return rightConstraint
    }
    
    public func constrainTopToSuperView(_ offset:CGFloat)->NSLayoutConstraint{
        translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1.0, constant: offset)
        superview?.addConstraint(topConstraint)
        return topConstraint
    }
    
    public func constrainBottomToSuperView(_ offset:CGFloat)->NSLayoutConstraint{
        translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = NSLayoutConstraint(item: self.superview!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: offset)
        superview?.addConstraint(bottomConstraint)
        return bottomConstraint
    }
    
    public func verticallyCenterToSuperView(_ offset:CGFloat)->NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let yConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1.0, constant: offset)
        superview!.addConstraint(yConstraint)
        return yConstraint
    }
    
    public func horizontallyCenterToSuperView(_ offset:CGFloat)->NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let xConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1.0, constant: offset)
        superview!.addConstraint(xConstraint)
        return xConstraint
    }
    
    public func constrainHeight(_ height:CGFloat)->NSLayoutConstraint{
        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: height)
        addConstraint(heightConstraint)
        return heightConstraint
    }
    
    public func constrainWidth(_ width:CGFloat)->NSLayoutConstraint{
        translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: width)
        addConstraint(widthConstraint)
        return widthConstraint
    }
    
    public func constrainWidth(_ width:CGFloat, height:CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        constrainHeight(height)
        constrainWidth(width)
    }

    // adds a blur overlay to the view and returns a reference to it.
    func addBlurOverlay(_ style:UIBlurEffectStyle)->UIView{
        let overlay = UIView(frame: CGRect.zero)
        addSubview(overlay)
        overlay.constrainToSuperViewEdges()
        
        let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style:style)) as UIVisualEffectView
        overlay.addSubview(visualEffect)
        visualEffect.constrainToSuperViewEdges()
        
        return overlay
    }
    
    func hasSuperview()->Bool{
        return superview != nil
    }
    
    public func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            if parentResponder == nil {
                return nil
            }
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return (parentResponder as! UIViewController)
            }
        }
    }
    
    /// Adds a bottom border with specified width and color
    func addBottomBorderWithWidth(_ width:CGFloat, color:UIColor)->UIView{
        let borderImageView = UIImageView(frame: CGRect.zero)
        borderImageView.backgroundColor = color
        borderImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderImageView)
        borderImageView.constrainLeftToSuperView(0)
        borderImageView.constrainRightToSuperView(0)
        borderImageView.constrainBottomToSuperView(0)
        borderImageView.constrainHeight(width)
        return borderImageView
    }
    
    /// Adds a left border with specified width and color
    func addLeftBorderWithWidth(_ width:CGFloat, color:UIColor)->UIView{
        let borderImageView = UIImageView(frame: CGRect.zero)
        borderImageView.backgroundColor = color
        borderImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderImageView)
        borderImageView.constrainLeftToSuperView(0)
        borderImageView.constrainTopToSuperView(0)
        borderImageView.constrainBottomToSuperView(0)
        borderImageView.constrainWidth(width)
        return borderImageView
    }
    
    /// Adds a right border with specified width and color
    func addRightBorderWithWidth(_ width:CGFloat, color:UIColor)->UIView{
        let borderImageView = UIImageView(frame: CGRect.zero)
        borderImageView.backgroundColor = color
        borderImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderImageView)
        borderImageView.constrainRightToSuperView(0)
        borderImageView.constrainTopToSuperView(0)
        borderImageView.constrainBottomToSuperView(0)
        borderImageView.constrainWidth(width)
        return borderImageView
    }
    
    /// Adds a top border with specified width and color
    func addTopBorderWithWidth(_ width:CGFloat, color:UIColor)->UIView{
        let borderImageView = UIImageView(frame: CGRect.zero)
        borderImageView.backgroundColor = color
        borderImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderImageView)
        borderImageView.constrainLeftToSuperView(0)
        borderImageView.constrainRightToSuperView(0)
        borderImageView.constrainTopToSuperView(0)
        borderImageView.constrainHeight(width)
        return borderImageView
    }
  
}
