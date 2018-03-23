//
//  LoginViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol LoginViewModelType: Transitionable {
    
    func loginCompleted(_ user: User)
}

class LoginViewModel : LoginViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    init() {
    }
    
    func loginCompleted(_ user: User) {
//        let user = User(id: user.id, name: user.name ?? R.string.localizable.unknown())
        self.navigationCoordinator?.performTransition(transition: .showMain(user))
    }
}
