//
//  CoinUnit+Additions.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 15/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

extension CoinUnit {
    
    struct Constants {
        static let baseReserver: CoinUnit = 0.5
        static let transactionFee: CoinUnit = 0.00001
    }
    
    var stringWithUnit: String {
        get {
            return String(format: "%.2f XLM", self)
        }
    }
    
    var availableAmount: CoinUnit {
        get {
            return self - Constants.baseReserver - Constants.transactionFee
        }
    }
    
    func stringConversionTo(currency: Currency, rate: Double) -> String {
        return "\(stringWithUnit) ≈ \(String(format: "%.2f %@", rate * self, currency.assetCode))"
    }
    
}
