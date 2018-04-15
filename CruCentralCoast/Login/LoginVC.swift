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
    
    private var authListenerHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use this to display spinner while waiting for app switch to occur
        // Need to implement the methods of the delegate protocol
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Dismiss keyboard if view is tapped
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if the user is already logged in
        self.authListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            print(user?.displayName, user?.email, user?.phoneNumber, user?.photoURL, user?.metadata, user?.providerID)
//            if let user = user {
//                print(user.metadata.creationDate, user.metadata.lastSignInDate)
//                for providerData in user.providerData {
//                    print(providerData.displayName, providerData.email, providerData.phoneNumber, providerData.photoURL, providerData.providerID)
//                }
//            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(self.authListenerHandle)
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
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            signIn()
        }
        return true
    }
}

// Use this to display a spinner while waiting for app switch to occur
extension LoginVC: GIDSignInUIDelegate {

}
