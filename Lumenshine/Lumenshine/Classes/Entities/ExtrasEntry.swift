//
//  SettingsEntry.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 23/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum ExtrasEntry {
    case mergeExternalAccount
    case mergeWallet
    
    var name: String {
        switch self {
        case .mergeExternalAccount:
            return R.string.localizable.merge_external_account()
        case .mergeWallet:
            return R.string.localizable.merge_wallet()
        }
    }
}
