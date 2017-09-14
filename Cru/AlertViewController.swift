//
//  AlertViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/13/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var bottomButton: UIButton!
    
    var alertTitle = ""
    var message = ""
    var buttonTitle = ""
    var delegate: AlertDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = alertTitle
        messageTextView.text = message
        messageTextView.font = UIFont(name: Config.fontName, size: 18)
        bottomButton.setTitle(buttonTitle, for: .normal)

        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func buttonAction(_ sender: UIButton) {
        delegate.closeAlertAction(sender)
        self.dismiss(animated: true, completion: nil)
    }
}

protocol AlertDelegate {
    func closeAlertAction(_ button: UIButton)
}
