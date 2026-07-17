//
//  AppDelegate.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/24/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

// Local notification permission/authorization handling. Remote/push notifications
// (e.g. opponent-move alerts while the app is closed) are a separate, later step.
struct NotificationManager {
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // handle Google Sign-In callback
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
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
