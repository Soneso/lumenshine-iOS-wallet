//
//  CoinUnit+Additions.swift
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
    
    var shortStringWithUnit: String {
        get {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.minimumFractionDigits = 2
            currencyFormatter.maximumFractionDigits = 2
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
    
    func tickerConversionTo(currency: Currency, rate: Double) -> String {
        let result:CoinUnit = rate * self
        return "\(shortStringWithUnit) XLM ≈ \(String(format: "%@ %@", result.shortStringWithUnit, currency.assetCode))"
    }
}
