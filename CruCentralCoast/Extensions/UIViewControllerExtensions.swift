//
//  UIViewControllerExtensions.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

public extension UIViewController {
    func insertProfileButtonInNavBar() {
        if let largeTitleView = self.navigationController?.navigationBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UINavigationBarLargeTitleView" } ) {
            
            let profileButton = UIButton()
            profileButton.translatesAutoresizingMaskIntoConstraints = false
            profileButton.setImage(#imageLiteral(resourceName: "profile_icon")
                , for: .normal)
            profileButton.tintColor = .black
            largeTitleView.addSubview(profileButton)
            profileButton.bottomAnchor.constraint(equalTo: largeTitleView.bottomAnchor, constant: -10).isActive = true
            profileButton.rightAnchor.constraint(equalTo: largeTitleView.rightAnchor, constant: -10).isActive = true
            profileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor).isActive = true
            
            profileButton.addTarget(self, action: #selector(self.pushProfileViewController), for: .touchUpInside)
            profileButton.addTarget(self, action: #selector(self.setColorLightGray), for: [.touchDown, .touchDragEnter])
            profileButton.addTarget(self, action: #selector(self.setColorBlack), for: [.touchUpInside,.touchCancel,.touchUpOutside, .touchDragExit])
        }
    }
    
    @objc private func setColorLightGray(sender: UIButton, forevent event: UIEvent) {
        sender.tintColor = .lightGray
    }
    
    @objc private func setColorBlack(sender: UIButton) {
        sender.tintColor = .black
    }
    
    @objc private func pushProfileViewController(sender: UIButton) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(ProfileVC.self)
        self.show(vc, sender: self)
    }
    
    func presentAlert(title: String?, message: String?, animated: Bool = true, completion: (()->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: animated, completion: completion)
    }
}
