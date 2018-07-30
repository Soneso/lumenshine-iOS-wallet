//
//  AccountBalanceResponse+Extra.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 25/07/2018.
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
