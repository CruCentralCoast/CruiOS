//
//  ProfilePrivacyPolicyVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfilePrivacyPolicyVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.textView.scrollRangeToVisible(NSRange(location: 0, length: 1))
    }
}
