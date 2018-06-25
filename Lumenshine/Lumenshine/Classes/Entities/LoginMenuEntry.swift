//
//  LoginMenuEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/23/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift

enum LoginMenuEntry {
    case avatar
    case login
    case signUp
    case lostPassword
    case lost2FA
    case importMnemonic
    case about
    case help
    
    var name: String {
        switch self {
        case .avatar:
            return R.string.localizable.not_logged_in()
        case .login:
            return R.string.localizable.login()
        case .signUp:
            return R.string.localizable.signup()
        case .lostPassword:
            return R.string.localizable.lost_password()
        case .lost2FA:
            return R.string.localizable.lost_2fa()
        case .importMnemonic:
            return R.string.localizable.import_mnemonic()
        case .about:
            return R.string.localizable.about()
        case .help:
            return R.string.localizable.help()
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .avatar:
            return R.image.rocket
        case .login:
            return R.image.sign
        case .signUp:
            return R.image.pencil
        case .lostPassword:
            return R.image.compose
        case .lost2FA:
            return R.image.combination_lock
        case .importMnemonic:
            return R.image.user_add
        case .about:
            return R.image.star
        case .help:
            return R.image.question

        }
    }
}
