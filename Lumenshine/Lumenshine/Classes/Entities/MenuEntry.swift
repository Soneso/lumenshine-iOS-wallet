//
//  MenuEntry.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift

enum MenuEntry {
    // Dashboard
    case avatar
    case home
    case wallets
    case transactions
    case currencies
    case ICOs
    case myOrders
    case contacts
    case extras
    case settings
    case help
    
    // Login
    case login
    case signOut
    case signUp
    case lostPassword
    case lost2FA
    case importMnemonic
    case fingerprint
    case faceRecognition
    case about
    
    var name: String {
        switch self {
        case .avatar:
            return R.string.localizable.not_logged_in()
        case .home:
            return R.string.localizable.home()
        case .wallets:
            return R.string.localizable.wallets()
        case .transactions:
            return R.string.localizable.transactions()
        case .currencies:
            return R.string.localizable.currencies()
        case .myOrders:
            return R.string.localizable.my_orders()
        case .ICOs:
            return R.string.localizable.icos()
        case .contacts:
            return R.string.localizable.contacts()
        case .extras:
            return R.string.localizable.extras()
        case .settings:
            return R.string.localizable.settings()
        case .help:
            return R.string.localizable.help()
        case .login:
            return R.string.localizable.login()
        case .signOut:
            return R.string.localizable.signout()
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
        case .fingerprint:
            return R.string.localizable.fingerprint_cap()
        case .faceRecognition:
            return R.string.localizable.face_recognition_cap()
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .avatar:
            return R.image.user
        case .home:
            return R.image.home
        case .wallets:
            return R.image.wallets
        case .transactions:
            return R.image.transactions
        case .currencies:
            return R.image.currencies
        case .myOrders:
            return R.image.my_orders
        case .ICOs:
            return R.image.ico
        case .contacts:
            return R.image.user
        case .extras:
            return R.image.star
        case .settings:
            return R.image.gear
        case .help:
            return R.image.question
        case .login:
            return R.image.signIn
        case .signOut:
            return R.image.signOut
        case .signUp:
            return R.image.pencil
        case .lostPassword:
            return R.image.link
        case .lost2FA:
            return R.image.lost_2fa
        case .importMnemonic:
            return R.image.user
        case .about:
            return R.image.star
        case .fingerprint:
            return R.image.fingerprint
        case .faceRecognition:
            return R.image.face_recognition
        }
        
    }
}
