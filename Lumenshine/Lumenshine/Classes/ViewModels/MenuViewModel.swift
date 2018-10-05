//
//  MenuViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol MenuViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    func name(at indexPath: IndexPath) -> String?
    func iconName(at indexPath: IndexPath) -> String
    func isAvatar(at indexPath: IndexPath) -> Bool
    
    func menuItemSelected(at indexPath: IndexPath)
}

class MenuViewModel : MenuViewModelType {
    
    static var backgroudTimePeriod: TimeInterval = 10
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let entries: [[MenuEntry]]
    fileprivate var lastIndex = IndexPath(row: 0, section: 1)
    fileprivate var backgroundTime: Date?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        self.entries = [[.avatar],
                        [.home, .wallets, .transactions, .ICOs, .myOrders, .contacts, .extras, .settings],
                        [.help, .signOut]]
        
        if let tokenExists = TFAGeneration.isTokenExists(email: user.email),
            tokenExists == false {
            service.tfaSecret(publicKeyIndex188: user.publicKeyIndex188) { result in
                switch result {
                case .success(let response):
                    if let secret = response.tfaSecret {
                        TFAGeneration.createToken(tfaSecret: secret, email: user.email)
                    } else {
                        TFAGeneration.removeToken(email: user.email)
                    }
                case .failure(let error):
                    print("Tfa secret request error: \(error)")
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notification:)), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
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
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        
        LoginViewModel.logout(username: user.email)
        navigationCoordinator?.performTransition(transition: .logout(nil))
    }
    
    func showRelogin() {
        if let time = backgroundTime, time.addingTimeInterval(MenuViewModel.backgroudTimePeriod) < Date() {
            navigationCoordinator?.performTransition(transition: .showRelogin)
        }
    }
    
    func countBackgroundTime() {
        backgroundTime = Date()
    }
}
