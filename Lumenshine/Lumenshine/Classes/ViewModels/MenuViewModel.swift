//
//  MenuViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
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
    
    fileprivate let services: Services
    fileprivate let user: User
    fileprivate let entries: [[MenuEntry]]
    fileprivate var lastIndex = IndexPath(row: 0, section: 1)
    fileprivate var backgroundTime: Date?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(services: Services, user: User) {
        self.services = services
        self.user = user
        
        /*self.entries = [[.avatar],
                        [.home, .wallets, .transactions, .ICOs, .myOrders, .contacts, .extras, .settings],
                        [.help, .signOut]]*/
        
        self.entries = [[.avatar],
         [.home, .wallets, .transactions, .contacts, .settings],
         [.help, .signOut]]
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notification:)), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePushToken(notification:)), name: Notification.Name(Keys.deviceTokenNotification), object: nil)
        
        loginCompleted()
    }
    
    deinit {
        removeObservers()
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        showRelogin()
    }
    
    @objc
    func appDidEnterBackground(notification: Notification) {
        countBackgroundTime()
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
        if indexPath == lastIndex { return }
        switch entry(at: indexPath) {
        case .avatar, .settings:
            navigationCoordinator?.performTransition(transition: .showSettings)
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
        default: break
        }
        lastIndex = indexPath
    }
}

fileprivate extension MenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func logout() {
        removeObservers()
        if let deviceToken = UserDefaults.standard.value(forKey: Keys.deviceToken) as? String {
            services.push.unsubscribe(pushToken: deviceToken) { result in
                switch result {
                case .success:
                    UserDefaults.standard.setValue(nil, forKey:Keys.deviceToken)
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Keys.deviceTokenNotification), object: nil)
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
        update2FASecret()
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func update2FASecret() {
        if let tokenExists = TFAGeneration.isTokenExists(email: user.email),
            tokenExists == false {
            // TODO: update to sep10
//            services.auth.tfaSecret(publicKeyIndex188: user.publicKeyIndex188) { result in
//                switch result {
//                case .success(let response):
//                    if let secret = response.tfaSecret {
//                        TFAGeneration.createToken(tfaSecret: secret, email: self.user.email)
//                    } else {
//                        TFAGeneration.removeToken(email: self.user.email)
//                    }
//                case .failure(let error):
//                    print("Tfa secret request error: \(error)")
//                }
//            }
        }
    }
    
    @objc
    func updatePushToken(notification: Notification) {
        
        if let notifications = UserDefaults.standard.value(forKey: Keys.notifications) as? Bool {
            if notifications == false { return }
        } else {
            UserDefaults.standard.setValue(true, forKey: Keys.notifications)
        }
        
        if let newToken = notification.userInfo?[Keys.deviceToken] as? String {
            if let deviceToken = UserDefaults.standard.value(forKey: Keys.deviceToken) as? String,
                newToken != deviceToken {
                services.push.update(newPushToken: newToken, oldPushToken: deviceToken) { result in
                    switch result {
                    case .success:
                        print("Push update success")
                    case .failure(let error):
                        print("Push update error: \(error)")
                    }
                }
            } else {
                services.push.subscribe(pushToken: newToken) { result in
                    switch result {
                    case .success:
                        print("Push Subscribe success")
                    case .failure(let error):
                        print("Push Subscribe error: \(error)")
                    }
                }
            }
            UserDefaults.standard.setValue(newToken, forKey: Keys.deviceToken)
        } else {
            UserDefaults.standard.setValue(false, forKey: Keys.notifications)
        }
    }
}
