//
//  WCVideoView.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/16/15.
//
//

import Foundation
import MediaPlayer
import WebKit

@objc
public protocol WCVideoViewDelegate{
    
    @objc optional func videoViewDidStartPlaying(_ videoView:WCVideoView)
    @objc optional func videoViewWillEndPlaying(_ videoView:WCVideoView)
    @objc optional func videoViewTapped(_ videoView:WCVideoView)
}

/// Plays content from a Video Card
@objc
open class WCVideoView : UIView, WKNavigationDelegate, UIGestureRecognizerDelegate, WKScriptMessageHandler, YTPlayerViewDelegate  {
    
    open var videoCard:VideoCard?
    open var delegate:WCVideoViewDelegate?
    
    fileprivate var videoWKView:WKWebView!
    fileprivate var ytPlayer:YTPlayerView!
    fileprivate var posterView:WCImageView!
    fileprivate var tapGestureRecognizer:UITapGestureRecognizer!
    fileprivate var ytTapGestureRecognizer:UITapGestureRecognizer!
    fileprivate var passthroughView:PassthroughView!
    fileprivate var videoActionImage:UIImageView!
    fileprivate var tintOverlay:UIView!
    fileprivate var spinner:UIActivityIndicatorView!
    fileprivate var moviePlayer:MPMoviePlayerViewController?
    fileprivate var streamUrl:URL?
    fileprivate var inError:Bool = false
    
