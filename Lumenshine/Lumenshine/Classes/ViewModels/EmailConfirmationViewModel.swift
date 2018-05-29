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
    func showDashboard()
}

class EmailConfirmationViewModel : EmailConfirmationViewModelType {
    fileprivate let service: AuthService
    fileprivate let user: User
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
    }
    
    var navigationCoordinator: CoordinatorType?
    
    func checkMailConfirmation(response: @escaping TFAResponseClosure) {
        service.registrationStatus { result in
            response(result)
        }
    }
    
    func resendMailConfirmation(response: @escaping EmptyResponseClosure) {
        service.resendMailConfirmation(email: user.email) { result in
            response(result)
        }
    }
    
    func showMnemonicConfirmation() {
        navigationCoordinator?.performTransition(transition: .showMnemonic(user))
    }
    
    func showDashboard() {
        navigationCoordinator?.performTransition(transition: .showDashboard(user))
    }
}
