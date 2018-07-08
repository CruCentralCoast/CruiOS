//
//  VideoResourceDetailVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import AVKit
import WebKit

class VideoResourceDetailVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var resource: VideoResource?
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = resource?.title
        self.titleLabel.text = resource?.title
        self.authorLabel.text = "by \(resource?.author ?? "Unknown")"
        self.descriptionLabel.text = self.resource?.description
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if let videoResourceURLString = self.resource?.url {
            self.showWebView(from: videoResourceURLString, with: self.activityIndicator, navigationDelegate: self)
        }
    }
}

extension VideoResourceDetailVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}
