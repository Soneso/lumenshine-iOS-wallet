//
//  AccountBalanceResponse+Extra.swift
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

extension AccountBalanceResponse {
    
    var displayCode: String? {
        get {
            if assetType == "native" {
                return "XLM"
            }
            
            return assetCode
        }
    }
    
}
