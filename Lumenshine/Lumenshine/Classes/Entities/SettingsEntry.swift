//
//  SettingsEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/24/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum SettingsEntry {
    case changePassword
    case change2FA
    case biometricAuth
    case avatar
    
    var name: String {
        switch self {
        case .changePassword:
            return R.string.localizable.change_password()
        case .change2FA:
            return R.string.localizable.change_2fa()
        case .biometricAuth:
            return R.string.localizable.fingerprint_recognition()
        case .avatar:
            return R.string.localizable.avatar()
        }
    }
}
