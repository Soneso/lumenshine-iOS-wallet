//
//  BiometricAuthenticationProtocol.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol BiometricAuthenticationProtocol {
    func authenticateUser(completion: @escaping BiometricAuthResponseClosure)
}
