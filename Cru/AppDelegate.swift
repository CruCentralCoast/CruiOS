
//  AppDelegate.swift
//  Cru
//
//  Created by Deniz Tumer on 11/5/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import Appsee
import AWSCognito


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var subscribedToTopic = false
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    var notifications = [Notification]()
    var ridesPage : RidesViewController?
    
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self, Appsee.self, Answers.self])
        // TODO: Move this to where you establish a user session
        self.logUser()

        // Register for remote notifications
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Setup the Firebase Cloud Messaging service
        FirebaseApp.configure()
        NotificationCenter.default.addObserver(self, selector: #selector(onTokenRefresh), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendDataMessageFailure(notification:)), name: NSNotification.Name.MessagingSendError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendDataMessageSuccess(notification:)), name: NSNotification.Name.MessagingSendSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteMessagesOnServer), name: NSNotification.Name.MessagingMessagesDeleted, object: nil)
        
        //Initialize Google Places
        GMSPlacesClient.provideAPIKey(Config.googleAPIKey)
        GMSServices.provideAPIKey(Config.googleAPIKey)
        
        //IQKeyboardManager makes keyboards play nicely with textfields usually covered by keyboard
        IQKeyboardManager.sharedManager().enable = true
        
        // Set up AWS S3 stuff
        //let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2, identityPoolId:"us-west-2:23478422-d01b-4f71-8da2-4d8b1d4dc2d7")
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest1, identityPoolId: Config.s3IdentityPoolID)
        
        let configuration = AWSServiceConfiguration(region:.USWest1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
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

    
    func applicationDidBecomeActive( _ application: UIApplication) {
        // Connect to the GCM server to receive non-APNS notifications
//        GCMService.sharedInstance().connect(handler: {
//            (error) -> Void in
//            if error != nil {
//                print("Could not connect to GCM: \(error?.localizedDescription)")
//            } else {
//                self.connectedToGCM = true
//                print("Connected to GCM")
//                if(self.registrationToken != nil) {
//                    CruClients.getSubscriptionManager().saveFCMToken(self.registrationToken!)
//                    CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
//                }
//            }
//        })
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        InstanceID.instanceID().token()
        
//            // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
//            let instanceIDConfig = GGLInstanceIDConfig.default()
//            instanceIDConfig?.delegate = self
//        
//            // Start the GGLInstanceID shared instance with that config and request a registration
//            // token to enable reception of notifications
//            GGLInstanceID.sharedInstance().start(with: instanceIDConfig)
//            registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject,
//                kGGLInstanceIDAPNSServerTypeSandboxOption:true as AnyObject]
//            GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
//                scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
        let userInfo = ["error": error.localizedDescription]
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: registrationKey), object: nil, userInfo: userInfo)
    }
    
    func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Notification received: \(userInfo)")
        // Handle the received message
        if let apsDict = userInfo["aps"] as? [String : AnyObject]{
            if let alertDict = apsDict["alert"] as? [String : AnyObject]{
                if let alert = alertDict["body"] as? String{
                    if let alertTitle = alertDict["title"] as? String{
                        //Insert it into the notifications array
                        notifications.append(Notification(title: alertTitle, content: alert, dateReceived: Date())!)
                        
                        
                        let alertControl = UIAlertController(title: alert, message: "", preferredStyle: UIAlertControllerStyle.alert)
                        alertControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.window?.rootViewController!.present(alertControl, animated: true, completion: {
                            
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
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: messageKey), object: nil, userInfo: userInfo)
    }
    
    func saveNotifications() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notifications, toFile: Notification.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save notifications...")
        }
    }
    
    func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Notification received from fetcher: \(userInfo)")

        let title = userInfo["title"] as! String
        let body = userInfo["body"] as! String
    
        //Insert it into the notifications array
        notifications.append(Notification(title: title, content: body, dateReceived: Date())!)
        
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = body // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = userInfo
        
        UIApplication.shared.scheduleLocalNotification(notification)
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
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: messageKey), object: nil,
            userInfo: userInfo)
        handler(UIBackgroundFetchResult.noData);
    }
    
//    func registrationHandler(_ registrationToken: String?, error: Error?) {
//        if let registrationToken = registrationToken {
//            CruClients.getSubscriptionManager().saveFCMToken(registrationToken)
//            self.registrationToken = registrationToken
//            print("Registration Token: \(registrationToken)")
//            if (connectedToGCM) {
//                CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
//            }
//            let userInfo = ["registrationToken": registrationToken]
//            NotificationCenter.default.post(
//                name: Foundation.Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
//        } else if let error = error {
//            print("Registration to GCM failed with error: \(error.localizedDescription)")
//            let userInfo = ["error": error.localizedDescription]
//            NotificationCenter.default.post(
//                name: Foundation.Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
//        }
//    }
    
    func onTokenRefresh() {
        // Get the default token if the earlier default token was nil. If the we already
        // had a default token most likely this will be nil too. But that is OK we just
        // wait for another notification of this type.
        print("The Firebase Cloud Messaging token needs to be refreshed. Refreshing now.")
        InstanceID.instanceID().token()
    }
    
    func sendDataMessageFailure(notification: Notification) {
        print("ERROR: Message failed to send: \(notification.content)")
    }
    
    func sendDataMessageSuccess(notification: Notification) {
        print("SUCCESS: Message sent: \(notification.content)")
    }
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the FCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    
    
    
    
    
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hopscotch.Cru" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Cru", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

