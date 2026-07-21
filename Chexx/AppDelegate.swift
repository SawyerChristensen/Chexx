//
//  AppDelegate.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/24/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import UserNotifications

// Local notification permission/authorization handling, plus remote (push)
// notification registration. The resulting APNs device token is stored per-user
// in Firestore so a Cloud Function can later push opponent-move alerts.
struct NotificationManager {
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(granted)
            }
        }
    }

    static func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // if the user already granted notification permission in a previous session,
        // re-register for a device token (APNs tokens can change, e.g. after reinstall)
        NotificationManager.authorizationStatus { status in
            if status == .authorized {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        // cold launch via a Home Screen quick action: stash it and tell the
        // system we've handled it ourselves rather than also calling
        // performActionFor for this same launch
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            QuickActionManager.shared.pendingAction = QuickAction(rawValue: shortcutItem.type)
            return false
        }

        return true
    }

    // Home Screen quick action tapped while the app was already running/suspended
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let action = QuickAction(rawValue: shortcutItem.type)
        QuickActionManager.shared.pendingAction = action
        completionHandler(action != nil)
    }

    // handle Google Sign-In callback
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        AuthViewModel.shared.updateDeviceTokenInFirestore(token: token)
        Messaging.messaging().apnsToken = deviceToken
    }

    // called whenever FCM (re)generates the registration token used to target this device
    // from a Cloud Function via the Firebase Admin SDK
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        AuthViewModel.shared.updateFCMTokenInFirestore(token: fcmToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Pause tasks, disable timers, or save application state if necessary
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Release shared resources or save data
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Undo background changes
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks paused (or not started) while the app was inactive
    }
}

@main
struct ChexxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 550, height: 550)
        #endif
    }
}
