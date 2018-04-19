//
//  LoginManager.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/15/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

protocol FBSignInDelegate {
    func didSignIn(withResult result: FBSDKLoginManagerLoginResult?, withError error: Error?)
}

class LoginManager: NSObject {
    
    static let instance = LoginManager()
    
    var user: User? { return Auth.auth().currentUser }
    
    // Use weak to avoid strong retain cycles, which cause memory leaks
    weak var loginScreen: UIViewController?
    
    private override init() {}
    
    func presentLogin(from viewController: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        if self.loginScreen != nil {
            print("ERROR: Failed to present login screen. Login screen already exists.")
            return
        }
        guard let viewController = viewController else {
            print("ERROR: Tried to present login screen from nil view controller.")
            return
        }
        let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(LoginVC.self)
        loginVC.fbSignInDelegate = self
        self.loginScreen = loginVC
        viewController.present(loginVC, animated: animated, completion: completion)
    }
    
    func dismissLogin(animated: Bool = true, completion: (() -> Void)? = nil) {
        // Dismiss from presenting view controller in order to dismiss entire stack of login view controllers
        self.loginScreen?.presentingViewController?.dismiss(animated: animated) {
            self.loginScreen = nil
            completion?()
        }
    }
}

extension LoginManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Sign in user with Firebase
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // User is signed in
            print("Successful Google sign-in")
            LoginManager.instance.dismissLogin()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
}

extension LoginManager: FBSignInDelegate {
    func didSignIn(withResult result: FBSDKLoginManagerLoginResult?, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let result = result, !result.isCancelled else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: result.token.tokenString)
        
        // Sign in user with Firebase
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // User is signed in
            print("Successful Facebook sign-in")
            LoginManager.instance.dismissLogin()
        }
    }
}
