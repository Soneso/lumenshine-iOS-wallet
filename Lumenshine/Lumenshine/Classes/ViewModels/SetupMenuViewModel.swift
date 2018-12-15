//
//  SetupMenuViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class SetupMenuViewModel : MenuViewModelType {
    fileprivate var user: User
    
    var entries: [[MenuEntry]]
    weak var navigationCoordinator: CoordinatorType?
    
    init(user: User) {
        self.user = user
        
        self.entries = [[.avatar],
                        [.signOut]]
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
        case .signOut:
            logout()
            navigationCoordinator?.performTransition(transition: .logout(nil))
        default: break
        }
    }
}

extension SetupMenuViewModel {
    func entry(at indexPath: IndexPath) -> MenuEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func logout() {
        LoginViewModel.logout(username: user.email)
    }
}
