//
//  LoginMenuViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/23/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class LoginMenuViewModel : MenuViewModelType {
    fileprivate let service: AuthService
    var entries: [[MenuEntry]]
    var lastIndex: IndexPath?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
        
        self.entries = [[.avatar],
                        [.login, .signUp, .lostPassword, .lost2FA, .importMnemonic, .about, .help]]
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    func name(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).name
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
        case .login:
            navigationCoordinator?.performTransition(transition: .showLogin)
        case .signUp:
            navigationCoordinator?.performTransition(transition: .showSignUp)
        case .lostPassword:
            navigationCoordinator?.performTransition(transition: .showForgotPassword)
        case .lost2FA:
            navigationCoordinator?.performTransition(transition: .showLost2fa)
        case .help:
            navigationCoordinator?.performTransition(transition: .showHelp)
        default: break
        }
        lastIndex = indexPath
    }
}

extension LoginMenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
}
