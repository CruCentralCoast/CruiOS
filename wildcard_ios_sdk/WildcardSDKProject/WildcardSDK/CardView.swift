//
//  CardView.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//
//

import Foundation
import UIKit
import QuartzCore

/**
The visual source of a CardView.

Every CardView is associated with a visual source and provides views for various subcomponents. If you choose to completely customize a card, you will have to implement a visual source of your own.

Each subcomponent of a CardView must extend CardViewElement.
*/
@objc
public protocol CardViewVisualSource{
    
    /// CardViewElement for the card body
    func viewForCardBody()->CardViewElement
    
    /// Optional CardViewElement for header
    @objc optional func viewForCardHeader()->CardViewElement?
    
    /// Optional CardViewElement for footer
    @objc optional func viewForCardFooter()->CardViewElement?
    
    /// Optional CardViewElement for the back of the card. Spans the full card, shown on double tap
    @objc optional func viewForBackOfCard()->CardViewElement?
}

/**
ALPHA: The visual source of a maximized CardView

The maximized visual source should always be used with the extension UIView.maximizeCardView. This visual source is responsible for displaying a Card during its 'maximized state'. In this state, the Card takes up the entire application frame, and is owned by a fully presented view controller.

This visual source may never be used for an inline card. The size is always determined relative to the application frame using applicationFrameEdgeInsets
*/
@objc
public protocol MaximizedCardViewVisualSource : CardViewVisualSource {
    
    /**
    This represents the edge insets of the maximized CardView to the application frame.
    
    This is essentially how inset the CardView is from the screen
    */
    func applicationFrameEdgeInsets()->UIEdgeInsets
}

@objc
public protocol CardViewDelegate{
    
    /**
    Simply just a hook into UIView.layoutSubviews() for the CardView
    */
    @objc optional func cardViewLayoutSubviews(_ cardView:CardView)
    
    /**
    CardView has been requested to perform a specific action.
    */
    @objc optional func cardViewRequestedAction(_ cardView:CardView, action:CardViewAction)
    
    /**
    CardView is about to be reloaded.
    */
    @objc optional func cardViewWillReload(_ cardView:CardView)
    
    /**
    CardView has reloaded.
    */
    @objc optional func cardViewDidReload(_ cardView:CardView)
    
}

@objc
open class CardView : UIView
{
    // MARK: Public
    
    /// See CardPhysics
    open var physics:CardPhysics?
    
    /// See CardViewDelegate
    open var delegate:CardViewDelegate?
    
    /// The visual source associated with this CardView
    open var visualSource:CardViewVisualSource!
    
    /// The backing card for this CardView
    open var backingCard:Card!
    
    /**
    Preferred width for the CardView. When a CardView lays out its subcomponents from a visual source, each subcomponent will also be assigned this preferred width.
    
    Changing the preferredWidth for the CardView will affect the intrinsic size of the subcomponents and the CardView itself.
    */
    open var preferredWidth:CGFloat{
        get{
            return __preferredWidth
        }set{
            __preferredWidth = newValue
            for element in [header, body, footer, back]{
                element?.preferredWidth = __preferredWidth
            }
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Creates a CardView from a card. A layout will be chosen and the CardView will be returned with a default size.
    open class func createCardView(_ card:Card!)->CardView?{
        if let card = card {
            let layoutToUse = CardLayoutEngine.sharedInstance.matchLayout(card)
            return CardView.createCardView(card, layout: layoutToUse, preferredWidth:UIViewNoIntrinsicMetric)
        }else{
            print("Can't create CardView from nil card")
            return nil
        }
    }
    
    /// Creates a CardView from a card with a prechosen layout. The CardView will be returned with a default size.
    open class func createCardView(_ card:Card!, layout:WCCardLayout)->CardView?{
        if let card = card {
            if(!card.supportsLayout(layout)){
                print("Unsupported layout for this card type, returning nil.")
                return nil
            }
            let datasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: card)
            return CardView.createCardView(card, visualSource: datasource, preferredWidth:UIViewNoIntrinsicMetric)
        }else{
            print("Can't create CardView from nil card")
            return nil
        }
    }

    /**
    Creates a CardView from a card with a prechosen layout and width. 
    
    The card's size will be calculated optimally from the preferredWidth. You may choose various layouts and widths to a get a height that is suitable.
    */
    open class func createCardView(_ card:Card!, layout:WCCardLayout, preferredWidth:CGFloat)->CardView?{
        if let card = card {
            if(!card.supportsLayout(layout)){
                print("Unsupported layout for this card type, returning nil.")
                return nil
            }
            let datasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: card)
            return CardView.createCardView(card, visualSource: datasource, preferredWidth:preferredWidth)
        }else{
            print("Can't create CardView from nil card")
            return nil
        }
    }
    
    /**
    Creates a CardView with a customized visual source. See tutorials on how to create your own visual source.
    
    Passing in UIViewNoIntrinsicMetric for the width will result in a default width calculation based on screen size
    */
    open class func createCardView(_ card:Card!, visualSource:CardViewVisualSource!, preferredWidth:CGFloat)->CardView?{
        
