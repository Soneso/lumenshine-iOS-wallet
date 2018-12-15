//
//  WalletManager.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public enum EffectsEnum {
    case success(response: [EffectResponse])
    case failure(error: HorizonRequestError)
}

public enum BalancesEnum {
    case success(response: [AccountBalanceResponse])
    case failure(error: HorizonRequestError)
}

public enum WalletsForSendingPaymentEnum {
    case success(fundedWallets: [FundedWallet], paymentDestination: String?)
    case failure(error: String)
    case noFunding
}

public typealias EffectsClosure = (_ response:EffectsEnum) -> (Void)
public typealias BalancesClosure = (_ response:BalancesEnum) -> (Void)
public typealias WalletsForSendingPaymentClosure = (_ response: WalletsForSendingPaymentEnum) -> (Void)

class WalletManager: NSObject {
    let limit = 200
    
    var stellarSDK = Services.shared.stellarSdk
    private let userManager = UserManager()
    
    func hasWalletEnoughFunding(wallet: Wallet) -> Bool {
        return !wallet.nativeBalance.availableAmount(forWallet: wallet, forCurrency: (wallet as? FundedWallet)?.nativeAsset).isLess(than: CoinUnit.minimumAccountBalance(forWallet: wallet))
    }
    
    private func getFundedWallets(wallets: [Wallet]) -> [FundedWallet] {
        var fundedWallets = [FundedWallet]()
        
        for wallet in wallets {
            if let fundedWallet = wallet as? FundedWallet {
                fundedWallets.append(fundedWallet)
            }
        }
        
        return fundedWallets
    }
    
    func walletsForSendingPayment(stellarAddress: String? = nil, publicKey: String? = nil, completion: @escaping WalletsForSendingPaymentClosure) {
        userManager.walletsForCurrentUser { (response) -> (Void) in
            switch response {
            case .success(response: let wallets):
                let fundedWallets = self.getFundedWallets(wallets: wallets)
                
                if fundedWallets.count == 0 {
                    DispatchQueue.main.async {
                        completion(.noFunding)
                    }
                    return
                }
                
                if let address = stellarAddress {
                    DispatchQueue.main.async {
                        completion(.success(fundedWallets: fundedWallets, paymentDestination: address))
                    }
                } else if let publicKey = publicKey {
                    DispatchQueue.main.async {
                        completion(.success(fundedWallets: fundedWallets, paymentDestination: publicKey))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(fundedWallets: fundedWallets, paymentDestination: nil))
                    }
                }
            case .failure(error: let error):
                completion(.failure(error: error.localizedDescription))
            }
        }
    }
}
