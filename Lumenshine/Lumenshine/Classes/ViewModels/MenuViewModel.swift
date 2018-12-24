//
//  MenuViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UIApplication

protocol MenuViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    func name(at indexPath: IndexPath) -> String?
    func iconName(at indexPath: IndexPath) -> String
    func isAvatar(at indexPath: IndexPath) -> Bool
    
    func menuItemSelected(at indexPath: IndexPath)
}

class MenuViewModel : MenuViewModelType {
    
    static var backgroudTimePeriod: TimeInterval = 10
    fileprivate let user: User
    fileprivate let entries: [[MenuEntry]]
    fileprivate var backgroundTime: Date?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(user: User) {
        self.user = user
        
        self.entries = [[.avatar],
         [.home, .wallets, .transactions, .contacts, .settings, .extras],
         [.help, .signOut]]
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notification:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePushToken(notification:)), name: Notification.Name(Keys.Notifications.DeviceToken), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToWallet(notification:)), name: Notification.Name(Keys.Notifications.ScrollToWallet), object: nil)

        loginCompleted()
    }
    
    deinit {
        removeObservers()
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    func name(at indexPath: IndexPath) -> String? {
        return isAvatar(at: indexPath) ? user.email : entry(at: indexPath).name
    }
    
    func iconName(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).icon.name
    }
    
    func isAvatar(at indexPath: IndexPath) -> Bool {
        return entry(at: indexPath) == .avatar
    }
    
    func menuItemSelected(at indexPath:IndexPath) {
        switch entry(at: indexPath) {
        case .avatar, .settings:
            navigationCoordinator?.performTransition(transition: .showSettings)
        case .extras:
            navigationCoordinator?.performTransition(transition: .showExtras)
        case .home:
            navigationCoordinator?.performTransition(transition: .showHome)
        case .contacts:
            navigationCoordinator?.performTransition(transition: .showContacts)
        case .signOut:
            logout()
        case .help:
            navigationCoordinator?.performTransition(transition: .showHelp)
        case .wallets:
            navigationCoordinator?.performTransition(transition: .showWallets)
        case .transactions:
            navigationCoordinator?.performTransition(transition: .showTransactions)
        default: break
        }
    }
}

// MARK: Notifications
fileprivate extension MenuViewModel {
    @objc
    func appWillEnterForeground(notification: Notification) {
        showRelogin()
    }
    
    @objc
    func appDidEnterBackground(notification: Notification) {
        countBackgroundTime()
    }
    
    @objc
    func updatePushToken(notification: Notification) {
        
        if let notifications = UserDefaults.standard.value(forKey: Keys.UserDefs.Notifications) as? Bool {
            if notifications == false { return }
        } else {
            UserDefaults.standard.setValue(true, forKey: Keys.UserDefs.Notifications)
        }
        
        if let newToken = notification.userInfo?[Keys.UserDefs.DeviceToken] as? String {
            if let deviceToken = UserDefaults.standard.value(forKey: Keys.UserDefs.DeviceToken) as? String,
                newToken != deviceToken {
                Services.shared.push.update(newPushToken: newToken, oldPushToken: deviceToken) { result in
                    switch result {
                    case .failure(let error):
                        print("Push update error: \(error)")
                    default:
                        break
                    }
                }
            } else {
                Services.shared.push.subscribe(pushToken: newToken) { result in
                    switch result {
                    case .failure(let error):
                        print("Push Subscribe error: \(error)")
                    default:
                        break
                    }
                }
            }
            UserDefaults.standard.setValue(newToken, forKey: Keys.UserDefs.DeviceToken)
        } else {
            UserDefaults.standard.setValue(false, forKey: Keys.UserDefs.Notifications)
        }
    }
    
    @objc
    func scrollToWallet(notification: Notification) {
        if let walletPublicKey = UserDefaults.standard.value(forKey: Keys.UserDefs.ShowWallet) as? String {
            self.showWallet(publicKey: walletPublicKey)
        }
    }    
}

fileprivate extension MenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func logout() {
        removeObservers()
        if let deviceToken = UserDefaults.standard.value(forKey: Keys.UserDefs.DeviceToken) as? String {
            Services.shared.push.unsubscribe(pushToken: deviceToken) { result in
                switch result {
                case .success:
                    UserDefaults.standard.setValue(nil, forKey:Keys.UserDefs.DeviceToken)
                case .failure(let error):
                    print("Push unsubscribe error: \(error)")
                }
            }
        }
        LoginViewModel.logout(username: user.email)
        navigationCoordinator?.performTransition(transition: .logout(nil))
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Keys.Notifications.DeviceToken), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Keys.Notifications.ScrollToWallet), object: nil)
    }
    
    func showRelogin() {
        if let time = backgroundTime, time.addingTimeInterval(MenuViewModel.backgroudTimePeriod) < Date() {
            navigationCoordinator?.performTransition(transition: .showRelogin)
        }
    }
    
    func countBackgroundTime() {
        backgroundTime = Date()
    }
    
    func loginCompleted() {
        UIApplication.shared.registerForRemoteNotifications()
        
        if let walletPublicKey = UserDefaults.standard.value(forKey: Keys.UserDefs.ShowWallet) as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showWallet(publicKey: walletPublicKey)
            }
        }
    }
    
    func showWallet(publicKey: String) {
        Services.shared.walletService.getWallets(reload: false) { (result) -> (Void) in
            var transition: Transition = .showHome
            switch result {
            case .success(let wallets):
                let current = wallets.filter({ $0.publicKey == publicKey })
                if current.first?.showOnHomeScreen == false {
                    transition = .showWallets
                }
            case .failure(let error):
                // TODO: handle this
                print("Failed to get wallets: \(error)")
            }
            DispatchQueue.main.async {
                self.navigationCoordinator?.performTransition(transition: transition)
            }
        }
    }
}
