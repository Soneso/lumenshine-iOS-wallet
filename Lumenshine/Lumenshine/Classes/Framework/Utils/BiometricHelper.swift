//
//  BiometricHelper.swift
//  Lumenshine
//
//  Created by Soneso on 29/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum BiometricStatus: String {
    case success
    case enterPasswordPressed = "You pressed password."
}

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
}
