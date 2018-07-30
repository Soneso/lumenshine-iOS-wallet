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
    func name(at indexPath: IndexPath) -> String
    func switchValue(at indexPath: IndexPath) -> Bool?
    func switchChanged(value: Bool, at indexPath: IndexPath)
    func itemSelected(at indexPath: IndexPath)
    func showPasswordHint()
    func changePassword(currentPass: String, newPass: String, repeatPass: String, response: @escaping EmptyResponseClosure)
    func showHome()
    func showSettings()
}


class SettingsViewModel: SettingsViewModelType {
    var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let entries: [[SettingsEntry]]
    fileprivate var touchEnabled: Bool
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        self.entries = [[.changePassword, .change2FA, .biometricAuth, .avatar]]
        
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool {
            self.touchEnabled = touchEnabled
        } else {
            self.touchEnabled = false
        }
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
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
            touchEnable(value: value)
        default: break
        }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        switch entry(at: indexPath) {
        case .changePassword:
            navigationCoordinator?.performTransition(transition: .showChangePassword)
        case .change2FA:
            break
        case .biometricAuth:
            break
        case .avatar:
            break
        }
    }
    
    func showPasswordHint() {
        let hint = R.string.localizable.password_hint()
        navigationCoordinator?.performTransition(transition: .showPasswordHint(hint))
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
}

fileprivate extension SettingsViewModel {
    func touchEnable(value: Bool) {
        touchEnabled = value
        UserDefaults.standard.setValue(touchEnabled, forKey: "touchEnabled")
    }
    
    func entry(at indexPath: IndexPath) -> SettingsEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func changePassword(authResponse: AuthenticationResponse, oldPass: String, newPass: String, response: @escaping GenerateAccountResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if let userSecurity = UserSecurity(from: authResponse),
                    let (publicKeyIndex188, _, wordlistMasterKey, mnemonicMasterKey) = try UserSecurityHelper.decryptUserSecurity(userSecurity, password: oldPass) {
                    
                    let userSec = try userSecurity.updatePassword(newPass, publicKeyIndex188: publicKeyIndex188, wordlistMasterKey: wordlistMasterKey, mnemonicMasterKey: mnemonicMasterKey)
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
}
