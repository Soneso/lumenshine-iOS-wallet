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
    func showRelogin()
    func countBackgroundTime()
}

class MenuViewModel : MenuViewModelType {
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let entries: [[MenuEntry]]
    fileprivate var lastIndex = IndexPath(row: 0, section: 1)
    fileprivate var backgroundTime: Date?
    
    var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        self.entries = [[.avatar],
                        [.home, .wallets, .transactions, .currencies, .contacts, .extras],
                        [.settings, .help],
                        [.signOut]]
        
        if let tokenExists = TFAGeneration.isTokenExists(email: user.email),
            tokenExists == false {
            service.tfaSecret(publicKeyIndex188: user.publicKeyIndex188) { result in
                switch result {
                case .success(let response):
                    TFAGeneration.createToken(tfaSecret: response.tfaSecret, email: user.email)
                case .failure(let error):
                    print("Tfa secret request error: \(error)")
                    // TODO: remove hard coded tfa secret
                    TFAGeneration.createToken(tfaSecret: "1234567890", email: user.email)
                }
            }
        }
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
        case .signOut:
            logout()
        default: break
        }
        lastIndex = indexPath
    }
    
    func showRelogin() {
        if let time = backgroundTime, time.addingTimeInterval(10) < Date() {
            navigationCoordinator?.performTransition(transition: .showRelogin)
        }
    }
    
    func countBackgroundTime() {
        backgroundTime = Date()
    }
}

fileprivate extension MenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func logout() {
        TFAGeneration.removeToken(email: user.email)
        BaseService.removeToken()
        navigationCoordinator?.performTransition(transition: .logout(nil))
    }
}
