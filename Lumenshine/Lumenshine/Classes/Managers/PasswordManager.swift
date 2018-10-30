//
//  PasswordManager.swift
//  Lumenshine
//
//  Created by Soneso on 30/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

enum PasswordEnum {
    case success(mnemonic: String)
    case failure(error: String)
}

enum PrivateKeyEnum {
    case success(privateKey: String?)
    case failure(error: String)
}

typealias PasswordClosure = (_ response: PasswordEnum) -> (Void)
typealias PrivateKeyClosure = (_ response: PrivateKeyEnum) -> (Void)

class PasswordManager {
    private var AuthService: AuthService {
        get {
            return Services.shared.auth
        }
    }
    
   private func getMnemonicFromBiometricAuth(completion: @escaping PasswordClosure) {
        let biometricIDAuth = BiometricIDAuth()
        if biometricIDAuth.canEvaluatePolicy() {
            biometricIDAuth.authenticateUser(completion: { error in
                
                if let err = error {
                    completion(.failure(error: err.errorDescription))
                } else {
                    BiometricHelper.getMnemonic(completion: { (response) -> (Void) in
                        switch response {
                        case .success(mnemonic: let mnemonic):
                            completion(.success(mnemonic: mnemonic))
                        case .failure(error: let error):
                            completion(.failure(error: error))
                        }
                    })
                }
            })
        }
    }
    
   private func getMnemonic(fromPassword password: String, completion: @escaping PasswordClosure) {
        Services.shared.auth.authenticationData { result in
            switch result {
            case .success(let authResponse):
                if let userSecurity = UserSecurity(from: authResponse),
                    let decryptUserSecurity = try? UserSecurityHelper.decryptUserSecurity(userSecurity, password: password) {
                    if let decryptedUserSecurity = decryptUserSecurity {
                        completion(.success(mnemonic: decryptedUserSecurity.mnemonic))
                    }
                    else {
                        completion(.failure(error: "Wrong password"))
                    }
                } else {
                    completion(.failure(error: "Wrong password"))
                }
                
            case .failure(let error):
                completion(.failure(error: error.localizedDescription))
            }
        }
    }
    
    func getMnemonic(password: String? = nil, completion: @escaping (PasswordEnum) -> (Void)) {
        if let password = password {
            getMnemonic(fromPassword: password) { (result) -> (Void) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(mnemonic: let mnemonic):
                        completion(.success(mnemonic: mnemonic))
                        
                    case .failure(error: let error):
                        completion(.failure(error: error))
                    }
                }
            }
        } else {
            getMnemonicFromBiometricAuth { (result) -> (Void) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(mnemonic: let mnemonic):
                        completion(.success(mnemonic: mnemonic))
                        
                    case .failure(let error):
                        completion(.failure(error: error))
                    }
                }
            }
        }
    }
    
    func getPrivateKey(fromPassword password: String, forAccountID accountID: String, completion: @escaping PrivateKeyClosure) {
        getMnemonic(fromPassword: password) { (response) -> (Void) in
            switch response {
            case .success(mnemonic: let mnemonic):
                PrivateKeyManager.getKeyPair(forAccountID: accountID, fromMnemonic: mnemonic, completion: { (response) -> (Void) in
                    switch response {
                    case .success(keyPair: let keyPair):
                        DispatchQueue.main.async {
                            completion(.success(privateKey: keyPair?.secretSeed))
                        }
                    
                    case .failure(error: let error):
                        print(error)
                        DispatchQueue.main.async {
                            completion(.failure(error: "KeyPair not found"))
                        }
                    }
                })
                
            case .failure(error: let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
}
