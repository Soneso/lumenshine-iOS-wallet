//
//  LoginViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

struct KeychainConfiguration {
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

protocol LoginViewModelType: Transitionable {
    
    func createAccount(username: String, password: String)
    func checkLogin(username: String, password: String) -> Bool
    func loginCompleted()
    
    func biometricType() -> BiometricType
    func canEvaluatePolicy() -> Bool
    func authenticateUser(completion: @escaping (String?) -> Void)
    
    func signUpClick()
}

class LoginViewModel : LoginViewModelType {
    fileprivate let touchMe = BiometricIDAuth()
    
    weak var navigationCoordinator: CoordinatorType?
    
    init() {
    }
    
    func loginCompleted() {
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
        let user = User(id: "1", name: username)
        self.navigationCoordinator?.performTransition(transition: .showMain(user))
        touchMe.invalidate()
    }
    
    func createAccount(username: String, password: String) {
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey && username.count > 0 {
            UserDefaults.standard.setValue(username, forKey: "username")
        }
        
        do {
            
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        guard username == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        }
        catch {
            fatalError("Error reading password from keychain - \(error)")
        }
        return false
    }
    
    func signUpClick() {
        self.navigationCoordinator?.performTransition(transition: .showSignUp)
    }
    
    // MARK: Biometric authentication
    
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
