//
//  AppDelegate.swift
//  PushNotifications
//
//  Created by Mert Karabulut on 22.11.2020.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        registerForPushNotifications()

        // Is app launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject],
           let payload = notification["aps"] as? [String: AnyObject] {
            // Handle your payload
            print("Launched from notification:\n\(payload)")
        }

        return true
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

// MARK: - Push Notifications
extension AppDelegate {
    func registerForPushNotifications() {
        let center =  UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(
            options: options) { [weak self] (granted, error) in
            if let error = error {
                // Handle the error here.
                print("registerForPushNotifications - Error: \(error)")
            }

            // Enable or disable features based on the authorization.
            print("registerForPushNotifications - Granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        let center =  UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            print("getNotificationSettings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("didRegisterForRemoteNotificationsWithDeviceToken Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError Error: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let payload = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        // Handle your payload
        print("didReceiveRemoteNotification:\n\(payload)")
    }
}
