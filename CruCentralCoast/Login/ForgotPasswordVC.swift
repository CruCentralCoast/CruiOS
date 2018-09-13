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
    var email: String? { didSet { self.emailTextField?.setText(self.email) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.setText(self.email)
    }
    
    @IBAction func sendEmailButtonPressed(_ sender: Any) {
        guard let email = self.emailTextField.text, !email.isEmpty else {
            self.presentAlert(title: "Email Field Empty", message: "Type the email associated with the account that you want to reset the password of")
            return
        }
        
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
