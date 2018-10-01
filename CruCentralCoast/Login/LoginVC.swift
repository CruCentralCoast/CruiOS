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
    @IBOutlet weak var signInButton: CruButton!
    @IBOutlet weak var facebookButton: CruImageButton!
    @IBOutlet weak var googleButton: CruImageButton!
    
    var fbSignInDelegate: FBSignInDelegate?
    
    override var viewNotCoveredByKeyboard: UIView? { return self.signInButton }
    override var keyboardOffset: CGFloat { return 10 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let googleGray = UIColor(white: 117/255.0, alpha: 1.0)
        self.googleButton.layer.borderWidth = 0.5
        self.googleButton.layer.borderColor = googleGray.cgColor
        self.facebookButton.layer.borderWidth = 0.5
        self.facebookButton.layer.borderColor = googleGray.cgColor
        
        // Use this to display spinner while waiting for app switch to occur
        // Need to implement the methods of the delegate protocol
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        // Adjust screen position if keyboard is shown
        self.listenForKeyboardEvents()
    }
    
    @IBAction func signIn() {
        self.view.endEditing(true)
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
        let forgotPasswordVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(ForgotPasswordVC.self)
        forgotPasswordVC.email = self.emailTextField.text
        self.show(forgotPasswordVC, sender: self)
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
            self.passwordTextField.resignFirstResponder()
            self.signIn()
        }
        return true
    }
}

// Use this to display a spinner while waiting for app switch to occur
extension LoginVC: GIDSignInUIDelegate {}
