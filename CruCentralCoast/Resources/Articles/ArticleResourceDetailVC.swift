//
//  ArticleResourceDetailVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import WebKit

class ArticleResourceDetailVC: UIViewController {
    var resource: Resource?
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.resource?.title
        self.webView.navigationDelegate = self
        if let resourceURL = self.resource?.url, let url = URL(string: resourceURL) {
            self.activityIndicator.startAnimating()
            self.webView.load(URLRequest(url: url))
        }
    }
}

extension ArticleResourceDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}
