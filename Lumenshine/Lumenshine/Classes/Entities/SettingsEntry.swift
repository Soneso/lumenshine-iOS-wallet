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
    case fingerprint
    case faceRecognition
    case backupMnemonic
    case notifications
    case personalData
    case avatar
    case chartCurrency
    
    var name: String {
        switch self {
        case .changePassword:
            return R.string.localizable.change_password()
        case .change2FA:
            return R.string.localizable.change_2fa()
        case .fingerprint:
            return R.string.localizable.fingerprint()
        case .faceRecognition:
            return R.string.localizable.face_recognition()
        case .avatar:
            return R.string.localizable.avatar()
        case .backupMnemonic:
            return R.string.localizable.backup_mnemonic()
        case .notifications:
            return R.string.localizable.notifications()
        case .personalData:
            return R.string.localizable.personal_data()
        case .chartCurrency:
            return R.string.localizable.chart_currency()
        }
    }
}
