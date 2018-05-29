//
//  LoginViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import OneTimePassword

protocol LoginViewModelType: Transitionable {
    func loginCompleted()
    
    func loginStep1(email: String, tfaCode: String?, response: @escaping Login1ResponseClosure)
    
    func signUpClick()
    func forgotPasswordClick()
    func verifyLogin1Response(_ login1Response: LoginStep1Response, password: String, response: @escaping Login2ResponseClosure)
    func verifyLogin2Response(_ login2Response: LoginStep2Response)
    
    func biometricType() -> BiometricType
    func canEvaluatePolicy() -> Bool
    func authenticateUser(completion: @escaping (String?) -> Void)
}

class LoginViewModel : LoginViewModelType {
    fileprivate let touchMe = BiometricIDAuth()
    fileprivate let service: AuthService
    fileprivate var email: String?
    fileprivate var user: User?
    
    var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
    }
    
    func loginCompleted() {
        guard let user = self.user else { return }
        self.navigationCoordinator?.performTransition(transition: .showDashboard(user))
        touchMe.invalidate()
    }
    
    func signUpClick() {
        self.navigationCoordinator?.performTransition(transition: .showSignUp)
    }
    
    func forgotPasswordClick() {
        self.navigationCoordinator?.performTransition(transition: .showForgotPassword)
    }
    
    func loginStep1(email: String, tfaCode: String?, response: @escaping Login1ResponseClosure) {
        self.email = email
        var token: String?
        if let tfa = tfaCode, !tfa.isEmpty {
            token = tfa
        } else {
            token = TFAGeneration.generatePassword(email: email)
        }
        service.loginStep1(email: email, tfaCode: token) { result in
            response(result)
        }
    }
    
    func verifyLogin1Response(_ login1Response: LoginStep1Response, password: String, response: @escaping Login2ResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: login1Response),
                    let (publicKeyIndex188, mnemonic) = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    self.user = User(id: "1", email: self.email!, publicKeyIndex188: publicKeyIndex188, mnemonic: mnemonic)
                    self.service.loginStep2(publicKeyIndex188: publicKeyIndex188) { result in
                        response(result)
                    }
                } else {
                    response(.failure(error: .badCredentials))
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
}

// MARK: Biometric authentication
extension LoginViewModel {
    
    func biometricType() -> BiometricType {
        return touchMe.biometricType()
    }
    
    func canEvaluatePolicy() -> Bool {
        return touchMe.canEvaluatePolicy()
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        touchMe.authenticateUser(completion: completion)
    }
}
