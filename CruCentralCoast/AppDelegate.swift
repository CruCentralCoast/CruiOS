//
//  AppDelegate.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 2/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google sign-in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = LoginManager.instance
        
        // Configure Facebook sign-in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Present welcome screen if first app launch
        if LocalStorage.preferences.getObject(forKey: .onboarded) == nil {
            DispatchQueue.main.async {
                let introVC = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(IntroPageContainerVC.self)
                self.window?.rootViewController?.present(introVC, animated: true, completion: nil)
            }
        }
        
        // Set the app tint color
        self.window?.tintColor = .cruBrightBlue
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Allow login flows to link back to this app
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: [:]) {
            return true
        } else if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: [:]) {
            return true
        }
        
        // other URL handling goes here.
        return false
    }
}
