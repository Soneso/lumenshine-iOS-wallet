//
//  BiometricHelper.swift
//  Lumenshine
//
//  Created by Soneso on 29/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum BiometricAuthResponseEnum {
    case success(response: String)
    case failure(error: String)
}

enum BiometricStatus: String {
    case success
    case enterPasswordPressed = "You pressed password."
}

typealias BiometricAuthResponseClosure = (_ response:BiometricAuthResponseEnum) -> (Void)

class BiometricHelper {
    static var UserMnemonic: String?
    static let touchIDKey = "touchEnabled"
    static var isBiometricAuthEnabled: Bool {
        get {
            if let touchEnabled = UserDefaults.standard.value(forKey: BiometricHelper.touchIDKey) as? Bool {
                if touchEnabled {
                    let biometricIDAuth = BiometricIDAuth()
                    if biometricIDAuth.canEvaluatePolicy() {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    static func enableTouch(_ touch: Bool) {
        UserDefaults.standard.setValue(touch, forKey: BiometricHelper.touchIDKey)
    }
    
    static var isTouchEnabled: Bool {
        if let touchEnabled = UserDefaults.standard.value(forKey: BiometricHelper.touchIDKey) as? Bool {
            return touchEnabled
        } else {
            return false
        }
    }
    
    static func save(user: String, password: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: user,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch {
            print("Error updating keychain: \(error)")
        }
    }
    
    static func password(for username: String) -> String? {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return keychainPassword
        } catch {
            print("Error reading password from keychain: \(error)")
            return nil
        }
    }
    
    static func authenticate(username: String, response: @escaping BiometricAuthResponseClosure) {
        let touchAuth = BiometricIDAuth()
        touchAuth.authenticateUser() { error in
            if let err = error {
                response(.failure(error: err))
            } else {
                if let password = password(for: username) {
                    response(.success(response: password))
                } else {
                    response(.failure(error: R.string.localizable.missing_password()))
                }
            }
        }
    }
}
