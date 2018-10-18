//
//  UIViewControllerExtensions.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import WebKit

public extension UIViewController {
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

public extension UIViewController {
    func insertProfileButtonInNavBar() {
        if let largeTitleView = self.navigationController?.navigationBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UINavigationBarLargeTitleView" } ) {
            
            let profileButton = UIButton()
            profileButton.tag = 1
            profileButton.layer.cornerRadius = 16
            profileButton.clipsToBounds = true
            if let imageUrl = LoginManager.instance.user?.photoURL {
                ImageManager.instance.fetch(imageUrl) { image in
                    DispatchQueue.main.async {
                        profileButton.setImage(image, for: .normal)
                    }
                }
            } else {
                profileButton.setImage(#imageLiteral(resourceName: "profile_icon"), for: .normal)
            }
            profileButton.tintColor = .appTint
            largeTitleView.addSubview(profileButton)
            profileButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                profileButton.bottomAnchor.constraint(equalTo: largeTitleView.bottomAnchor, constant: -10),
                profileButton.rightAnchor.constraint(equalTo: largeTitleView.rightAnchor, constant: -20),
                profileButton.heightAnchor.constraint(equalToConstant: 32),
                profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor)
            ])
            
            profileButton.addTarget(self, action: #selector(self.presentProfileViewController), for: .touchUpInside)
            profileButton.addTarget(self, action: #selector(self.profileButtonPressed), for: [.touchDown, .touchDragEnter])
            profileButton.addTarget(self, action: #selector(self.profileButtonReleased), for: [.touchUpInside,.touchCancel,.touchUpOutside, .touchDragExit])
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateProfileButtonImage), name: .UserDidLogin, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateProfileButtonImage), name: .UserDidLogout, object: nil)
        }
    }
    
    @objc private func updateProfileButtonImage() {
        if let largeTitleView = self.navigationController?.navigationBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UINavigationBarLargeTitleView" } ) {
            if let profileButton = largeTitleView.subviews.first(where: { $0.tag == 1 }) as? UIButton {
                if let imageUrl = LoginManager.instance.user?.photoURL {
                    ImageManager.instance.fetch(imageUrl) { image in
                        DispatchQueue.main.async {
                            profileButton.setImage(image, for: .normal)
                        }
                    }
                } else {
                    profileButton.setImage(#imageLiteral(resourceName: "profile_icon"), for: .normal)
                }
            }
        }
    }
    
    @objc private func profileButtonPressed(sender: UIButton, forevent event: UIEvent) {
        sender.tintColor = UIColor.appTint.withAlphaComponent(0.7)
    }
    
    @objc private func profileButtonReleased(sender: UIButton) {
        sender.tintColor = .appTint
    }
    
    @objc private func presentProfileViewController(sender: UIButton) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(ProfileVC.self)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
}

@objc protocol KeyboardOffsetProtocol: AnyObject {
    var view: UIView! { get set }
    /// A view that must be visible when the keyboard is displayed.
    /// The screen will be offset to ensure this view is visible.
    var viewNotCoveredByKeyboard: UIView? { get }
    /// The distance the screen is offset from the viewNotCoveredByKeyboard.
    /// If viewNotCoveredByKeyboard is nil, the screen will be offset from its origin.
    var keyboardOffset: CGFloat { get }
    
    func listenForKeyboardEvents()
    @objc func keyboardWillShow(notification: NSNotification)
    @objc func keyboardWillHide(notification: NSNotification)
}

extension UIViewController: KeyboardOffsetProtocol {
    var viewNotCoveredByKeyboard: UIView? { return nil }
    var keyboardOffset: CGFloat { return 10 }
    
    func listenForKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let visibleView = self.viewNotCoveredByKeyboard {
                let visibleViewPosition = self.view.frame.origin.y + visibleView.frame.origin.y + visibleView.frame.height
                let keyboardPosition = self.view.frame.height - keyboardSize.height
                if visibleViewPosition + self.keyboardOffset > keyboardPosition {
                    self.view.frame.origin.y -= visibleViewPosition + self.keyboardOffset - keyboardPosition
                }
            } else {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= self.keyboardOffset
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
}