        if(card == nil){
            print("Card is nil -- can't create CardView.")
            return nil
        }else if(visualSource == nil){
            print("Visual source is nil -- can't create CardView.")
            return nil
        }else if(WildcardSDK.apiKey == nil){
            print("Wildcard API Key not initialized -- can't create CardView.")
            return nil
        }
        
        WildcardSDK.analytics?.trackEvent("CardViewCreated", withProperties: nil, with: card)
        
        let newCardView = CardView(frame: CGRect.zero)
        
        // default width if necessary
        if(preferredWidth == UIViewNoIntrinsicMetric){
            newCardView.preferredWidth = CardView.defaultWidth()
        }else{
            newCardView.preferredWidth = preferredWidth
        }
        
        // init data and visuals
        newCardView.backingCard = card
        newCardView.visualSource = visualSource
        newCardView.initializeCardComponents()
        
        // set frame to default at intrinsic size
        let size = newCardView.intrinsicContentSize
        newCardView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // lays out card components
        newCardView.layoutCardComponents()
        
        return newCardView
    }
    
    /// ALPHA: Reloads the CardView with a new card. Autogenerates a layout
    open func reloadWithCard(_ newCard:Card!){
        if let card = newCard {
            let layoutToUse = CardLayoutEngine.sharedInstance.matchLayout(card)
            return reloadWithCard(card, layout: layoutToUse)
        }else{
            print("Can't reload with nil card")
        }
    }
    
