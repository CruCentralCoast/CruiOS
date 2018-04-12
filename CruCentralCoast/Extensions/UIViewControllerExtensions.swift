//
//  UIViewControllerExtensions.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

public extension UIViewController {
    func insertProfileButtonInNavBar(buttonPressed: Selector?) {
        if let largeTitleView = self.navigationController?.navigationBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UINavigationBarLargeTitleView" } ) {
            
            let profileButton = UIButton()
            profileButton.translatesAutoresizingMaskIntoConstraints = false
            profileButton.setImage(#imageLiteral(resourceName: "profile"), for: .normal)
            profileButton.tintColor = .black
            largeTitleView.addSubview(profileButton)
            profileButton.bottomAnchor.constraint(equalTo: largeTitleView.bottomAnchor, constant: -10).isActive = true
            profileButton.rightAnchor.constraint(equalTo: largeTitleView.rightAnchor, constant: -10).isActive = true
            profileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor).isActive = true
            
            if let selector = buttonPressed {
                profileButton.addTarget(self, action: selector, for: .touchUpInside)
                profileButton.addTarget(self, action: #selector(self.touchDownColor), for: .touchDown)
                profileButton.addTarget(self, action: #selector(self.touchUpColor), for: [.touchUpInside,.touchCancel,.touchUpOutside])
            }
        }
    }
    
    @objc private func touchDownColor(sender: UIButton) {
        sender.tintColor = .lightGray
    }
    
    @objc private func touchUpColor(sender: UIButton) {
        sender.tintColor = .black
    }
}
