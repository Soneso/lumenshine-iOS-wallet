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
    
    func loginStep1(email: String, password: String, tfaCode: String?, checkSetup: Bool?, response: @escaping EmptyResponseClosure)
    func enableTfaCode(email: String) -> Bool
    func signUp(email: String, password: String, repassword: String, response: @escaping EmptyResponseClosure)
    func showPasswordHint()
    func showTermsOfService()
    
    func headerMenuSelected(at index: Int)
    
    func forgotPasswordClick()
    func lost2FAClick()
    func remove2FASecret()
    func removeBiometricRecognition()
}

protocol LostSecurityViewModelType: Transitionable {
    var lostEmail: String? { get }
    var title: String { get }
    var subtitle: String { get }
    var successHint: String { get }
    var successDetail: String { get }
    
    func lostSecurity(email:String?, response: @escaping EmptyResponseClosure)
    func resendMailConfirmation(response: @escaping EmptyResponseClosure)
    func showEmailConfirmation()
    func showSuccess()
    func showLogin()
}

class LoginViewModel : LoginViewModelType {
    fileprivate let service: AuthService
    fileprivate var email: String?
    fileprivate var user: User?
    fileprivate var mnemonic: String? {
        didSet {
            PrivateKeyManager.getWalletsKeyPairs(fromMnemonic: mnemonic)
        }
    }
    
