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

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Local notification permission/authorization handling, plus remote (push)
// notification registration. The resulting APNs device token is stored per-user
// in Firestore so a Cloud Function can later push opponent-move alerts.
struct NotificationManager {
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    #if canImport(UIKit)
                    UIApplication.shared.registerForRemoteNotifications()
                    #elseif os(macOS)
                    NSApplication.shared.registerForRemoteNotifications()
                    #endif
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

#if canImport(UIKit)
class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
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
#elseif os(macOS)
// Native macOS has no Home Screen quick actions, so the UIApplicationShortcutItem
// handling above doesn't carry over; everything else (Firebase, push registration,
// Google Sign-In URL callback) has a direct AppKit/NSApplicationDelegate equivalent.
class AppDelegate: NSObject, NSApplicationDelegate, MessagingDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Messaging.messaging().delegate = self

        // if the user already granted notification permission in a previous session,
        // re-register for a device token (APNs tokens can change, e.g. after reinstall)
        NotificationManager.authorizationStatus { status in
            if status == .authorized {
                NSApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // handle Google Sign-In callback
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            _ = GIDSignIn.sharedInstance.handle(url)
        }
    }

    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        AuthViewModel.shared.updateDeviceTokenInFirestore(token: token)
        Messaging.messaging().apnsToken = deviceToken
    }

    // called whenever FCM (re)generates the registration token used to target this device
    // from a Cloud Function via the Firebase Admin SDK
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task { @MainActor in
            AuthViewModel.shared.updateFCMTokenInFirestore(token: fcmToken)
        }
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
#endif

@main
struct ChexxApp: App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif

    init() {
        // Configured here, rather than in AppDelegate's launch callback, since
        // SwiftUI can construct MainMenuView's @StateObject AuthViewModel (which
        // touches Firestore/Auth at init) before that callback fires — App.init()
        // is guaranteed to run first on every platform.
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        #if os(macOS)
        .defaultSize(width: 550, height: 550)
        #endif
    }
}
