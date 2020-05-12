//
//  AppDelegate.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import UserNotifications
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        OneSignal.initWithLaunchOptions(launchOptions,
        appId: "",
        handleNotificationAction: nil,
        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

        OneSignal.promptForPushNotifications(userResponse: { accepted in
       // print("User accepted notifications: \(accepted)")
        })
        
		return true
	}

	// MARK: UISceneSession Lifecycle

	@available(iOS 13.0, *)
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	@available(iOS 13.0, *)
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
         UIApplication.shared.applicationIconBadgeNumber = 0
	}
    
    func applicationWillResignActive(_ application: UIApplication) {
         UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
         UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async
        {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        
     
    }

    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
     
    }
}

