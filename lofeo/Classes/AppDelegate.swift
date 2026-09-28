//
//  AppDelegate.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 20/02/26.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging


@main
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate{
    var loadingWindow: UIWindow?
    var window: UIWindow?
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()

             // Notification Permission
             UNUserNotificationCenter.current().delegate = self
             let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

             UNUserNotificationCenter.current().requestAuthorization(
                 options: authOptions,
                 completionHandler: { _, _ in }
             )

             application.registerForRemoteNotifications()

             // Messaging Delegate
             Messaging.messaging().delegate = self

             return true
    }
    
    // MARK: - APNs Token
        func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

            Messaging.messaging().apnsToken = deviceToken
        }

    // MARK: - FCM Token
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

            print("FCM Token: \(fcmToken ?? "")")

            // 👉 Subscribe to topic here
            subscribeToTopic()
        }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        print("Background notification")
        print(userInfo)
    }
    
    func subscribeToTopic() {
            Messaging.messaging().subscribe(toTopic: "news") { error in
                if let error = error {
                    print("Subscription failed: \(error)")
                } else {
                    print("Subscribed to news topic")
                }
            }
        }
        
  
    
    // MARK: - Foreground Notification
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
            
            print("📩 Notification received (foreground)")
            print(notification.request.content.userInfo)
            completionHandler([.alert, .badge, .sound])
        }
    
    // MARK: - Notification Click
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {

            let userInfo = response.notification.request.content.userInfo
            print("Notification Clicked: \(userInfo)")

            completionHandler()
        }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

