//
//  Wallet.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 11/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public protocol Wallet {
    var name: String { get }
    var nativeBalance: CoinUnit { get }
    var isFounded: Bool { get }
}

public class FoundedWallet: Wallet {
    public var name: String
    
    var balances: [AccountBalanceResponse]
    
    init(walletResponse: WalletsResponse, accountResponse: AccountResponse) {
        self.balances = accountResponse.balances
        self.name = walletResponse.walletName
    }
    
    public var nativeBalance: CoinUnit {
        get {
            var amount: CoinUnit = 0
            for balance in balances {
                switch balance.assetType {
                case AssetTypeAsString.NATIVE:
                    print("balance: \(balance.balance) XLM")
                    if let units = CoinUnit(balance.balance) {
                        amount += units
                    }
                default:
                    break
                }
            }
            
            return amount
        }
    }
    
    public var isFounded: Bool {
        get {
            return nativeBalance != 0
        }
    }
}

public class UnfoundedWallet: Wallet {
    public var name: String
    
    public var nativeBalance: CoinUnit {
        get {
            return 0
        }
    }
    
    public var isFounded: Bool {
        get {
            return false
        }
    }
    
    init(walletResponse: WalletsResponse) {
        self.name = walletResponse.walletName
    }
}
