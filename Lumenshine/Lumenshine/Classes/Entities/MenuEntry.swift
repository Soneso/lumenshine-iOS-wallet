//
//  MenuEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/15/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift

enum MenuEntry {
    case avatar
    case home
    case wallets
    case transactions
    case currencies
    case contacts
    case extras
    case settings
    case help
    
    var name: String? {
        switch self {
        case .avatar:
            return nil
        case .home:
            return R.string.localizable.home()
        case .wallets:
            return R.string.localizable.wallets()
        case .transactions:
            return R.string.localizable.transactions()
        case .currencies:
            return R.string.localizable.currencies()
        case .contacts:
            return R.string.localizable.contacts()
        case .extras:
            return R.string.localizable.extras()
        case .settings:
            return R.string.localizable.settings()
        case .help:
            return R.string.localizable.help()
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .avatar:
            return R.image.rocket
        case .home:
            return R.image.home
        case .wallets:
            return R.image.money1
        case .transactions:
            return R.image.top_list
        case .currencies:
            return R.image.money2
        case .contacts:
            return R.image.users
        case .extras:
            return R.image.puzzlePiece
        case .settings:
            return R.image.gear
        case .help:
            return R.image.question
        }
    }
}
