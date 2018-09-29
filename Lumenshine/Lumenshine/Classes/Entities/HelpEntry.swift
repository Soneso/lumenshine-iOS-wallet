//
//  HelpEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/27/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift

enum HelpEntry {
    
    case inbox
    case FAQ1
    case FAQ2
    case FAQ3
    case FAQ4
    case basics
    case security
    case wallets
    case stellar
    //case ICO
    
    var title: String? {
        switch self {
        case .inbox:
            return R.string.localizable.support_inbox()
        case .FAQ1:
            return R.string.localizable.faq_1()
        case .FAQ2:
            return R.string.localizable.faq_2()
        case .FAQ3:
            return R.string.localizable.faq_3()
        case .FAQ4:
            return R.string.localizable.faq_4()
        case .basics:
            return R.string.localizable.basics()
        case .security:
            return R.string.localizable.security()
        case .wallets:
            return R.string.localizable.wallets()
        case .stellar:
            return R.string.localizable.stellar()
        /*case .ICO:
            return R.string.localizable.ico()*/
        }
    }
    
    var detail: String? {
        switch self {
        case .basics:
            return R.string.localizable.basics_detail()
        case .security:
            return R.string.localizable.security_detail()
        case .wallets:
            return R.string.localizable.wallets_detail()
        case .stellar:
            return R.string.localizable.stellar_detail()
        /*case .ICO:
            return R.string.localizable.ico_detail()*/
        default:
            return nil
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .inbox:
            return R.image.inbox
        case .FAQ1, .FAQ2, .FAQ3, .FAQ4:
            return R.image.faq
        case .basics:
            return R.image.basics
        case .security:
            return R.image.security
        case .wallets:
            return R.image.wallets2
        case .stellar:
            return R.image.stellar
        /*case .ICO:
            return R.image.ico2*/
        }
    }
}
