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
    
    var barItems: [(String, String)] { get }
    var headerTitle: String { get }
    var headerDetail: String { get }
    func barItemSelected(at index:Int)
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
    
    func showHeaderMenu() {
        let entries:[MenuEntry] = [.lostPassword, .lost2FA, .importMnemonic, .about, .help]
        let items = entries.map {
            ($0.name, $0.icon.name)
        }
        navigationCoordinator?.performTransition(transition: .showHeaderMenu(items))
    }
    
    var barItems: [(String, String)] {
        return [(MenuEntry.login.name, MenuEntry.login.icon.name),
                (MenuEntry.signUp.name, MenuEntry.signUp.icon.name),
                (R.string.localizable.more(), R.image.more.name)]
    }
    
    func barItemSelected(at index:Int) {
        switch index {
        case 0:
            navigationCoordinator?.performTransition(transition: .showLogin)
        case 1:
            navigationCoordinator?.performTransition(transition: .showSignUp)
        case 2:
            showHeaderMenu()
        default: break
        }
    }
    
    var headerTitle: String {
        return R.string.localizable.app_name()
    }
    
    var headerDetail: String {
        return R.string.localizable.welcome()
    }
}
