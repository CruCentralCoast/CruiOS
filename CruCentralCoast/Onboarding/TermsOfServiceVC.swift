//
//  TermsOfServiceVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/21/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class TermsOfServiceVC: UIViewController {

    @IBOutlet weak var tosTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tosTextView.layer.cornerRadius = 10
        self.tosTextView.layer.borderColor = UIColor.gray.cgColor
        self.tosTextView.layer.borderWidth = 0.5
    }
    
    @IBAction func agreeButtonPressed() {
        let alertVC = UIAlertController(title: "Agree to Terms?", message: "By pressing AGREE, you agree to abide by these terms.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alertVC.addAction(UIAlertAction(title: "AGREE", style: .default, handler: { action in
            self.presentCampusSelection()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func presentCampusSelection() {
        let chooseCampusVC = ChooseCampusVC()
        self.navigationController?.pushViewController(chooseCampusVC, animated: true)
    }
}
