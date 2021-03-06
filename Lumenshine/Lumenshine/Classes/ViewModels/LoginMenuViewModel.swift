//
//  LoginMenuViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class LoginMenuViewModel : MenuViewModelType {
    fileprivate let service: AuthService
    var entries: [[MenuEntry]]
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
        
        self.entries = [[.avatar],
                        [.login, .signUp, .lostPassword, .lost2FA, .about, .help]] //.importMnemonic
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
        case .about:
            navigationCoordinator?.performTransition(transition: .showAbout)
        default: break
        }
    }
}

extension LoginMenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
}
