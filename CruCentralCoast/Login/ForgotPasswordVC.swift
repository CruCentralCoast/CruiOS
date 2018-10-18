//
//  ForgotPasswordVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 9/12/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import FirebaseAuth


class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTextField: CruTextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var email: String? { didSet { self.emailTextField?.setText(self.email) } }
    
    override var viewNotCoveredByKeyboard: UIView? { return self.resetPasswordButton }
    override var keyboardOffset: CGFloat { return 10 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.setText(self.email)
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        // Adjust screen position if keyboard is shown
        self.listenForKeyboardEvents()
    }
    
    @IBAction func resetPasswordButtonPressed() {
        self.emailTextField.validateHasText()
        guard let email = self.emailTextField.text, !email.isEmpty else { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.presentAlert(title: error.localizedDescription, message: nil)
            } else {
                self.presentAlert(title: "Password Reset Email Sent", message: "Check your email and follow the link to reset your password.")
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func dismissLogin(_ sender: Any) {
        LoginManager.instance.dismissLogin()
    }
}
