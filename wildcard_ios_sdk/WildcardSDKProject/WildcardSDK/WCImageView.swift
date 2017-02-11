//
//  WCImageView.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/26/15.
//
//

import Foundation
import QuartzCore

@objc
public protocol WCImageViewDelegate{
    @objc optional func imageViewTapped(_ imageView:WCImageView)
}

/// Wildcard Extension of UIImageView with a few extra functions
@objc
open class WCImageView : UIImageView
{
    /// Default cross fade animation duration when setting an image
    open var crossFadeDuration:TimeInterval = 0.8
    
    /// Set image to URL and automatically set the image
    open func setImageWithURL(_ url:URL, mode:UIViewContentMode){
        setImageWithURL(url, mode:mode, completion: nil)
    }
    
    /// See WCImageViewDelegate
    open var delegate:WCImageViewDelegate?
    
    /// Set image to URL with a completion block. If the completion block is nil, this function will automatically set the image for the WCAImageView. If the completion block is not nil, this function will not assign the image directly and use the callback -- more suitable for re-use scenarios. This should be called on the main thread.
    open func setImageWithURL(_ url:URL, mode:UIViewContentMode, completion: ((UIImage?, NSError?)->Void)?) -> Void
    {
        var imageRequest = URLRequest(url: url)
        imageRequest.addValue("image/*", forHTTPHeaderField: "Accept")
        
        cancelRequest()
        
        if let cachedImage = ImageCache.sharedInstance.cachedImageForRequest(imageRequest as URLRequest){
            if let cb = completion{
                DispatchQueue.main.async(execute: { () -> Void in
                    cb(cachedImage,nil)
                })
            }else{
                setImage(cachedImage, mode: mode)
            }
        }else{
            startPulsing()
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: WildcardSDK.networkDelegateQueue)
            
            _downloadTask =
                session.downloadTask(with: imageRequest,
                    completionHandler: { (location:URL?, resp:URLResponse?, error:NSError?) -> Void in
                        self.stopPulsing()
                        
                        var error = error
                        guard let imageLocation = location else {
                            error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                            return
                        }
                        
                        guard let underlyingQueue = WildcardSDK.networkDelegateQueue.underlyingQueue else {
                            error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                            return
                        }
                        
                        if(error == nil){
                            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: { () -> Void in
                                let data:Data? = try? Data(contentsOf: imageLocation)
                                if let newImage = UIImage(data: data!){
                                    ImageCache.sharedInstance.cacheImageForRequest(newImage, request: imageRequest)
                                    if let cb = completion{
                                        underlyingQueue.async(execute: { () -> Void in
                                            cb(newImage,nil)
                                        })
                                    }else{
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.setImage(newImage, mode: mode)
                                        })
                                    }
                                }else{
                                    let error = NSError(domain: "Couldn't create image from data", code: 0, userInfo: nil)
                                    if let cb = completion{
                                        underlyingQueue.async(execute: { () -> Void in
                                            cb(nil,error)
                                        })
                                    }else{
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.setNoImage()
                                        })
                                    }
                                }
                            })
                        }else{
                            if let cb = completion{
                                cb(nil,error)
                            }else{
                                self.setNoImage()
                            }
                        }
                } as! (URL?, URLResponse?, Error?) -> Void)
            _downloadTask?.resume()
        }
    }
    
    /// Set the default place holder image, use this when there was a problem downloading or loading an image
    open func setNoImage(){
        tintColor = UIColor.white
        setImage(UIImage.loadFrameworkImage("noImage")!, mode: .center)
    }
    
    /// Cancel any pending image requests
    open func cancelRequest(){
        _downloadTask?.cancel()
        _downloadTask = nil;
    }
    
    /// Set image with a content mode. Does a cross fade animation by default
    open func setImage(_ image:UIImage, mode:UIViewContentMode){
        contentMode = mode
        UIView.transition(with: self,
            duration:crossFadeDuration,
            options: UIViewAnimationOptions.transitionCrossDissolve,
            animations: { self.image = image },
            completion: nil)
    }
    
    fileprivate var _downloadTask:URLSessionDownloadTask?
    fileprivate var _tapGesture:UITapGestureRecognizer!
    
    func startPulsing(){
        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.75
        pulseAnimation.toValue = NSNumber(value: 1.0 as Float)
        pulseAnimation.fromValue = NSNumber(value: 0.6 as Float)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pulseAnimation.autoreverses = true;
        pulseAnimation.repeatCount = FLT_MAX;
        layer.add(pulseAnimation, forKey: nil)
    }

    func stopPulsing(){
        layer.removeAllAnimations()
    }
    
    func imageViewTapped(_ recognizer:UITapGestureRecognizer!){
        delegate?.imageViewTapped?(self)
    }
    
    open func setup(){
        backgroundColor = UIColor.wildcardBackgroundGray()
        layer.cornerRadius = WildcardSDK.imageCornerRadius
        layer.masksToBounds = true
        isUserInteractionEnabled = true
        
        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(WCImageViewDelegate.imageViewTapped(_:)))
        addGestureRecognizer(_tapGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}
