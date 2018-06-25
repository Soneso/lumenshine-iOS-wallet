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
    fileprivate let entries: [[LoginMenuEntry]]
    fileprivate var lastIndex = IndexPath(row: 0, section: 1)
    
    var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
        
        self.entries = [[.avatar],
                        [.login, .signUp, .lostPassword, .lost2FA, .importMnemonic],
                        [.about, .help]]
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
        case .avatar:
            break
        case .login:
            break
        default: break
        }
        lastIndex = indexPath
    }
    
    func showRelogin() {}
    
    func countBackgroundTime() {}
}

fileprivate extension LoginMenuViewModel {
    func entry(at indexPath: IndexPath) -> LoginMenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
}
