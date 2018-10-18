//
//  IntroTermsOfServiceVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class IntroTermsOfServiceVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var pageVCDelegate: PageVCDelegate?
    
    @IBAction func agreeButtonPressed() {
        self.pageVCDelegate?.moveToNextPage()
    }
}
