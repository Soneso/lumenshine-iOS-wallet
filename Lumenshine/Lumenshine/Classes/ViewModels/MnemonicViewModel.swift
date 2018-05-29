//
//  MnemonicViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/7/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol MnemonicViewModelType: Transitionable {
    var mnemonic24Word: String { get }
    func confirmMnemonic(response: @escaping TFAResponseClosure)
    func showDashboard()
}

class MnemonicViewModel: MnemonicViewModelType {
    fileprivate let service: AuthService
    fileprivate let user: User
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var mnemonic24Word: String {
        return user.mnemonic
    }
    
    func confirmMnemonic(response: @escaping TFAResponseClosure) {
        service.confirmMnemonic { result in
            response(result)
        }
    }
    
    func showDashboard() {
        navigationCoordinator?.performTransition(transition: .showDashboard(user))
    }
}
