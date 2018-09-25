//
//  WelcomeVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func welcomeButtonPressed() {
        let tosVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(TermsOfServiceVC.self)
        self.navigationController?.pushViewController(tosVC, animated: true)
    }
}