    func initialize(){
        
        backgroundColor = UIColor.black
        isUserInteractionEnabled = true
        
        // initializes the video wkwebview
        let controller = WKUserContentController()
        controller.add(self, name: "observe")
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = false
        configuration.mediaPlaybackRequiresUserAction = true
        configuration.userContentController = controller
        
        videoWKView = WKWebView(frame: CGRect.zero, configuration: configuration)
        videoWKView.backgroundColor = UIColor.black
        videoWKView.scrollView.isScrollEnabled = false
        videoWKView.scrollView.bounces = false
        videoWKView.navigationDelegate = self
        videoWKView.isUserInteractionEnabled = true
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WCVideoView.videoTapped(_:)));
        tapGestureRecognizer.delegate = self
        videoWKView.addGestureRecognizer(tapGestureRecognizer)
        
        // wkwebview constraints
        addSubview(videoWKView)
        videoWKView.constrainToSuperViewEdges()

        // youtube has its own player for callbacks. put this under the wkwebview and only show if we're using Youtube
        ytPlayer = YTPlayerView(frame: CGRect.zero)
        ytPlayer.delegate = self
        ytPlayer.backgroundColor = UIColor.black
        ytPlayer.isUserInteractionEnabled = true
        ytTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WCVideoView.videoTapped(_:)));
        ytTapGestureRecognizer.delegate = self
        ytPlayer.addGestureRecognizer(ytTapGestureRecognizer)
        insertSubview(ytPlayer, belowSubview: videoWKView)
        ytPlayer.constrainExactlyToView(videoWKView)
        
        // pass through view on top of webview for a poster image
        passthroughView = PassthroughView(frame:CGRect.zero)
        passthroughView.isUserInteractionEnabled = false
        insertSubview(passthroughView, aboveSubview: videoWKView)
        passthroughView.constrainExactlyToView(videoWKView)
        passthroughView.backgroundColor = UIColor.black
        
        posterView = WCImageView(frame:CGRect.zero)
        posterView.clipsToBounds = true
        passthroughView.addSubview(posterView)
        posterView.constrainToSuperViewEdges()
        posterView.backgroundColor = UIColor.black
        
        // black tint overlay on the poster image
        tintOverlay = PassthroughView(frame:CGRect.zero)
        tintOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        passthroughView.addSubview(tintOverlay)
        tintOverlay.constrainToSuperViewEdges()
        
        videoActionImage = UIImageView(frame:CGRect.zero)
        videoActionImage.tintColor = UIColor.white
        videoActionImage.translatesAutoresizingMaskIntoConstraints = false
        videoActionImage.image = UIImage.loadFrameworkImage("playIcon")
        videoActionImage.isHidden = true
        passthroughView.insertSubview(videoActionImage, aboveSubview: posterView)
        passthroughView.addSubview(videoActionImage)
        addConstraint(NSLayoutConstraint(item: videoActionImage, attribute: .centerX, relatedBy: .equal, toItem: passthroughView, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: videoActionImage, attribute: .centerY, relatedBy: .equal, toItem: passthroughView, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        // spinner above poster image
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(spinner, aboveSubview: passthroughView)
        addConstraint(NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: videoWKView, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: videoWKView, attribute: .centerY, multiplier: 1.0, constant: 0))
        
    }
    
    func loadVideoCard(_ videoCard:VideoCard){
        inError = false
        self.videoCard = videoCard

        // poster image if available
        if let posterImageUrl = videoCard.posterImageUrl {
            posterView.image = nil;
            posterView.setImageWithURL(posterImageUrl, mode: .scaleAspectFill, completion: { (image, error) -> Void in
                if(self.inError == false){
                    if(image != nil && error == nil){
                        self.posterView.setImage(image!, mode:.scaleAspectFill)
                    }else{
                        self.posterView.setNoImage()
                    }
                }else{
                    self.setError()
                }
            })
        }else{
            posterView.setNoImage()
        }
        
        if(videoCard.isYoutube()){
            // youtube special treatment
            streamUrl = nil
            videoWKView.isHidden = true
            ytPlayer.isHidden = false
            if let ytId = videoCard.getYoutubeId() {
                setLoading(true)
                ytPlayer.load(withVideoId: ytId)
            }else{
                print("Shouldn't happen -- Video Card with Youtube creator is malformed.")
                setError()
                return
            }
        }else if(videoCard.isVimeo()){
            // vimeo special treatment
            self.setLoading(true)
            YTVimeoExtractor.fetchVideoURL(fromURL: videoCard.embedUrl.absoluteString, quality: YTVimeoVideoQualityMedium, completionHandler: { (url, error, quality) -> Void in
                if(url != nil && error == nil){
                    self.streamUrl = url
                    self.setLoading(false)
                }else{
                    self.setError()
                }
            })
        }else if(videoCard.streamUrl != nil){
            // direct stream available
            streamUrl = videoCard.streamUrl as URL?
            videoActionImage.isHidden = false
            setLoading(false)
        }else{
            // most general case we load embedded URL into webview
            streamUrl = nil
            videoWKView.isHidden = false
            ytPlayer.isHidden = true
            setLoading(true)
            videoWKView.load(URLRequest(url: videoCard.embedUrl as URL))
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        if(gestureRecognizer == tapGestureRecognizer || gestureRecognizer == ytTapGestureRecognizer || otherGestureRecognizer == tapGestureRecognizer || otherGestureRecognizer == ytTapGestureRecognizer){
            // we want our tap gesture to be recognized alongside the WKWebView's default one
            return true;
        }else{
            return false;
        }
    }
    
    // MARK: Notification Handling
    func moviePlayerDidFinish(_ notification:Notification){
        delegate?.videoViewWillEndPlaying?(self)
       
        if let vc = parentViewController(){
            vc.dismissMoviePlayerViewControllerAnimated()
        }
        
        // remove notifications
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer?.moviePlayer)
    }
    
    // MARK: Action
    func videoTapped(_ recognizer:UITapGestureRecognizer!){
        
        delegate?.videoViewTapped?(self)
        
        if(inError){
            // attempt reload if we're in error state
            if let card = videoCard {
                loadVideoCard(card)
            }
        }else{
            if(streamUrl != nil){
                // have a stream url, can show a movie player automatically
                moviePlayer = MPMoviePlayerViewController(contentURL: streamUrl!)
                NotificationCenter.default.removeObserver(moviePlayer!, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer?.moviePlayer)
                NotificationCenter.default.addObserver(self, selector: #selector(WCVideoView.moviePlayerDidFinish(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: moviePlayer?.moviePlayer)
                moviePlayer!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                moviePlayer!.moviePlayer.play()
                
                if let vc = parentViewController(){
                    vc.presentMoviePlayerViewControllerAnimated(moviePlayer!)
                    delegate?.videoViewDidStartPlaying?(self)
                }
            }else{
                // using a webview, hide the poster image
                passthroughView.isHidden = true
            }
        }
    }
    
    // MARK: WKNavigationDelegate
    open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
    }
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        setLoading(false)
        
        // add some listeners to html5 video tag to get call backs for full screen
        videoWKView.evaluateJavaScript(getHtml5ListenerJS(), completionHandler: nil)
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        setError()
    }
    
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        setError()
    }
    
    // MARK: WKScriptMessageHandler
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        if let body = message.body as? String{
            if(body == "webkitbeginfullscreen"){
                delegate?.videoViewDidStartPlaying?(self)
            }else if(body == "webkitendfullscreen"){
                delegate?.videoViewWillEndPlaying?(self)
            }
        }
    }
    
    // MARK: YTPlayerViewDelegate
    open func playerView(_ playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        setError()
    }
    
    open func playerViewDidBecomeReady(_ playerView: YTPlayerView!) {
        setLoading(false)
    }
    
    open func playerView(_ playerView: YTPlayerView!, didChangeTo state: YTPlayerState) {
        if(state.rawValue == kYTPlayerStatePlaying.rawValue){
            delegate?.videoViewDidStartPlaying?(self)
        }else if(state.rawValue == kYTPlayerStatePaused.rawValue){
            delegate?.videoViewWillEndPlaying?(self)
        }
    }
    
    // MARK: Private
    fileprivate func setError(){
        passthroughView.isHidden = false
        spinner.stopAnimating()
        posterView.cancelRequest()
        posterView.image = nil
        videoActionImage.isHidden = false
        videoActionImage.image = UIImage.loadFrameworkImage("noVideoFound")
        inError = true
    }
    
    fileprivate func getHtml5ListenerJS()->String{
        var script:String?
        if let file = Bundle.wildcardSDKBundle().path(forResource: "html5VideoListeners", ofType: "js"){
            script = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
        }
        return script!
    }
    
    fileprivate func setLoading(_ loading:Bool){
        if(loading){
            videoActionImage.isHidden = true
            spinner.startAnimating()
        }else{
            videoActionImage.isHidden = false
            spinner.stopAnimating()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        initialize()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
}
