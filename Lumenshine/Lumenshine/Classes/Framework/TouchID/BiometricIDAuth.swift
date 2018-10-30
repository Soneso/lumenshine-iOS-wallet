//
//  BiometricIDAuth.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricIDAuth {
    fileprivate var context: LAContext
    var loginReason = "Logging in with Touch ID"
    
    init() {
        context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = 0
    }
    
    func invalidate() {
        context.invalidate()
        context = LAContext()
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return .none
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(completion: @escaping (Error?) -> Void) {
        guard canEvaluatePolicy() else {
            completion(LAError(.touchIDNotAvailable))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                completion(nil)
            } else {
                completion(evaluateError)
            }
        }
    }
}

extension Error {
    public var errorDescription: String {
        var message: String
        switch self {
        case LAError.authenticationFailed:
            message = "There was a problem verifying your identity."
        case LAError.userCancel:
            message = ""
        case LAError.userFallback:
            message = "You pressed password."
        default:
            message = self.localizedDescription
        }
        
        if #available(iOS 11.0, *) {
            switch self {
            case LAError.biometryNotAvailable:
                message = "Face ID/Touch ID is not available."
            case LAError.biometryNotEnrolled:
                message = "Face ID/Touch ID is not set up."
            case LAError.biometryLockout:
                message = "Face ID/Touch ID is locked."
            default:
                break
            }
        }
        return message
    }
}

