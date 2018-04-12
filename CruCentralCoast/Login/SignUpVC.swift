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
    
    var email: String? { didSet { self.emailTextField?.text = self.email } }
    var password: String?  { didSet { self.passwordTextField?.text = self.password } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.setText(self.email)
        self.passwordTextField.setText(self.password)
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
    }

    @IBAction func signUp() {
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
            }
        }
    }
    
    @IBAction func signIn() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            signUp()
        }
        return true
    }
}
