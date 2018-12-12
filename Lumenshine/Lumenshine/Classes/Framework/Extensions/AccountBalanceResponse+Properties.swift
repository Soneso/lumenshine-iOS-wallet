//
//  AccountBalanceResponse+Properties.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk
import ObjectiveC

private var balanceAuthorizedAssociationKey: UInt8 = 0

extension AccountBalanceResponse {

    var authorized: Bool? {
        get {
            return objc_getAssociatedObject(self, &balanceAuthorizedAssociationKey) as? Bool
        }
        set(newValue) {
            objc_setAssociatedObject(self, &balanceAuthorizedAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}
