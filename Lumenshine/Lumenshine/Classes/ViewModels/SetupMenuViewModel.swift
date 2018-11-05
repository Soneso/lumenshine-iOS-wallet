//
//  SetupMenuViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class SetupMenuViewModel : MenuViewModelType {
    fileprivate let service: AuthService
    fileprivate var user: User
    
    var entries: [[MenuEntry]]
    var lastIndex: IndexPath?
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        self.entries = [[.avatar],
                        [.signOut],
                        [.about, .help]]
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
        case .signOut:
            logout()
            navigationCoordinator?.performTransition(transition: .logout(nil))
        default: break
        }
        lastIndex = indexPath
    }
}

extension SetupMenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func logout() {
        if (UserDefaults.standard.value(forKey: Keys.deviceToken) as? String) != nil {
            fatalError("deviceToken is only activated after setup process")
        }
        LoginViewModel.logout(username: user.email)
    }
}
