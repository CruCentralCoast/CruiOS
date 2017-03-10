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
    var urlString:String?
    private var webView:UIWebView!
    private var progressShowing = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView = UIWebView(frame: self.view.frame)
        webView.delegate = self
        var url:URL
        
        if let desiredURL = urlString
        {
            url = URL(string: desiredURL)!
        }
        else
        {
            url = URL(string: "www.cru.org")!
        }
        
        webView.loadRequest(URLRequest(url: url))
        self.view.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        if !progressShowing {
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            progressShowing = true
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if progressShowing {
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            progressShowing = false
        }
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if progressShowing {
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            progressShowing = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
