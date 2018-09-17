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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.setText(self.email)
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let buttonPosition = self.view.frame.origin.y + self.resetPasswordButton.frame.origin.y + self.resetPasswordButton.frame.height
            let keyboardPosition = self.view.frame.height - keyboardSize.height
            let buffer: CGFloat = 10
            if buttonPosition + buffer >= keyboardPosition {
                self.view.frame.origin.y -= buttonPosition + buffer - keyboardPosition
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
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
