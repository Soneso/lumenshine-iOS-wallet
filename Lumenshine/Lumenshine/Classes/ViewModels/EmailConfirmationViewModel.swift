//
//  EmailConfirmationViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol EmailConfirmationViewModelType: Transitionable {
    func checkMailConfirmation(response: @escaping TFAResponseClosure)
    func resendMailConfirmation(response: @escaping EmptyResponseClosure)
    func showMnemonicConfirmation()
}

class EmailConfirmationViewModel : EmailConfirmationViewModelType {
    fileprivate let service: AuthService
    fileprivate let email: String
    fileprivate let mnemonic: String?
    
    init(service: AuthService, email: String, mnemonic: String?) {
        self.service = service
        self.email = email
        self.mnemonic = mnemonic
    }
    
    var navigationCoordinator: CoordinatorType?
    
    func checkMailConfirmation(response: @escaping TFAResponseClosure) {
        service.registrationStatus { result in
            response(result)
        }
    }
    
    func resendMailConfirmation(response: @escaping EmptyResponseClosure) {
        service.resendMailConfirmation(email: email) { result in
            response(result)
        }
    }
    
    func showMnemonicConfirmation() {
        guard let mnemonic = self.mnemonic else { return }
        navigationCoordinator?.performTransition(transition: .showMnemonic(mnemonic))
    }
}