    /// ALPHA: Reloads the CardView with a new card and specified layout.
    open func reloadWithCard(_ newCard:Card!, layout:WCCardLayout){
        if let card = newCard {
            if(!card.supportsLayout(layout)){
                print("Unsupported layout for this card type, nothing reloaded.")
                return
            }
            let autoDatasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: card)
            reloadWithCard(card, visualSource: autoDatasource, preferredWidth:UIViewNoIntrinsicMetric)
        }else{
            print("Can't reload with nil card")
        }
    }
    
    /// ALPHA: Reloads the CardView with a new card, specified layout, and preferredWidth.
    open func reloadWithCard(_ newCard:Card!, layout:WCCardLayout, preferredWidth:CGFloat){
        if let card = newCard {
            if(!card.supportsLayout(layout)){
                print("Unsupported layout for this card type, nothing reloaded.")
                return
            }
            let autoDatasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: card)
            reloadWithCard(card, visualSource: autoDatasource, preferredWidth:preferredWidth)
        }else{
            print("Can't reload with nil card")
        }
    }
    
    /// ALPHA: Reloads the CardView with a new card, custom visual source, and preferredWidth
    open func reloadWithCard(_ newCard:Card!, visualSource:CardViewVisualSource, preferredWidth:CGFloat){
        if let card = newCard {
            delegate?.cardViewWillReload?(self)
            
            // default width if necessary
            if(preferredWidth == UIViewNoIntrinsicMetric){
                self.preferredWidth = CardView.defaultWidth()
            }else{
                self.preferredWidth = preferredWidth
            }
            
            backingCard = card
            self.visualSource = visualSource
            
            // remove old card subviews
            removeCardSubviews()
            
            initializeCardComponents()
            
            layoutCardComponents()
            
            invalidateIntrinsicContentSize()
            
            // reloaded
            delegate?.cardViewDidReload?(self)
        }else{
            print("Can't reload with nil card")
        }
    }
    
    open func fadeOut(_ duration:TimeInterval, delay:TimeInterval, completion:((_ bool:Bool) -> Void)?){
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.header?.alpha = 0
            self.body?.alpha = 0
            self.footer?.alpha = 0
            self.back?.alpha = 0
            }) { (bool:Bool) -> Void in
                completion?(bool)
                return
        }
    }
    
    open func fadeIn(_ duration:TimeInterval, delay:TimeInterval, completion:((_ bool:Bool) -> Void)?){
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.header?.alpha = 1
            self.body?.alpha = 1
            self.footer?.alpha = 1
            self.back?.alpha = 1
            }) { (bool:Bool) -> Void in
                completion?(bool)
                return
        }
    }
    
    // MARK: Private properties
    var containerView:UIView!
    var back:CardViewElement?
    var header:CardViewElement?
    var body:CardViewElement!
    var footer:CardViewElement?
    fileprivate var __preferredWidth:CGFloat = UIViewNoIntrinsicMetric
    
    // MARK: UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        convenienceInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        convenienceInitialize()
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if(hasSuperview()){
            WildcardSDK.analytics?.trackEvent("CardViewDisplayed", withProperties: nil, with: backingCard)
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        convenienceInitialize()
    }
    
    override open func layoutSubviews(){
        super.layoutSubviews()
        
        delegate?.cardViewLayoutSubviews?(self)
        
        // reset shadow path to whatever bounds card is taking up
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: WildcardSDK.cardCornerRadius)
        layer.shadowPath = path.cgPath
    }
    
    // MARK: Instance
    func handleShare(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Platform.sharedInstance.createWildcardShortLink(backingCard.webUrl, completion: { (url:URL?, error:NSError?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let shareUrl = url {
                let params:NSDictionary = ["url":shareUrl]
                let cardAction = CardViewAction(type: WCCardAction.share, parameters: params)
                self.delegate?.cardViewRequestedAction?(self, action: cardAction)
            }
        })
    }
    
    func handleViewOnWeb(_ url:URL){
        let params:NSDictionary = ["url":url]
        let cardAction = CardViewAction(type: WCCardAction.viewOnWeb, parameters: params)
        delegate?.cardViewRequestedAction?(self, action: cardAction)
    }
    
    func handleDownloadApp(){
        if let articleCard = backingCard as? ArticleCard{
            if let url = articleCard.creator.iosAppStoreUrl {
                let lastComponent:NSString = url.lastPathComponent as NSString
                let id = lastComponent.substring(from: 2) as NSString
                let params:NSDictionary = ["id":id]
                
                let cardAction = CardViewAction(type: WCCardAction.downloadApp, parameters: params)
                delegate?.cardViewRequestedAction?(self, action: cardAction)
            }
        }
    }
    
    // MARK: Private
    
    fileprivate class func defaultWidth()->CGFloat{
        let screenBounds = UIScreen.main.bounds
        if(screenBounds.width > screenBounds.height){
            return screenBounds.height - (2 * WildcardSDK.defaultScreenMargin)
        }else{
            return screenBounds.width - (2 * WildcardSDK.defaultScreenMargin)
        }
        
    }
    
    fileprivate func initializeCardComponents(){
        header = visualSource.viewForCardHeader?()
        header?.preferredWidth = preferredWidth
        body = visualSource.viewForCardBody()
        body.preferredWidth = preferredWidth
        footer = visualSource.viewForCardFooter?()
        footer?.preferredWidth = preferredWidth
        
        back = visualSource.viewForBackOfCard?()
        back?.preferredWidth = preferredWidth
        back?.layer.cornerRadius = WildcardSDK.cardCornerRadius
        back?.layer.masksToBounds = true
        
        // initialize and update
        let cardViews:[CardViewElement?] = [header, body, footer, back]
        for view in cardViews{
            view?.cardView = self
            view?.update(backingCard)
        }
    }
    
    override open var intrinsicContentSize : CGSize {
        var height:CGFloat = 0
        
        if(header != nil){
            height += header!.optimizedHeight(preferredWidth)
        }
        
        height += body.optimizedHeight(preferredWidth)
        
        if(footer != nil){
            height += footer!.optimizedHeight(preferredWidth)
        }
        
        let size = CGSize(width: preferredWidth, height: height)
        return size
    }
    
    fileprivate func layoutCardComponents(){
        // header and footer always stick to top and bottom
        if(header != nil){
            containerView.addSubview(header!)
            header!.constrainLeftToSuperView(0)
            header!.constrainRightToSuperView(0)
            header!.constrainTopToSuperView(0)
        }
        
        if(footer != nil){
            containerView.addSubview(footer!)
            footer!.constrainLeftToSuperView(0)
            footer!.constrainRightToSuperView(0)
            footer!.constrainBottomToSuperView(0)
        }
        
        containerView.addSubview(body)
        body.constrainLeftToSuperView(0)
        body.constrainRightToSuperView(0)
        
        // card body layout has 4 vertical layout possibilities
        if(header == nil && footer == nil){
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0))
        }else if(header != nil && footer == nil){
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .top, relatedBy: .equal, toItem: header!, attribute: .bottom, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0))
        }else if(header == nil && footer != nil){
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .bottom, relatedBy: .equal, toItem: footer!, attribute: .top, multiplier: 1.0, constant: 0))
        }else{
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .top, relatedBy: .equal, toItem: header!, attribute: .bottom, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .bottom, relatedBy: .equal, toItem: footer!, attribute: .top, multiplier: 1.0, constant: 0))
        }
    }
    
    fileprivate func convenienceInitialize(){
        
        backgroundColor = UIColor.clear
        
        // container view holds card view elements
        containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = WildcardSDK.cardBackgroundColor
        containerView.layer.cornerRadius = WildcardSDK.cardCornerRadius
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        containerView.constrainToSuperViewEdges()
        
        // drop shadow if enabled
        if(WildcardSDK.cardDropShadow){
            layer.shadowColor = UIColor.wildcardMediumGray().cgColor
            layer.shadowOpacity = 0.8
            layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            layer.shadowRadius = 1.0
        }
        
        physics = CardPhysics(cardView:self)
        physics?.setup()
    }
    
    fileprivate func removeCardSubviews(){
        let cardViews:[UIView?] = [header, body, footer, back]
        for view in cardViews{
            view?.removeFromSuperview()
        }
    }
}
