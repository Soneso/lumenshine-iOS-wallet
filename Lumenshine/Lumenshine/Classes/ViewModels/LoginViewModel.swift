//
//  LoginViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import OneTimePassword

protocol LoginViewModelType: Transitionable, BiometricAuthenticationProtocol {
    var barItems: [(String, String)] { get }
    func barItemSelected(at index:Int)
    
    var headerTitle: String { get }
    var headerDetail: String { get }
    var hintText: String? { get }
    
    func loginCompleted()
    func showLoginForm()
    
    func loginStep1(email: String, password: String, tfaCode: String?, response: @escaping EmptyResponseClosure)
    func enableTfaCode(email: String) -> Bool
    func signUp(email: String, password: String, repassword: String, response: @escaping EmptyResponseClosure)
    func showPasswordHint()
    
    func headerMenuSelected(at index: Int)
    
    func forgotPasswordClick()
}

class LoginViewModel : LoginViewModelType {
    fileprivate let service: AuthService
    fileprivate var email: String?
    fileprivate var user: User?
    fileprivate var mnemonic: String?
    var entries: [MenuEntry]
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User? = nil) {
        self.service = service
        self.user = user
        
        self.entries = [.login, .signUp, .lostPassword, .lost2FA, .importMnemonic, .about, .help]
    }
    
    var barItems: [(String, String)] {
        return [(entries[0].name, entries[0].icon.name),
                (entries[1].name, entries[1].icon.name),
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
        return R.string.localizable.welcome().uppercased()
    }
    
    var headerDetail: String {
        return R.string.localizable.welcome()
    }
    
    var hintText: String? {
        return nil
    }
    
    func loginCompleted() {
        if let user = self.user {
            navigationCoordinator?.performTransition(transition: .showDashboard(user))
        }
    }
    
    func showLoginForm() {
        BaseService.removeToken()
        navigationCoordinator?.performTransition(transition: .logout(nil))
    }
    
    func forgotPasswordClick() {
        self.navigationCoordinator?.performTransition(transition: .showForgotPassword)
    }
    
    func enableTfaCode(email: String) -> Bool {
        if let tokenExists = TFAGeneration.isTokenExists(email: email) {
            return tokenExists
        }
        return false
    }
    
    func loginStep1(email: String, password: String, tfaCode: String?, response: @escaping EmptyResponseClosure) {
        self.email = email
        service.loginStep1(email: email, tfaCode: tfaCode) { [weak self] result in
            switch result {
            case .success(let login1Response):
                self?.verifyLogin1Response(login1Response, password: password, response: response)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func signUp(email: String, password: String, repassword: String, response: @escaping EmptyResponseClosure) {
        
        if !email.isEmail() {
            let error = ErrorResponse()
            error.parameterName = "email"
            error.errorMessage = R.string.localizable.invalid_email()
            response(.failure(error: .validationFailed(error: error)))
            return
        }
        
        if !password.isValidPassword() {
            let error = ErrorResponse()
            error.parameterName = "password"
            error.errorMessage = R.string.localizable.invalid_password()
            response(.failure(error: .validationFailed(error: error)))
            return
        }
        
        if password != repassword {
            let error = ErrorResponse()
            error.parameterName = "repassword"
            error.errorMessage = R.string.localizable.invalid_repassword()
            response(.failure(error: .validationFailed(error: error)))
            return
        }
        
        self.email = email
        
        service.generateAccount(email: email, password: password, userData: nil) { [weak self] result in
            switch result {
            case .success( _, let userSecurity):
                self?.user = User(id: "1", email: email, publicKeyIndex0: userSecurity.publicKeyIndex0, publicKeyIndex188: userSecurity.publicKeyIndex188)
                self?.mnemonic = userSecurity.mnemonic24Word
                self?.service.loginStep2(publicKeyIndex188: userSecurity.publicKeyIndex188) { [weak self] result in
                    switch result {
                    case .success(let login2Response):
                        self?.showSetup(login2Response: login2Response)
                        response(.success)
                    case .failure(let error):
                        response(.failure(error: error))
                    }
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func headerMenuSelected(at index: Int) {
        switch entries[index+2] {
        case .lostPassword:
            navigationCoordinator?.mainCoordinator.currentMenuCoordinator?.performTransition(transition: .showForgotPassword)
        case .lost2FA:
            navigationCoordinator?.mainCoordinator.currentMenuCoordinator?.performTransition(transition: .showLost2fa)
        default: break
        }
    }
    
    func showPasswordHint() {
        let hint = R.string.localizable.password_hint()
        navigationCoordinator?.performTransition(transition: .showPasswordHint(hint))
    }
    
    func biometricType() -> BiometricType {
        return .none
    }
    
    func canEvaluatePolicy() -> Bool {
        return false
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {}
}

fileprivate extension LoginViewModel {
    func showHeaderMenu() {
        let items = entries[2...].map {
            ($0.name, $0.icon.name)
        }
        navigationCoordinator?.performTransition(transition: .showHeaderMenu(items))
    }
    
    func verifyLogin1Response(_ login1Response: AuthenticationResponse, password: String, response: @escaping EmptyResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: login1Response),
                    let decryptedUserData = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    
                    self.user = User(id: "1",
                                     email: self.email!,
                                     publicKeyIndex0: login1Response.publicKeyIndex0,
                                     publicKeyIndex188: decryptedUserData.publicKeyIndex188)
                    self.mnemonic = decryptedUserData.mnemonic
                    self.service.loginStep2(publicKeyIndex188: decryptedUserData.publicKeyIndex188) { [weak self] result in
                        switch result {
                        case .success(let login2Response):
                            self?.showSetup(login2Response: login2Response)
                            response(.success)
                        case .failure(let error):
                            response(.failure(error: error))
                        }
                    }
                } else {
                    let error = ErrorResponse()
                    error.parameterName = "password"
                    error.errorMessage = R.string.localizable.invalid_password()
                    response(.failure(error: .validationFailed(error: error)))
                }
            } catch {
                response(.failure(error: .encryptionFailed(message: error.localizedDescription)))
            }
        }
    }
    
    func showSetup(login2Response: LoginStep2Response) {
        guard let user = self.user else { return }
        DispatchQueue.main.async {
            if login2Response.tfaConfirmed && login2Response.mailConfirmed && login2Response.mnemonicConfirmed {
                self.navigationCoordinator?.performTransition(transition: .showDashboard(user))
            } else {
                guard let mnemonic = self.mnemonic else { return }
                self.navigationCoordinator?.performTransition(transition: .showSetup(user, mnemonic, login2Response))
            }
        }
    }
}
