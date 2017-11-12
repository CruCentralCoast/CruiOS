//
//  CustomWebViewController.swift
//  Cru
//
//  Created by Erica Solum on 3/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class CustomWebViewController: UIViewController, UIWebViewDelegate {
    var url:URL?
    var urlString:String?
    var artTitle: String?
    var html: String?
    var displayLocalHTML = false
    private var webView:UIWebView!
    private var progressShowing = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if webView == nil {
            webView = UIWebView(frame: self.view.frame)
            webView.delegate = self
            self.view.addSubview(webView)
        }

        if self.displayLocalHTML {
            self.webView.loadHTMLString(self.html!, baseURL: nil)
        } else if let desiredURL = urlString {
            url = URL(string: desiredURL)!
            webView.loadRequest(URLRequest(url: url!))
        }
        if let aTitle = artTitle {
            self.navigationController?.title = aTitle
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomWebViewController.showStatusBar), name: NSNotification.Name.UIWindowDidBecomeHidden, object: self.view.window)
    }
    
    func showStatusBar() {
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    func setUrl(string: String) {
        urlString = string
        
        url = URL(string: urlString!)!
        if webView == nil {
            webView = UIWebView(frame: self.view.frame)
            webView.delegate = self
            self.view.addSubview(webView)
        }
        webView.loadRequest(URLRequest(url: url!))
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if !progressShowing {
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            progressShowing = true
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if progressShowing {
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            progressShowing = false
        }
    }
    
    
}
