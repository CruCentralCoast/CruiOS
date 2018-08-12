//
//  UIViewControllerExtensions.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import WebKit

public extension UIViewController {
    func insertProfileButtonInNavBar() {
        if let largeTitleView = self.navigationController?.navigationBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UINavigationBarLargeTitleView" } ) {
            
            let profileButton = UIButton()
            profileButton.setImage(#imageLiteral(resourceName: "profile_icon")
                , for: .normal)
            profileButton.tintColor = .cruBrightBlue
            largeTitleView.addSubview(profileButton)
            profileButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                profileButton.bottomAnchor.constraint(equalTo: largeTitleView.bottomAnchor, constant: -10),
                profileButton.rightAnchor.constraint(equalTo: largeTitleView.rightAnchor, constant: -10),
                profileButton.heightAnchor.constraint(equalToConstant: 30),
                profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor)
            ])
            
            profileButton.addTarget(self, action: #selector(self.presentProfileViewController), for: .touchUpInside)
            profileButton.addTarget(self, action: #selector(self.setColorLightGray), for: [.touchDown, .touchDragEnter])
            profileButton.addTarget(self, action: #selector(self.setColorBlack), for: [.touchUpInside,.touchCancel,.touchUpOutside, .touchDragExit])
        }
    }
    
    @objc func popToRootViewController(notification: Notification) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc private func setColorLightGray(sender: UIButton, forevent event: UIEvent) {
        sender.tintColor = .lightGray
    }
    
    @objc private func setColorBlack(sender: UIButton) {
        sender.tintColor = .black
    }
    
    @objc private func presentProfileViewController(sender: UIButton) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(ProfileVC.self)
        self.present(vc, animated: true)
    }
    
    func presentAlert(title: String?, message: String?, animated: Bool = true, completion: (()->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: animated, completion: completion)
    }
    
    func showWebView(from url: String, with activityIndicator: UIActivityIndicatorView? = nil, navigationDelegate: WKNavigationDelegate? = nil) {
        let webView = WKWebView()
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        let vc = UIViewController()
        vc.view = webView
        webView.navigationDelegate = navigationDelegate
        if let indicator = activityIndicator {
            indicator.activityIndicatorViewStyle = .whiteLarge
            indicator.hidesWhenStopped = true
            indicator.color = .gray
            webView.addSubview(indicator)
            indicator.startAnimating()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
            ])
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        self.show(vc, sender: self)
    }
}
