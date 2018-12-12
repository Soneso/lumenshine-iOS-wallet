//
//  ReLoginMenuViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
    }
}

fileprivate extension ReLoginMenuViewModel {
    
    func logout() {
        if let deviceToken = UserDefaults.standard.value(forKey: Keys.UserDefs.DeviceToken) as? String {
            services.push.unsubscribe(pushToken: deviceToken) { result in
                switch result {
                case .success:
                    UserDefaults.standard.setValue(nil, forKey:Keys.UserDefs.DeviceToken)
                case .failure(let error):
                    print("Push unsubscribe error: \(error)")
                }
            }
        }
        LoginViewModel.logout(username: user.email)
    }
}
