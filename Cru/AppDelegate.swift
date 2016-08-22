
//  AppDelegate.swift
//  Cru
//
//  Created by Deniz Tumer on 11/5/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import CoreData
import WildcardSDK
import IQKeyboardManagerSwift
import Google
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import Appsee


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?

    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    var notifications = [Notification]()
    var ridesPage : RidesViewController?
    
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self, Appsee.self, Answers.self])
        // TODO: Move this to where you establish a user session
        self.logUser()

        // Configure the Google context: parses the GoogleService-Info.plist, and initializes
        // the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        // Register for remote notifications
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        
        //Initialize Google Places
        GMSPlacesClient.provideAPIKey(Config.googleAPIKey)
        GMSServices.provideAPIKey(Config.googleAPIKey)
        
        
        //Initialize WildcardSDK with Cru API key for Resources and change font
        WildcardSDK.initializeWithApiKey("4f154853-1955-4422-9aa3-f1fbd89d3403")
        WildcardSDK.cardTitleFont = UIFont(name: "FreightSansProMedium-Regular", size: 18.0)!
        WildcardSDK.cardDescriptionFont = UIFont(name: "FreightSansProBook-Regular", size: 13.0)!
        WildcardSDK.cardActionButtonFont = UIFont(name: "FreightSansProBook-Regular", size: 12.0)!
        WildcardSDK.cardKickerFont = UIFont(name: "FreightSansProMedium-Regular", size: 11.0)!
        
        //IQKeyboardManager makes keyboards play nicely with textfields usually covered by keyboard
        IQKeyboardManager.sharedManager().enable = true
        
        return true
    }
    
    func onUserSessionStarted() {
        Appsee.setUserID("User1234");

    }
    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
        Crashlytics.sharedInstance().setUserIdentifier("12345")
        Crashlytics.sharedInstance().setUserName("Test User")
    }

    
    func applicationDidBecomeActive( application: UIApplication) {
        // Connect to the GCM server to receive non-APNS notifications
        GCMService.sharedInstance().connectWithHandler({
            (error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                if(self.registrationToken != nil) {
                    CruClients.getSubscriptionManager().saveGCMToken(self.registrationToken!)
                    CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
                }
            }
        })
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        //GCMService.sharedInstance().disconnect()
        //self.connectedToGCM = false
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: NSData ) {
            // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
            let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
            instanceIDConfig.delegate = self
            // Start the GGLInstanceID shared instance with that config and request a registration
            // token to enable reception of notifications
            GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
            registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                kGGLInstanceIDAPNSServerTypeSandboxOption:true]
            GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                registrationKey, object: nil, userInfo: userInfo)
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            print("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
        if let apsDict = userInfo["aps"] as? [String : AnyObject]{
            if let alertDict = apsDict["alert"] as? [String : AnyObject]{
                if let alert = alertDict["body"] as? String{
                    if let alertTitle = alertDict["title"] as? String{
                        //Insert it into the notifications array
                        notifications.append(Notification(title: alertTitle, content: alert, dateReceived: NSDate())!)
                        
                        
                        let alertControl = UIAlertController(title: alert, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        alertControl.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.window?.rootViewController!.presentViewController(alertControl, animated: true, completion: {
                            
                            if (alertTitle == "Cru Ride Sharing" && self.ridesPage != nil){
                                self.ridesPage?.refresh()
                            }
                        })
                    }
                }
            }
        }
        
        // Handle the received message
        saveNotifications()
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
    }
    
    func saveNotifications() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notifications, toFile: Notification.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save notifications...")
        }
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
            print("Notification received from fetcher: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            let title = userInfo["title"] as! String
            let body = userInfo["body"] as! String
        
            //Insert it into the notifications array
            notifications.append(Notification(title: title, content: body, dateReceived: NSDate())!)
        
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = body // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = userInfo
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        if (self.ridesPage != nil){
            self.ridesPage?.refresh()
        }
        
            /*let alertControl = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
            alertControl.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.window?.rootViewController!.presentViewController(alertControl, animated: true, completion: {
            
                if (self.ridesPage != nil){
                    self.ridesPage?.refresh()
                }
            })*/
        
            // Handle the received message
            saveNotifications()
            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            handler(UIBackgroundFetchResult.NoData);
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            CruClients.getSubscriptionManager().saveGCMToken(registrationToken)
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            if (connectedToGCM) {
                CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
            }
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
            print("\(error)")
        } else {
            // Will send message, you can save the messageID to track the message
            print("Will send message with no errors?")
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
        print("Successfully sent message.")
    }
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hopscotch.Cru" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Cru", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

