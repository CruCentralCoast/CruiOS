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
    }

    @IBAction func signUp() {
        guard let email = self.emailTextField.text, !email.isEmpty else {
            //            self.emailTextField.error("Email field cannot be empty.")
            debugPrint("Email field cannot be empty.")
            self.presentAlert(title: "Email field cannot be empty.", message: nil)
            return
        }
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            //            self.passwordTextField.error("Password field cannot be empty.")
            debugPrint("Password field cannot be empty.")
            self.presentAlert(title: "Password field cannot be empty.", message: nil)
            return
        }
        guard let password2 = self.passwordTextField.text, !password.isEmpty else {
            //            self.confirmPasswordTextField.error("Password field cannot be empty.")
            debugPrint("Confirm Password field cannot be empty.")
            self.presentAlert(title: "Confirm Password field cannot be empty.", message: nil)
            return
        }
        guard password == password2 else {
            debugPrint("Passwords do not match.")
            self.presentAlert(title: "Passwords do not match.", message: nil)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.presentAlert(title: error.localizedDescription, message: nil)
            } else {
                debugPrint("Successful login")
            }
        }
        //        Auth.auth().createUser(withEmail: "", password: "") { (user, error) in
        //
        //        }
        //        Auth.auth().createUserAndRetrieveData(withEmail: "", password: "") { (data, error) in
        //
        //        }
    }
    
    @IBAction func signIn() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signIn()
        }
        return true
    }
}