    var entries: [MenuEntry]
    var lostPassword: Bool
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User? = nil) {
        self.service = service
        self.user = user
        self.lostPassword = true
        
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
    
    func lost2FAClick() {
        self.navigationCoordinator?.performTransition(transition: .showLost2fa)
    }
    
    func enableTfaCode(email: String) -> Bool {
        if let tokenExists = TFAGeneration.isTokenExists(email: email) {
            return tokenExists
        }
        return false
    }
    
    func loginStep1(email: String, password: String, tfaCode: String?, checkSetup: Bool? = true, response: @escaping EmptyResponseClosure) {
        self.email = email
        service.loginStep1(email: email, tfaCode: tfaCode) { [weak self] result in
            switch result {
            case .success(let login1Response):
                self?.verifyLogin1Response(login1Response, password: password) { result2 in
                    switch result2 {
                    case .success(let login2Response):
                        if BiometricHelper.isTouchEnabled {
                            BiometricHelper.save(user: email, password: password)
                        }
                        if checkSetup == true {
                            self?.checkSetup(login2Response: login2Response)
                        } else {
                            BiometricHelper.enableTouch(true)
                            BiometricHelper.save(user: email, password: password)
                        }
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
                self?.user = User(id: "1",
                                  email: email,
                                  publicKeyIndex0: userSecurity.publicKeyIndex0,
                                  publicKeyIndex188: userSecurity.publicKeyIndex188,
                                  publicKeys: nil)
                self?.mnemonic = userSecurity.mnemonic24Word
                
                // load sep10 challenge from server and continue signup.
                // TODO: handle errors correctly - the user is already registered here!
                self?.service.getSep10Challenge(response: { (challengeResponse) -> (Void) in
                    switch challengeResponse {
                    case .success(transactionEnvelopeXDR: let envelopeXDR):
                        // sign sep10 challenge and login user
                        PrivateKeyManager.getKeyPair(forAccountID: userSecurity.publicKeyIndex0, fromMnemonic: userSecurity.mnemonic24Word, completion: { (keyResponse) -> (Void) in
                            switch keyResponse {
                            case .success(keyPair: let keyPair):
                                // sign challenge
                                self?.service.signSEP10ChallengeIfValid(base64EnvelopeXDR: envelopeXDR, userKeyPair: keyPair!, completion: { (signResponse) -> (Void) in
                                    switch signResponse {
                                    case .success(signedXDR: let signedXDR):
                                        // login user
                                        self?.service.loginStep2(signedSEP10TransactionEnvelope:signedXDR) { [weak self] result in
                                            switch result {
                                            case .success(let login2Response):
                                                self?.checkSetup(login2Response: login2Response)
                                                response(.success)
                                            case .failure(let error):
                                                response(.failure(error: error))
                                            }
                                        }
                                    case .failure(error: let error):
                                        print(error)
                                        response(.failure(error: error))
                                    }
                                })
                            case .failure(error: let error):
                                print(error)
                                response(.failure(error: .encryptionFailed(message: error)))
                            }
                        })
                    case .failure(error: let error):
                        print(error)
                        response(.failure(error: error))
                    }
                    
                })
               
                /*
                self?.service.loginStep2(publicKeyIndex188: userSecurity.publicKeyIndex188) { [weak self] result in
                    switch result {
                    case .success(let login2Response):
                        self?.checkSetup(login2Response: login2Response)
                        response(.success)
                    case .failure(let error):
                        response(.failure(error: error))
                    }
                }
                */
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func headerMenuSelected(at index: Int) {
        switch entries[index+2] {
        case .lostPassword:
            navigationCoordinator?.performTransition(transition: .showForgotPassword)
        case .lost2FA:
            navigationCoordinator?.performTransition(transition: .showLost2fa)
        default: break
        }
    }
    
    func showPasswordHint() {
        let prefix_font = R.font.encodeSansBold(size: 15) ?? Stylesheet.font(.body)
        let font = R.font.encodeSansRegular(size: 15) ?? Stylesheet.font(.body)
        
        let hint1_prefix = NSAttributedString(string: R.string.localizable.password_hint1_prefix()+"\n",
                                       attributes: [NSAttributedStringKey.font : prefix_font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
        
        let hint1 = NSAttributedString(string: R.string.localizable.password_hint1()+"\n\n",
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
        let hint2_prefix = NSAttributedString(string: R.string.localizable.password_hint2_prefix()+"\n",
                                              attributes: [NSAttributedStringKey.font : prefix_font,
                                                           NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
        
        let hint2 = NSAttributedString(string: R.string.localizable.password_hint2()+"\n\n",
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
        
        let hint3_prefix = NSAttributedString(string: R.string.localizable.password_hint3_prefix()+"\n",
                                              attributes: [NSAttributedStringKey.font : prefix_font,
                                                           NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
        
        let hint3 = NSAttributedString(string: R.string.localizable.password_hint3()+"\n\n",
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
        
        let hint4_prefix = NSAttributedString(string: R.string.localizable.password_hint4_prefix()+"\n",
                                              attributes: [NSAttributedStringKey.font : prefix_font,
                                                           NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
        
        let hint4 = NSAttributedString(string: R.string.localizable.password_hint4(),
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.darkGray)])
        
        let hint = NSMutableAttributedString(attributedString: hint1_prefix)
        hint.append(hint1)
        hint.append(hint2_prefix)
        hint.append(hint2)
        hint.append(hint3_prefix)
        hint.append(hint3)
        hint.append(hint4_prefix)
        hint.append(hint4)
        
        navigationCoordinator?.performTransition(transition: .showPasswordHint(hint.string, hint))
    }
    
    func showTermsOfService() {
        navigationCoordinator?.performTransition(transition: .showTermsOfService)
    }
    

    func authenticateUser(completion: @escaping BiometricAuthResponseClosure) {}
    
    func remove2FASecret() {
        TFAGeneration.removeToken(email: email!)
    }
    
    func removeBiometricRecognition() {}
    
    class func logout(username: String) {
        TFAGeneration.removeToken(email: username)
        BaseService.removeToken()
        BiometricHelper.enableTouch(false)
        BiometricHelper.removePassword(username: username)
        UserDefaults.standard.setValue(nil, forKey:ChartCardViewModel.selectedPeriodKey)
    }
}

extension LoginViewModel: LostSecurityViewModelType {
    var lostEmail: String? {
        return self.email
    }
    
    var title: String {
        return lostPassword ? R.string.localizable.reset_password().uppercased() : R.string.localizable.reset_2fa().uppercased()
    }
    
    var subtitle: String {
        return R.string.localizable.reset_enter_email()
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
            self.email = email
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
        guard let email = self.email else { return }
        service.resendMailConfirmation(email: email) { result in
            response(result)
        }
    }
    
    func showEmailConfirmation() {
        navigationCoordinator?.performTransition(transition: .showEmailConfirmation)
    }
    
    func showSuccess() {
        navigationCoordinator?.performTransition(transition: .showSuccess)
    }
    
    func showLogin() {
        navigationCoordinator?.performTransition(transition: .showLogin)
    }
}

fileprivate extension LoginViewModel {
    func showHeaderMenu() {
        let items = entries[2...].map {
            ($0.name, $0.icon.name)
        }
        navigationCoordinator?.performTransition(transition: .showHeaderMenu(items))
    }
    
    func verifyLogin1Response(_ login1Response: LoginStep1Response, password: String, response: @escaping Login2ResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: login1Response),
                    let decryptedUserData = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    
                    self.user = User(id: "1",
                                     email: self.email!,
                                     publicKeyIndex0: login1Response.publicKeyIndex0,
                                     publicKeyIndex188: decryptedUserData.publicKeyIndex188,
                                     publicKeys: decryptedUserData.publicKeys)
                    
                    // this is needed because the user mitght not have completed the setup and it may be used later.
                    self.mnemonic = decryptedUserData.mnemonic
                    
                    // sign sep10 challenge and login user
                    PrivateKeyManager.getKeyPair(forAccountID: self.user!.publicKeyIndex0, fromMnemonic: decryptedUserData.mnemonic, completion: { (keyResponse) -> (Void) in
                        switch keyResponse {
                        case .success(keyPair: let keyPair):
                            // sign challenge
                            self.service.signSEP10ChallengeIfValid(base64EnvelopeXDR: login1Response.sep10TransactionEnvelopeXDR, userKeyPair: keyPair!, completion: { (signResponse) -> (Void) in
                                switch signResponse {
                                case .success(signedXDR: let signedXDR):
                                    // login user
                                    self.service.loginStep2(signedSEP10TransactionEnvelope:signedXDR, response: response)
                                case .failure(error: let error):
                                    print(error)
                                    response(.failure(error: error))
                                }
                        })
                        case .failure(error: let error):
                            print(error)
                            response(.failure(error: .encryptionFailed(message: error)))
                        }
                    })
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
    
    func checkSetup(login2Response: LoginStep2Response) {
        // TODO: improve this. Otherwise on error the app will hang in the login screen.
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
