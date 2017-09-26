//
//  NotificationManager.swift
//  Cru
//
//  Created by Tyler Dahl on 9/23/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private override init() {}
}

extension NotificationManager {
    func registerForRemoteNotifications(_ application: UIApplication) {
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
        
        // Configure Firebase Messaging
        FirebaseApp.configure()
        
        // Setup listeners for Firebase actions
        NotificationCenter.default.addObserver(self, selector: #selector(self.onTokenRefresh), name: .InstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataMessageFailure(notification:)), name: .MessagingSendError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataMessageSuccess(notification:)), name: .MessagingSendSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDeleteMessagesOnServer), name: .MessagingMessagesDeleted, object: nil)
    }
    
    fileprivate func handleNotification(title: String? = nil, body: String?, userInfo: [AnyHashable : Any]? = nil, presentLocalNotification: Bool = false) {
        // Present a local notification
        if presentLocalNotification {
            self.presentLocalNotification(title: title, body: body, userInfo: userInfo)
        }
        
        // Refresh the rides page
        if title == "Cru Ride Sharing" {
            NotificationCenter.default.post(name: Config.notificationRidesUpdated, object: nil)
        }
        
        // Save the notification
        self.saveNotification(title: title, body: body)
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
        var notifications = self.getSavedNotifications()
        notifications.append(notification)

        // Save the updated list of notifications
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notifications, toFile: Notification.ArchiveURL.path)

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
extension NotificationManager: UNUserNotificationCenterDelegate {
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
extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Refreshed FCM token: \(fcmToken)")
        CruClients.getSubscriptionManager().saveFCMToken(fcmToken)
        CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received FCM message: \(remoteMessage.appData)")
    }
}

extension NotificationManager {
    func saveNotifications(_ notifications: [Notification]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notifications, toFile: Notification.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save notifications...")
        }
    }
    
    func getSavedNotifications() -> [Notification] {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Notification.ArchiveURL.path) as? [Notification] ?? []
    }
}

// Push Notification methods on the App Delegate
extension AppDelegate {
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        if let token = InstanceID.instanceID().token() {
            print("FCM Token: \(token)")
            CruClients.getSubscriptionManager().saveFCMToken(token)
            CruClients.getSubscriptionManager().subscribeToTopic(Config.globalTopic)
        }
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
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
        NotificationManager.shared.handleNotification(title: title, body: body, userInfo: userInfo, presentLocalNotification: true)
        
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        handler(.noData);
    }
}
