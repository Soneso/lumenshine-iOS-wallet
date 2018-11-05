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
    fileprivate let services: Services
    
    init(services: Services, user: User) {
        self.user = user
        self.services = services
        super.init(service: services.auth)
        
        self.entries = [[.avatar],
                        [.signOut, .home, .lostPassword, .lost2FA],
                        [.about, .help]]
        
        
        if !BiometricHelper.isTouchEnabled {
            entries[1].append(BiometricIDAuth().biometricType() == .faceID ? .faceRecognition : .fingerprint)
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
        case .lost2FA:
            logout()
            navigationCoordinator?.performTransition(transition: .logout(.showLost2fa))
        case .fingerprint:
            break
        default: break
        }
        lastIndex = indexPath
    }
}

fileprivate extension ReLoginMenuViewModel {
    
    func logout() {
        if let deviceToken = UserDefaults.standard.value(forKey: Keys.deviceToken) as? String {
            services.push.unsubscribe(pushToken: deviceToken) { result in
                switch result {
                case .success:
                    print("Push unsubscribe success")
                case .failure(let error):
                    print("Push unsubscribe error: \(error)")
                }
            }
        }
        LoginViewModel.logout(username: user.email)
    }
}
