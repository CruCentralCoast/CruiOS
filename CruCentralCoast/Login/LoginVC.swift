//
//  LoginVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: CruTextField!
    @IBOutlet weak var passwordTextField: CruTextField!
    
    var fbSignInDelegate: FBSignInDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use this to display spinner while waiting for app switch to occur
        // Need to implement the methods of the delegate protocol
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func signIn() {
        self.emailTextField.validateHasText()
        self.passwordTextField.validateHasText()
        
        guard let email = self.emailTextField.text, !email.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.presentAlert(title: error.localizedDescription, message: nil)
            } else {
                print("Successful login")
                LoginManager.instance.dismissLogin()
            }
        }
    }
    
    @IBAction func signInWithFacebook() {
        guard let fbSignInDelegate = self.fbSignInDelegate else { return }
        
        let fbLoginManager = FBSDKLoginManager.init()
        let readPermissions = ["public_profile", "email"]
        fbLoginManager.logIn(withReadPermissions: readPermissions, from: self, handler: fbSignInDelegate.didSignIn)
    }
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func forgotPassword() {
        // TODO
        self.presentAlert(title: "Forgot Password", message: "Coming Soon...")
    }
    
    @IBAction func signUp() {
        let signUpVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(SignUpVC.self)
        signUpVC.email = self.emailTextField.text
        signUpVC.password = self.passwordTextField.text
        self.show(signUpVC, sender: self)
    }
    
    @IBAction func dismissLogin() {
        LoginManager.instance.dismissLogin()
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.signIn()
        }
        return true
    }
}

// Use this to display a spinner while waiting for app switch to occur
extension LoginVC: GIDSignInUIDelegate {}
