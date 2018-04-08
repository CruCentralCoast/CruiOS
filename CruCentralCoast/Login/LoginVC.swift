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
    
    private var authListenerHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use this to display spinner while waiting for app switch to occur
        // Need to implement the methods of the delegate protocol
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
        
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.authListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print(user?.displayName, user?.email, user?.phoneNumber, user?.photoURL, user?.metadata, user?.providerID)
            if let user = user {
                print(user.metadata.creationDate, user.metadata.lastSignInDate)
                for providerData in user.providerData {
                    print(providerData.displayName, providerData.email, providerData.phoneNumber, providerData.photoURL, providerData.providerID)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(self.authListenerHandle)
    }
    
    @IBAction func signIn() {
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
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.presentAlert(title: error.localizedDescription, message: nil)
            } else {
                debugPrint("Successful login")
            }
        }
    }
    
    @IBAction func signInWithFacebook() {
        let fbLoginManager = FBSDKLoginManager.init()
        let readPermissions = ["public_profile", "email"]
        fbLoginManager.logIn(withReadPermissions: readPermissions, from: self) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let result = result {
                let credential = FacebookAuthProvider.credential(withAccessToken: result.token.tokenString)
                
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    // User is signed in
                    print("Successful Facebook sign-in")
                }
            }
        }
    }
    
    @IBAction func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func forgotPassword() {
        
    }
    
    @IBAction func signUp() {
        // push to sign up screen
//        Auth.auth().createUser(withEmail: "", password: "") { (user, error) in
//
//        }
//        Auth.auth().createUserAndRetrieveData(withEmail: "", password: "") { (data, error) in
//
//        }
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signIn()
        }
        return true
    }
}

extension LoginVC: GIDSignInUIDelegate {
    
}
