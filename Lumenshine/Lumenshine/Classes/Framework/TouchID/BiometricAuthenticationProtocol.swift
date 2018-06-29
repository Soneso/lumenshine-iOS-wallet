//
//  BiometricAuthenticationProtocol.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol BiometricAuthenticationProtocol {
    func biometricType() -> BiometricType
    func canEvaluatePolicy() -> Bool
    func authenticateUser(completion: @escaping (String?) -> Void)
}
