//
//  SignUpVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/11/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {

    @IBOutlet weak var emailTextField: CruTextField!
    @IBOutlet weak var passwordTextField: CruTextField!
    @IBOutlet weak var confirmPasswordTextField: CruTextField!
    @IBOutlet weak var signUpButton: CruButton!
    
    var email: String? { didSet { self.emailTextField?.text = self.email } }
    var password: String?  { didSet { self.passwordTextField?.text = self.password } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.setText(self.email)
        self.passwordTextField.setText(self.password)
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let buttonPosition = self.signUpButton.frame.origin.y + self.signUpButton.frame.height
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

    @IBAction func signUp() {
        self.view.endEditing(true)
        self.emailTextField.validateHasText()
        self.passwordTextField.validateHasText()
        self.confirmPasswordTextField.validateHasText()
        
        guard let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty,
            let password2 = self.confirmPasswordTextField.text, !password2.isEmpty else { return }
        guard password == password2 else {
            self.confirmPasswordTextField.setError("Passwords do not match")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.presentAlert(title: error.localizedDescription, message: nil)
            } else {
                print("Successful sign-up")
                LoginManager.instance.dismissLogin()
            }
        }
    }
    
    @IBAction func signIn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissLogin() {
        LoginManager.instance.dismissLogin()
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.confirmPasswordTextField.becomeFirstResponder()
        } else if textField == self.confirmPasswordTextField {
            self.confirmPasswordTextField.resignFirstResponder()
            signUp()
        }
        return true
    }
}
