//
//  MediaTextFullWebView.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/18/14.
//
//

import Foundation

@objc
open class MediaTextFullWebView : CardViewElement, UIWebViewDelegate
{
    static var onceToken: Int = 0
    static var instance: String? = nil
    
    /*fileprivate class var webViewReadingCss : String{
        struct Static{
            static var onceToken : Int = 0
            static var instance : String? = nil
        }
        
        _ = MediaTextFullWebView.__once
        return Static.instance!
    }*/
    
    func getWebViewReadingCss() -> String {
        if MediaTextFullWebView.instance == nil {
            let file = Bundle.wildcardSDKBundle().path(forResource: "MediaReadingCss", ofType: "css")
            let contents = try? NSString(contentsOfFile: file!, encoding: String.Encoding.utf8.rawValue)
            MediaTextFullWebView.instance = contents as? String
        }
        return MediaTextFullWebView.instance!
    }
    
    /*private static var __once: () = { () -> Void in
            let file = Bundle.wildcardSDKBundle().path(forResource: "MediaReadingCss", ofType: "css")
            let contents = try? NSString(contentsOfFile: file!, encoding: String.Encoding.utf8.rawValue)
            Static.instance = contents as? String
        }()*/
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var webview: UIWebView!
    
    // MARK: CardViewElement
    override open func initialize() {
        webview.delegate = self
        bottomToolbar.tintColor = UIColor.wildcardLightBlue()
    }
    
    override open func update(_ card:Card) {
        if let articleCard = card as? ArticleCard{
            webview?.loadHTMLString(constructFinalHtml(articleCard), baseURL: card.webUrl as URL)
            updateToolbar(articleCard)
        }
    }
    
    // MARK: Action
    func closeButtonTapped(_ sender: AnyObject) {
        if(cardView != nil){
            cardView!.delegate?.cardViewRequestedAction?(cardView!, action: CardViewAction(type: .collapse, parameters: nil))
        }
    }
    
    func actionButtonTapped(_ sender:AnyObject){
        if(cardView != nil){
            WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"shareAction"], with: cardView!.backingCard)
            cardView!.handleShare()
        }
    }
    
    // MARK: Private
    func updateToolbar(_ card:Card){
        
        var barButtonItems:[UIBarButtonItem] = []
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(MediaTextFullWebView.closeButtonTapped(_:)))
        barButtonItems.append(closeButton)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        barButtonItems.append(flexSpace)
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(MediaTextFullWebView.actionButtonTapped(_:)))
        barButtonItems.append(actionButton)
        
        bottomToolbar.setItems(barButtonItems, animated: false)
    }
    
    func constructFinalHtml(_ articleCard:ArticleCard)->String{
        var finalHtml:String = ""
        finalHtml += "<html>"
        finalHtml += "<head>"
        finalHtml += getWebViewReadingCss()
        finalHtml += "</head>"
        
        finalHtml += "<body>"
        
        finalHtml +=  "<div id=\"customWildcardKicker\">\(articleCard.creator.name.uppercased())</div>"
        finalHtml +=  "<div id=\"customHairline\"></div>"
        finalHtml +=  "<div id=\"customWildcardHeader\">\(articleCard.title)</div>"
        
        let publishedDateFormatter = DateFormatter()
        publishedDateFormatter.dateFormat = "MMM dd, YYYY"
        var dateDisplayString:String?
        if let date = articleCard.publicationDate{
            dateDisplayString = publishedDateFormatter.string(from: date as Date)
        }
        
        var bylineDisplay:String?
    
        if let author = articleCard.author {
            if let dateString = dateDisplayString{
                bylineDisplay = String(format: "%@ %@ %@", dateString, "\u{2014}", author)
            }else{
                bylineDisplay = author
            }
        }else if let dateString = dateDisplayString{
            bylineDisplay = dateString
        }
       
        if bylineDisplay != nil{
             finalHtml +=  "<div id=\"customWildcardByline\">\(bylineDisplay!)</div>"
        }
        
        finalHtml +=  "<div id=\"customHairline\"></div>"
        
        finalHtml += articleCard.html!
        
        finalHtml += "<div><center><span class=\"viewMore\"><a id=\"viewOnWeb\" href=\"\(articleCard.webUrl)\">VIEW ON WEB</a></span></div><br></br>"
        
        finalHtml += "</body>"
        finalHtml += "</html>"

        return finalHtml
    }
    
    
    
    // MARK: UIWebViewDelegate
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if(navigationType == .linkClicked){
            if(cardView != nil){
                WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"linkClicked"], with: cardView!.backingCard)
                cardView!.handleViewOnWeb(request.url!)
            }
            return false
        }else{
            return true
        }
    }
    
}
