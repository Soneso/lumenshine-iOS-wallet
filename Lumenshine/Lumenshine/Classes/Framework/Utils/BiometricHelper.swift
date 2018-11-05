//
//  BiometricHelper.swift
//  Lumenshine
//
//  Created by Soneso on 29/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift

enum BiometricAuthResponseEnum {
    case success(response: String)
    case failure(error: Error)
}

enum BiometricStatus: String {
    case success
    case enterPasswordPressed = "You pressed password."
}

typealias BiometricAuthResponseClosure = (_ response:BiometricAuthResponseEnum) -> (Void)

class BiometricHelper {
    static var isBiometricAuthEnabled: Bool {
        get {
            if let touchEnabled = UserDefaults.standard.value(forKey: Keys.touchID) as? Bool {
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
    
    static func getMnemonic(completion: @escaping PasswordClosure) {
        let passwordManager = PasswordManager()
        if let userName = UserDefaults.standard.value(forKey: "username") as? String {
            password(for: userName) { result in
                switch result {
                case .success(let password):
                    passwordManager.getMnemonic(password: password) { (response) -> (Void) in
                        completion(response)
                    }
                case .failure(let error):
                    completion(.failure(error: error.errorDescription))
                }
            }
        }
    }
    
    static var touchIcon: ImageResource {
        return BiometricIDAuth().biometricType() == .faceID ? R.image.faceIcon : R.image.touchIcon
    }
    
    static func enableTouch(_ touch: Bool) {
        UserDefaults.standard.setValue(touch, forKey: Keys.touchID)
    }
    
    static var isTouchEnabled: Bool {
        if let touchEnabled = UserDefaults.standard.value(forKey: Keys.touchID) as? Bool {
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
    
    static func password(for username: String, response: @escaping BiometricAuthResponseClosure) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            response(.success(response: keychainPassword))
        } catch (let error) {
            print("Error reading password from keychain: \(error)")
            response(.failure(error: error))
        }
    }
    
    static func removePassword(username: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.deleteItem()
        } catch {
            print("Error deleting password from keychain: \(error)")
        }
    }
    
    static func authenticate(username: String, response: @escaping BiometricAuthResponseClosure) {
        let touchAuth = BiometricIDAuth()
        touchAuth.authenticateUser() { error in
            if let err = error {
                response(.failure(error: err))
            } else {
                password(for: username, response: response)
            }
        }
    }
}
