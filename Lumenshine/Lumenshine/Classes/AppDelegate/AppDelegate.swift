//
//  AppDelegate.swift
//  jupiter
//
//  Created by Razvan Chelemen on 25/01/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import stellarsdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var webSocketService: WebSocketService {
        get {
            return Services.shared.webSocketService
        }
    }
    
    fileprivate let mainCoordinator = MainCoordinator()
    fileprivate var snapshotView: UIView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        
        registerForPushNotifications()
        
        // for testing purpose
//        let loginCoordinator = MenuCoordinator(mainCoordinator: mainCoordinator, user: User(id: "1", email: "isti@isti.com", publicKeyIndex0: "publicKeyIndex0", publicKeys: nil))
        
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator)
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loginCoordinator.baseController
        window?.makeKeyAndVisible()
        
        let jailbreakChecker = JailbreakChecker()
        jailbreakChecker.checkDeviceForJailbreak()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        application.ignoreSnapshotOnNextApplicationLaunch()
        if let window = self.window {
            
            let snapshotView = UINib(nibName: "LockedView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
            snapshotView.frame = window.frame
            window.addSubview(snapshotView)
            self.snapshotView = snapshotView
        }
        
        webSocketService.disconnectWebSocket()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        snapshotView?.removeFromSuperview()
        snapshotView = nil
        webSocketService.connectWebSocket()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: APNs
extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        NotificationCenter.default.post(name: Notification.Name(Keys.Notifications.DeviceToken), object: nil, userInfo: [Keys.UserDefs.DeviceToken:token])
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        let viewAction = UNNotificationAction(identifier: Keys.NotificationActions.View,
                                              title: R.string.localizable.push_view(),
                                              options: [.foreground])
        
        let cancelAction = UNNotificationAction(identifier: Keys.NotificationActions.Cancel,
                                                title: R.string.localizable.cancel(),
                                                options: [.destructive])
        
        let category = UNNotificationCategory(identifier: Keys.NotificationCategories.General,
                                                  actions: [viewAction, cancelAction],
                                                  intentIdentifiers: [],
                                                  options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let walletKey = userInfo["wallet_key"] as? String,
            response.actionIdentifier == Keys.NotificationActions.View {
            UserDefaults.standard.setValue(walletKey, forKey: Keys.UserDefs.ShowWallet)
            
            NotificationCenter.default.post(name: Notification.Name(Keys.Notifications.ScrollToWallet), object: nil, userInfo:nil)
        }
        
        completionHandler()
    }
}
