//
//  ReLoginMenuViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/27/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class ReLoginMenuViewModel : LoginMenuViewModel {
    
    fileprivate let user: User
    
    init(service: AuthService, user: User) {
        self.user = user
        super.init(service: service)
        
        self.entries = [[.avatar],
                        [.signOut, .home, .lostPassword],
                        [.about, .help]]
        
        switch BiometricIDAuth().biometricType() {
        case .faceID:
            entries[1].append(.faceRecognition)
        case .touchID:
            entries[1].append(.fingerprint)
        default: break
        }
    }
    
    override func name(at indexPath: IndexPath) -> String? {
        return isAvatar(at: indexPath) ? user.email : entry(at: indexPath).name
    }
    
    override func menuItemSelected(at indexPath:IndexPath) {
        if indexPath == lastIndex { return }
        switch entry(at: indexPath) {
        case .signOut:
            logout()
            navigationCoordinator?.performTransition(transition: .logout(nil))
        case .home:
            navigationCoordinator?.performTransition(transition: .showRelogin)
        case .lostPassword:
            logout()
            navigationCoordinator?.performTransition(transition: .logout(.showForgotPassword))
        case .fingerprint:
            break
        default: break
        }
        lastIndex = indexPath
    }
}

fileprivate extension ReLoginMenuViewModel {
    func logout() {
        LoginViewModel.logout(userEmail: user.email)
    }
}
