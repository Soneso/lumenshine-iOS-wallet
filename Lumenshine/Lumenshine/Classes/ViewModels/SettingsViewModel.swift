//
//  SettingsViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol SettingsViewModelType: Transitionable {
    func logout()
}


class SettingsViewModel: SettingsViewModelType {
    var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    fileprivate let user: User
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
    }
    
    func logout() {
        TFAGeneration.removeToken(email: user.email)
    }
}
