//
//  CoinUnit+Additions.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 15/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

extension CoinUnit {
    static func minimumReserved(forWallet wallet: Wallet?) -> CoinUnit {
        if let fundedWallet = wallet as? FundedWallet {
            return 1 + CoinUnit(fundedWallet.subentryCount) * Constants.baseReserver + Constants.transactionFee
        }
        
        return 0
    }
    
    struct Constants {
        static let baseReserver: CoinUnit = 0.5
        static let transactionFee: CoinUnit = 0.00001
    }
    
    var stringWithUnit: String {
        get {
            return String(format: "%.2f XLM", self)
        }
    }
    
    func availableAmount(forWallet wallet: Wallet?) -> CoinUnit {
        let availableAmount = self - CoinUnit.minimumReserved(forWallet: wallet) - Constants.transactionFee
        
        if availableAmount > 0 {
            return availableAmount
        } else {
            return 0
        }
    }
    
    func stringConversionTo(currency: Currency, rate: Double) -> String {
        return "\(stringWithUnit) ≈ \(String(format: "%.2f %@", rate * self, currency.assetCode))"
    }
}
