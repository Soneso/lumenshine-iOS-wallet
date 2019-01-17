//
//  BiometricHelper.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift
import OneTimePassword

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
            if let touchEnabled = UserDefaults.standard.value(forKey: Keys.UserDefs.TouchID) as? Bool {
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
        var persistedUserEmail:String? = nil
        
        do {
            let persistentTokens = try Keychain.sharedInstance.allPersistentTokens()
            for token in persistentTokens {
                persistedUserEmail = token.token.name
                break
            }
        } catch {
            completion(.failure(error: "Password not found for user!"))
        }
        
        if let userName = persistedUserEmail {
            password(for: userName) { result in
                switch result {
                case .success(let password):
                    passwordManager.getMnemonic(password: password) { (response) -> (Void) in
                        DispatchQueue.main.async {
                            completion(response)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error: error.errorDescription))
                    }
                }
            }
        } else {
            //user not found
            DispatchQueue.main.async {
                completion(.failure(error: "Password not found for user!"))
            }
        }
    }
    
    static var touchIcon: ImageResource {
        return BiometricIDAuth().biometricType() == .faceID ? R.image.faceIcon : R.image.touchIcon
    }
    
    static func enableTouch(_ touch: Bool) {
        UserDefaults.standard.setValue(touch, forKey: Keys.UserDefs.TouchID)
    }
    
    static var isTouchEnabled: Bool {
        if let touchEnabled = UserDefaults.standard.value(forKey: Keys.UserDefs.TouchID) as? Bool {
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
    
    static private func password(for username: String, response: @escaping BiometricAuthResponseClosure) {
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
    
    static func removePasswords() {
        do {
            let passwords = try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName,
                                                               accessGroup: KeychainConfiguration.accessGroup)
            for password in passwords {
                try password.deleteItem()
            }
        } catch {
            print("Error deleting passwords from keychain: \(error)")
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
