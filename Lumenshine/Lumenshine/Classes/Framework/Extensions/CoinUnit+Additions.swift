//
//  CoinUnit+Additions.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 15/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

extension CoinUnit {
    static func minimumAccountBalance(forWallet wallet: Wallet?) -> CoinUnit {
        if let fundedWallet = wallet as? FundedWallet {
            return (2 + CoinUnit(fundedWallet.subentryCount)) * Constants.baseReserver
        }
        
        return 0
    }
    
    struct Constants {
        static let baseReserver: CoinUnit = 0.5
        static let transactionFee: CoinUnit = 0.00001
    }
    
    var stringWithUnit: String {
        get {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.minimumFractionDigits = 2
            currencyFormatter.maximumFractionDigits = 5
            currencyFormatter.numberStyle = .decimal
            currencyFormatter.locale = Locale.current
            
            let value = currencyFormatter.string(from: NSNumber(value: self))
            
            return value ?? "0.00"
        }
    }
    
    func availableAmount(forWallet wallet: Wallet?, forCurrency asset: AccountBalanceResponse?) -> CoinUnit {
        if let asset = asset {
            let sellingLiabilities = CoinUnit(asset.sellingLiabilities)
            if let _ = asset.assetCode {
                //non native
                return self - (sellingLiabilities ?? 0)
            } else {
                //native
                return self - CoinUnit.minimumAccountBalance(forWallet: wallet) - (sellingLiabilities ?? 0)
            }
        } else {
            return 0
        }
    }
    
    func stringConversionTo(currency: Currency, rate: Double) -> String {
        return "\(stringWithUnit) ≈ \(String(format: "%.2f %@", rate * self, currency.assetCode))"
    }
}
