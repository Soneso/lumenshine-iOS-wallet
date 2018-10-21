//
//  InputDataValidator.swift
//  Lumenshine
//
//  Created by Soneso on 30/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk


enum PasswordAndDestionationAddressValidityEnum {
    case success(userMnemonic: String)
    case failure(errorCode: PasswordAndAddressErrorCodes)
}

enum PasswordAndAddressErrorCodes: Int {
    case addressNotFound = 0
    case incorrectPassword = 1
    case enterPasswordPressed = 2
}

typealias PasswordAndDestinationAddressValidityClosure = (_ response: PasswordAndDestionationAddressValidityEnum) -> (Void)


class InputDataValidator {
    private let passwordManager = PasswordManager()
    private let userManager = UserManager()
    
    func isPasswordAndDestinationAddresValid(address: String, password: String? = nil, completion: @escaping PasswordAndDestinationAddressValidityClosure) {
        userManager.checkIfAccountExists(forAccountID: address) { (accountExists) -> (Void) in
            if accountExists {
                self.passwordManager.getMnemonic(password: password) { (passwordResult) -> (Void) in
                    DispatchQueue.main.async {
                        switch passwordResult {
                        case .success(mnemonic: let mnemonic):
                            completion(.success(userMnemonic: mnemonic))
                        case .failure(error: let error):
                            if error == BiometricStatus.enterPasswordPressed.rawValue {
                                completion(.failure(errorCode: .enterPasswordPressed))
                            } else {
                                completion(.failure(errorCode: .incorrectPassword))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(errorCode: .addressNotFound))
                }
            }
        }
    }
}
