//
//  MnemonicViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 5/7/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol MnemonicViewModelType: Transitionable {
    var mnemonic24Word: String { get }
    func confirmMnemonic(response: @escaping EmptyResponseClosure)
    func showDashboard()
}

class MnemonicViewModel: MnemonicViewModelType {
    fileprivate let service: AuthService
    fileprivate let mnemonic: String
    
    init(service: AuthService, mnemonic: String) {
        self.service = service
        self.mnemonic = mnemonic
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var mnemonic24Word: String {
        return mnemonic
    }
    
    func confirmMnemonic(response: @escaping EmptyResponseClosure) {
        service.confirmMnemonic { result in
            response(result)
        }
    }
    
    func showDashboard() {
        let user = User(id: "1", name: "username")
        navigationCoordinator?.performTransition(transition: .showDashboard(user))
    }
}
