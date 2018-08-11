//
//  LostSecurityViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/10/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol LostSecurityViewModelType: Transitionable {
    var email: String? { get }
    var title: String { get }
    var successHint: String { get }
    var successDetail: String { get }
    
    func lostSecurity(email:String?, response: @escaping EmptyResponseClosure)
    func resendMailConfirmation(response: @escaping EmptyResponseClosure)
    func showEmailConfirmation()
    func showSuccess()
    func showLogin()
}


class LostSecurityViewModel: LostSecurityViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var mail: String?
    fileprivate let service: AuthService
    fileprivate let lostPassword: Bool
    
    init(service: AuthService, lostPassword: Bool) {
        self.service = service
        self.lostPassword = lostPassword
    }
    
    var email: String? {
        return self.mail
    }
    
    var title: String {
        return lostPassword ? R.string.localizable.lost_password() : R.string.localizable.lost_2fa()
    }
    
    var successHint: String {
        let hint = lostPassword ? R.string.localizable.password() : R.string.localizable.fa_secret()
        return R.string.localizable.lost_security_email_hint(hint, hint)
    }
    
    var successDetail: String {
        return R.string.localizable.lost_security_email_sent(title)
    }
    
    func lostSecurity(email:String?, response: @escaping EmptyResponseClosure) {
        if let email = email, email.isEmail() {
            self.mail = email
            if lostPassword {
                service.lostPassword(email: email, response: response)
            } else {
                service.reset2fa(email: email, response: response)
            }
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
