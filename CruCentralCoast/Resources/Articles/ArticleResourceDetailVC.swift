//
//  ArticleResourceDetailVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import WebKit

class ArticleResourceDetailVC: UIViewController {
    var resource: ArticleResource?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.resource?.title
        self.titleLabel.text = self.resource?.title
        self.authorLabel.text = "by \(self.resource?.author ?? "Unknown")"
        self.descriptionLabel.text = self.resource?.description
    }
    
    @IBAction func readArticleButtonPressed(_ sender: Any) {
        if let resourceURLString = self.resource?.url {
            print(resourceURLString)
            self.showWebView(from: resourceURLString, with: self.activityIndicator, navigationDelegate: self)
        }
    }
}

extension ArticleResourceDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}
