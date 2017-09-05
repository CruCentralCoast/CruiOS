
//  AppDelegate.swift
//  Cru
//
//  Created by Deniz Tumer on 11/5/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Fabric
import Crashlytics
import Appsee
import AWSCognito
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var notifications = [Notification]()
    weak var ridesPage : RidesViewController?
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self, Appsee.self, Answers.self])
        // TODO: Move this to where you establish a user session
        self.logUser()

        // Register for remote notifications
        self.registerForPushNotifications(application)
        
        // Initialize Google Places
        GMSPlacesClient.provideAPIKey(Config.googleAPIKey)
        GMSServices.provideAPIKey(Config.googleAPIKey)
        
        // IQKeyboardManager makes keyboards play nicely with textfields usually covered by keyboard
        IQKeyboardManager.sharedManager().enable = true
        
        // Set up AWS S3 stuff
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2, identityPoolId: Config.s3IdentityPoolID)
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

// MARK: - Push Notifications
extension AppDelegate {
    fileprivate func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        // Setup listeners for Firebase actions
        NotificationCenter.default.addObserver(self, selector: #selector(self.onTokenRefresh), name: .InstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataMessageFailure(notification:)), name: .MessagingSendError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataMessageSuccess(notification:)), name: .MessagingSendSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDeleteMessagesOnServer), name: .MessagingMessagesDeleted, object: nil)
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        if let token = InstanceID.instanceID().token() {
            CruClients.getSubscriptionManager().saveFCMToken(token)
            CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
        }
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
        
        let userInfo = ["error": error.localizedDescription]
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
    }
    
    func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification received: \(userInfo)")
        
        var title = userInfo["title"] as? String
        var body = userInfo["body"] as? String
        
        if let apsDict = userInfo["aps"] as? [String : AnyObject] {
            if let alertDict = apsDict["alert"] as? [String : AnyObject] {
                title = alertDict["title"] as? String
                body = alertDict["body"] as? String
            }
        }
        
        // Handle the notification
        self.handleNotification(title: title, body: body, userInfo: userInfo, presentLocalNotification: true)
        
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        handler(.noData);
    }
    
    fileprivate func handleNotification(title: String? = nil, body: String?, userInfo: [AnyHashable : Any]? = nil, presentLocalNotification: Bool = false) {
        // Present a local notification
        if presentLocalNotification {
            self.presentLocalNotification(title: title, body: body, userInfo: userInfo)
        }
        
        // Refresh the rides page if we are on it
        if title == "Cru Ride Sharing", let ridesPage = self.ridesPage {
            ridesPage.refresh()
        }
        
        // Handle the received message
        saveNotification(title: title, body: body)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: self.messageKey), object: nil, userInfo: userInfo)
    }
    
    fileprivate func presentLocalNotification(title: String?, body: String?, userInfo: [AnyHashable : Any]? = nil) {
        guard let body = body else { return }
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            if let title = title {
                content.title = title
            }
            content.body = body
            content.sound = UNNotificationSound.default()
            if let userInfo = userInfo {
                content.userInfo = userInfo
            }
            
            let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: nil)
            
            // Present the notification
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        } else {
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = body
            notification.alertAction = "Open"
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = userInfo
            
            // Present the notification
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func saveNotification(title: String?, body: String?, date: Date = Date()) {
        guard let notification = Notification(title: title, content: body, dateReceived: date) else { return }
        
        // Append the new notification
        self.notifications.append(notification)
        
        // Save the updated list of notifications
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.notifications, toFile: Notification.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save notifications...")
        }
    }
    
    func onTokenRefresh() {
        // Get the default token if the earlier default token was nil. If the we already
        // had a default token most likely this will be nil too. But that is OK we just
        // wait for another notification of this type.
        print("Refreshed the Firebase Cloud Messaging token.")
        if let token = InstanceID.instanceID().token() {
            CruClients.getSubscriptionManager().saveFCMToken(token)
            CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
        }
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
}

// A protocol to handle notifications for devices running iOS 10 or above
extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Will present notification: \(notification.request.content.body)")
        
        var title: String?
        let body = notification.request.content.body
        let userInfo = notification.request.content.userInfo
        
        if let titleIndex = notification.request.content.userInfo.index(forKey: "google.c.a.c_l") {
            title = notification.request.content.userInfo[titleIndex].value as? String
        }
        
        // Handle the notification
        self.handleNotification(title: title, body: body, userInfo: userInfo)
        
        // Invoke the completion handler
        completionHandler(.alert)
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification: \(response.notification.request.content.body)")
        
        var title: String?
        let body = response.notification.request.content.body
        let userInfo = response.notification.request.content.userInfo
        
        if let titleIndex = response.notification.request.content.userInfo.index(forKey: "google.c.a.c_l") {
            title = response.notification.request.content.userInfo[titleIndex].value as? String
        }
        
        // Handle the notification
        self.handleNotification(title: title, body: body, userInfo: userInfo)
        
        // Invoke the completion handler
        completionHandler()
    }
}

// A protocol to handle events from FCM for devices running iOS 10 or above
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Refreshed FCM token: \(fcmToken)")
        CruClients.getSubscriptionManager().saveFCMToken(fcmToken)
        CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received FCM message: \(remoteMessage.appData)")
    }
}

