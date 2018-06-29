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
    
    func loginCompleted()
    func showLoginForm()
    
    func loginStep1(email: String, tfaCode: String?, response: @escaping Login1ResponseClosure)
    func enableTfaCode(email: String) -> Bool
    
    func signUpClick()
    func forgotPasswordClick()
    func lost2faClick()
    func verifyLogin1Response(_ login1Response: LoginStep1Response, password: String, response: @escaping Login2ResponseClosure)
    func verifyLogin2Response(_ login2Response: LoginStep2Response)
}

class LoginViewModel : LoginViewModelType {
    fileprivate let service: AuthService
    fileprivate var email: String?
    fileprivate var user: User?
    var entries: [MenuEntry]
    
    var navigationCoordinator: CoordinatorType?
    
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
            break
        case 1:
            break
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
    
    func loginCompleted() {
        if let user = self.user {
            navigationCoordinator?.performTransition(transition: .showDashboard(user))
        }
    }
    
    func showLoginForm() {
        BaseService.removeToken()
        navigationCoordinator?.performTransition(transition: .logout(nil))
    }
    
    func signUpClick() {
        self.navigationCoordinator?.performTransition(transition: .showSignUp)
    }
    
    func forgotPasswordClick() {
        self.navigationCoordinator?.performTransition(transition: .showForgotPassword)
    }
    
    func lost2faClick() {
        self.navigationCoordinator?.performTransition(transition: .showLost2fa)
    }
    
    func enableTfaCode(email: String) -> Bool {
        if let tokenExists = TFAGeneration.isTokenExists(email: email) {
            return tokenExists
        }
        return false
    }
    
    func loginStep1(email: String, tfaCode: String?, response: @escaping Login1ResponseClosure) {
        self.email = email
        service.loginStep1(email: email, tfaCode: tfaCode) { result in
            response(result)
        }
    }
    
    func verifyLogin1Response(_ login1Response: LoginStep1Response, password: String, response: @escaping Login2ResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: login1Response),
                    let (publicKeyIndex188, mnemonic) = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    self.user = User(id: "1", email: self.email!, publicKeyIndex0: login1Response.publicKeyIndex0, publicKeyIndex188: publicKeyIndex188, mnemonic: mnemonic)
                    self.service.loginStep2(publicKeyIndex188: publicKeyIndex188) { result in
                        response(result)
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
    
    func verifyLogin2Response(_ login2Response: LoginStep2Response) {
        guard let user = self.user else { return }
        if login2Response.tfaConfirmed == nil || login2Response.tfaConfirmed == false {
            if let tfaSecret = login2Response.tfaSecret,
                let qrCode = login2Response.qrCode {
                
                let response = RegistrationResponse(tfaSecret: tfaSecret, qrCode: qrCode)
                self.navigationCoordinator?.performTransition(transition: .show2FA(user, response))
            }
        } else if login2Response.mailConfirmed == nil || login2Response.mailConfirmed == false {
            self.navigationCoordinator?.performTransition(transition: .showEmailConfirmation(user) )
        } else if login2Response.mnemonicConfirmed == nil || login2Response.mnemonicConfirmed == false {
            self.navigationCoordinator?.performTransition(transition: .showMnemonic(user))
        } else {
            loginCompleted()
        }
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
}
