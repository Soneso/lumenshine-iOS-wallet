//
//  ForgotPasswordViewModel.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol ForgotPasswordViewModelType: Transitionable {
    var email: String? { get }
    func lostPassword(email:String?, response: @escaping EmptyResponseClosure)
    func resendMailConfirmation(response: @escaping EmptyResponseClosure)
    func showEmailConfirmation()
    func showSuccess()
    func showLogin()
}


class ForgotPasswordViewModel: ForgotPasswordViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var mail: String?
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    var email: String? {
        return self.mail
    }
    
    func lostPassword(email:String?, response: @escaping EmptyResponseClosure) {
        if let email = email, email.isEmail() {
            self.mail = email
            service.lostPassword(email: email, response: response)
        } else {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_email()
            response(.failure(error: .validationFailed(error: error)))
        }
    }
    
    func resendMailConfirmation(response: @escaping EmptyResponseClosure) {
        service.resendMailConfirmation(email: mail!) { result in
            response(result)
        }
    }
    
    func showEmailConfirmation() {
        navigationCoordinator?.performTransition(transition: .showEmailConfirmation)
    }
    
    func showSuccess() {
        navigationCoordinator?.performTransition(transition: .showLostPasswordSuccess)
    }
    
    func showLogin() {
        navigationCoordinator?.mainCoordinator.currentMenuCoordinator?.performTransition(transition: .showLogin)
    }
}
