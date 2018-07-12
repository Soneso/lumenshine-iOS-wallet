//
//  UserManager.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 05/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public enum BoolEnum {
    case success(response: Bool)
    case failure(error: ServiceError)
}

public enum CoinEnum {
    case success(response: CoinUnit)
    case failure(error: ServiceError)
}

public enum WalletsEnum {
    case success(response: [Wallet])
    case failure(error: ServiceError)
}

public typealias BoolClosure = (_ response:BoolEnum) -> (Void)
public typealias CoinClosure = (_ response:CoinEnum) -> (Void)
public typealias WalletsClosure = (_ response:WalletsEnum) -> (Void)
public typealias CoinUnit = Double

public class UserManager: NSObject {

    var walletService: WalletsService {
        get {
            return Services.shared.walletService
        }
    }
    
    var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    func totalNativeFounds(completion: @escaping CoinClosure) {
        walletService.getWallets { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.totalBalance(wallets: data, completion: completion)
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
    func walletsForCurrentUser(completion: @escaping WalletsClosure) {
        walletService.getWallets { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.walletDetailsFor(wallets: data) { (result) -> (Void) in
                    switch result {
                    case .success(let wallets):
                        if !wallets.isEmpty {
                            completion(.success(response: wallets))
                        } else {
                            let unfoundedWallet = UnfoundedWallet()
                            completion(.success(response: [unfoundedWallet]))
                        }
                    case .failure(let error):
                        completion(.failure(error: error))
                    }
                }
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
    private func totalBalance(wallets: [WalletsResponse], completion: @escaping CoinClosure) {
        guard wallets.count > 0 else {
            completion(.success(response: 0))
            return
        }
        
        var completed = 0
        var xlm: CoinUnit = 0
        for wallet in wallets {
            stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (result) -> (Void) in
                switch result {
                case .success(let accountDetails):
                    for balance in accountDetails.balances {
                        switch balance.assetType {
                        case AssetTypeAsString.NATIVE:
                            print("balance: \(balance.balance) XLM")
                            if let units = CoinUnit(balance.balance) {
                                xlm += units
                            }
                        default:
                            break
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                completed += 1
                if completed == wallets.count {
                    completion(.success(response: xlm))
                }
            }
        }
    }
    
    private func walletDetailsFor(wallets: [WalletsResponse], completion: @escaping WalletsClosure) {
        guard wallets.count > 0 else {
            completion(.success(response: []))
            return
        }
        
        var completed = 0
        var walletDetails = [Wallet]()
        for wallet in wallets {
            stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (result) -> (Void) in
                switch result {
                case .success(let accountDetails):
                    let walletDetail = FoundedWallet(accountResponse: accountDetails)
                    walletDetails.append(walletDetail)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                completed += 1
                if completed == wallets.count {
                    completion(.success(response: walletDetails))
                }
            }
        }
    }
    
}
