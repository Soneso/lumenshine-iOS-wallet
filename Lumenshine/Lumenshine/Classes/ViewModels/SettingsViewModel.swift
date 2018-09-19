//
//  SettingsViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol SettingsViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    var tfaSecret: String? { get }
    
    var successHeader: String? { get }
    var successTitle: String? { get }
    
    func name(at indexPath: IndexPath) -> String
    func switchValue(at indexPath: IndexPath) -> Bool?
    func switchChanged(value: Bool, at indexPath: IndexPath)
    func itemSelected(at indexPath: IndexPath)
    func showPasswordHint()
    func showSuccess()
    func changePassword(currentPass: String, newPass: String, repeatPass: String, response: @escaping EmptyResponseClosure)
    func change2faSecret(password: String, response: @escaping TfaSecretResponseClosure)
    func confirm2faSecret(tfaCode: String, response: @escaping TFAResponseClosure)
    func showHome()
    func showSettings()
    func showConfirm2faSecret(tfaResponse: RegistrationResponse)
    func showBackupMnemonic(password: String, response: @escaping DecryptedUserDataResponseClosure)
    func showMnemonic(_ mnemonic: String)
}


class SettingsViewModel: SettingsViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let entries: [[SettingsEntry]]
    fileprivate var touchEnabled: Bool
    fileprivate var tfaResponse: RegistrationResponse?
    fileprivate var changePassword: Bool = true
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        self.entries = [[.changePassword, .change2FA, .biometricAuth, .backupMnemonic, .avatar]]
        self.touchEnabled = BiometricHelper.isTouchEnabled
    }
    
    var tfaSecret: String? {
        return tfaResponse?.tfaSecret
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    var successHeader: String? {
        return changePassword ? R.string.localizable.change_password() : R.string.localizable.change_2fa()
    }
    
    var successTitle: String? {
        return changePassword ? R.string.localizable.password_changed() : R.string.localizable.tfa_secret_changed()
    }
    
    func name(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).name
    }
    
    func switchValue(at indexPath: IndexPath) -> Bool? {
        if entry(at: indexPath) == .biometricAuth {
            return touchEnabled
        }
        return nil
    }
    
    func switchChanged(value: Bool, at indexPath: IndexPath) {
        switch entry(at: indexPath) {
        case .biometricAuth:
            enableTouch(value: value)
        default: break
        }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        switch entry(at: indexPath) {
        case .changePassword:
            changePassword = true
            navigationCoordinator?.performTransition(transition: .showChangePassword)
        case .change2FA:
            changePassword = false
            navigationCoordinator?.performTransition(transition: .showChange2faSecret)
        case .biometricAuth:
            break
        case .avatar:
            break
        case .backupMnemonic:
            navigationCoordinator?.performTransition(transition: .showBackupMnemonic)
        }
    }
    
    func showPasswordHint() {
        let font = R.font.encodeSansRegular(size: 12) ?? Stylesheet.font(.body)
        let hint1 = NSAttributedString(string: R.string.localizable.password_hint1()+"\n",
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.green)])
        let hint2 = NSAttributedString(string: R.string.localizable.password_hint2()+"\n",
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.green)])
        let hint3 = NSAttributedString(string: R.string.localizable.password_hint3()+"\n",
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.red)])
        let hint4 = NSAttributedString(string: R.string.localizable.password_hint4(),
                                       attributes: [NSAttributedStringKey.font : font,
                                                    NSAttributedStringKey.foregroundColor : Stylesheet.color(.green)])
        
        let hint = NSMutableAttributedString(attributedString: hint1)
        hint.append(hint2)
        hint.append(hint3)
        hint.append(hint4)
        
        navigationCoordinator?.performTransition(transition: .showPasswordHint(hint.string, hint))
    }
    
    func showSuccess() {
        navigationCoordinator?.performTransition(transition: .showSuccess)
    }
    
    func showHome() {
        navigationCoordinator?.performTransition(transition: .showHome)
    }
    
    func showSettings() {
        navigationCoordinator?.performTransition(transition: .showSettings)
    }
    
    func changePassword(currentPass: String, newPass: String, repeatPass: String, response: @escaping EmptyResponseClosure) {
        if !newPass.isValidPassword() {
            let error = ErrorResponse()
            error.parameterName = "new_password"
            error.errorMessage = R.string.localizable.invalid_password()
            response(.failure(error: .validationFailed(error: error)))
            return
        }
        
        if newPass != repeatPass {
            let error = ErrorResponse()
            error.parameterName = "re_password"
            error.errorMessage = R.string.localizable.invalid_repassword()
            response(.failure(error: .validationFailed(error: error)))
            return
        }
        
        service.authenticationData { result in
            switch result {
            case .success(let authResponse):
                self.changePassword(authResponse: authResponse, oldPass: currentPass, newPass: newPass) { result2 in
                    switch result2 {
                    case .success(_, let userSecurity):
                        self.service.changePassword(userSecurity: userSecurity, response: response)
                    case .failure(let error):
                        response(.failure(error: error))
                    }
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func change2faSecret(password: String, response: @escaping TfaSecretResponseClosure) {
        service.authenticationData { result in
            switch result {
            case .success(let authResponse):
                self.change2faSecret(authResponse: authResponse, password: password, response: response)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func confirm2faSecret(tfaCode: String, response: @escaping TFAResponseClosure) {
        service.confirm2faSecret(tfaCode: tfaCode) { [weak self] result in
            switch result {
            case .success:
                if let secret = self?.tfaResponse?.tfaSecret,
                    let email = self?.user.email {
                    TFAGeneration.createToken(tfaSecret: secret, email: email)
                }
            default: break
            }
            response(result)
        }
    }
    
    func showConfirm2faSecret(tfaResponse: RegistrationResponse) {
        self.tfaResponse = tfaResponse
        navigationCoordinator?.performTransition(transition: .showNew2faSecret)
    }
    
    func showBackupMnemonic(password: String, response: @escaping DecryptedUserDataResponseClosure) {
        service.authenticationData { result in
            switch result {
            case .success(let authResponse):
                self.backupMnemonic(authResponse: authResponse, password: password, response: response)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func showMnemonic(_ mnemonic: String) {
        navigationCoordinator?.performTransition(transition: .showMnemonic(mnemonic))
    }
}

fileprivate extension SettingsViewModel {
    func enableTouch(value: Bool) {
        touchEnabled = value
        BiometricHelper.enableTouch(touchEnabled)
    }
    
    func entry(at indexPath: IndexPath) -> SettingsEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func changePassword(authResponse: AuthenticationResponse, oldPass: String, newPass: String, response: @escaping GenerateAccountResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: authResponse),
                    let decryptedUserData = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: oldPass) {
                    
                    let userSec = try userSecurity.updatePassword(newPass,
                                                                  publicKeyIndex188: decryptedUserData.publicKeyIndex188,
                                                                  wordlistMasterKey: decryptedUserData.wordListMasterKey,
                                                                  mnemonicMasterKey: decryptedUserData.mnemonicMasterKey)
                    response(.success(response: nil, userSecurity: userSec))
                } else {
                    let error = ErrorResponse()
                    error.parameterName = "current_password"
                    error.errorMessage = R.string.localizable.invalid_password()
                    response(.failure(error: .validationFailed(error: error)))
                }
            } catch {
                response(.failure(error: .encryptionFailed(message: error.localizedDescription)))
            }
        }
    }
    
    func change2faSecret(authResponse: AuthenticationResponse, password: String, response: @escaping TfaSecretResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: authResponse),
                    let decryptedUserData = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    self.service.new2faSecret(publicKeyIndex188: decryptedUserData.publicKeyIndex188, response: response)
                } else {
                    let error = ErrorResponse()
                    error.parameterName = "current_password"
                    error.errorMessage = R.string.localizable.invalid_password()
                    response(.failure(error: .validationFailed(error: error)))
                }
            } catch {
                response(.failure(error: .encryptionFailed(message: error.localizedDescription)))
            }
        }
    }
    
    func backupMnemonic(authResponse: AuthenticationResponse, password: String, response: @escaping DecryptedUserDataResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: authResponse),
                    let decryptedUserData = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    response(.success(response: decryptedUserData))
                } else {
                    let error = ErrorResponse()
                    error.parameterName = "current_password"
                    error.errorMessage = R.string.localizable.invalid_password()
                    response(.failure(error: .validationFailed(error: error)))
                }
            } catch {
                response(.failure(error: .encryptionFailed(message: error.localizedDescription)))
            }
        }
    }
    
}
