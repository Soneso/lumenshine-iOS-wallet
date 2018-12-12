//
//  WalletManager.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 09/08/2018.
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
    
    func effectsForWallet(wallet: String, completion: @escaping EffectsClosure) {
        var effects = [EffectResponse]()
        
        stellarSDK.effects.getEffects(forAccount: wallet, limit: limit) { (response) -> (Void) in
            switch response {
            case .success(let elements):
                effects.append(contentsOf: elements.records)
                self.effectsAfter(response: elements, effects: effects, completion: completion)
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
    func balancesWithAuthorizationForWallet(wallet: Wallet, completion: @escaping BalancesClosure) {
        var count = 0
        var assetsWithIssuers = 0
        
        stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                for balance in accountDetails.balances {
                    if let issuer = balance.assetIssuer {
                        assetsWithIssuers += 1
                        self.balanceAuthorized(issuer: issuer, completion: { (authorized, error) in
                            guard error == nil else {
                                return
                            }
                            
                            balance.authorized = authorized
                            count += 1
                            if assetsWithIssuers == count {
                                DispatchQueue.main.async {
                                    completion(.success(response: accountDetails.balances))
                                }
                            }
                        })
                    }
                }
                
                if assetsWithIssuers == 0 {
                    DispatchQueue.main.async {
                        completion(.success(response: accountDetails.balances))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
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
    
    public func updateWallets(currentWallet: inout Wallet, updatedWallets: [Wallet], walletsList: inout [Wallet]) {
        for wallet in walletsList {
            if let updatedWallet = updatedWallets.first(where: { (item) -> Bool in
                return item.publicKey == wallet.publicKey
            }) {
                if let indexOfWalletToUpdate = walletsList.firstIndex(where: { (item) -> Bool in
                    return item.publicKey == wallet.publicKey
                }) {
                    walletsList.remove(at: indexOfWalletToUpdate)
                    walletsList.insert(updatedWallet, at: indexOfWalletToUpdate)
                }
            }
        }

        if let updatedCurrentWallet = updatedWallets.first(where: { (updatedWallet) -> Bool in
            return updatedWallet.publicKey == currentWallet.publicKey
        }) {
            currentWallet = updatedCurrentWallet
        }
    }
    
    private func balanceAuthorized(issuer: String, completion: @escaping ((Bool, HorizonRequestError?)->())) {
        stellarSDK.accounts.getAccountDetails(accountId: issuer) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                if accountDetails.flags.authRequired {
                    self.checkEffectsForAuthorziation(issuer: issuer, completion: completion)
                } else {
                    completion(true, nil)
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    private func checkEffectsForAuthorziation(issuer: String, completion: @escaping ((Bool, HorizonRequestError?)->())) {
        effectsForWallet(wallet: issuer) { (response) -> (Void) in
            switch response {
            case .success(let effects):
                for index in stride(from: effects.count - 1, through: 0, by: -1) {
                    let effect = effects[index]
                    if effect.effectType == .trustlineDeauthorized, let _ = effect as? TrustlineDeauthorizedEffectResponse {
                        completion(true, nil)
                    }
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    private func effectsAfter(response: PageResponse<EffectResponse>, effects: [EffectResponse], completion: @escaping EffectsClosure) {
        var effects = effects
        if response.hasNextPage() {
            response.getNextPage { (response) -> (Void) in
                switch response {
                case .success(let elements):
                    effects.append(contentsOf: elements.records)
                    self.effectsAfter(response: elements, effects: effects, completion: completion)
                case .failure(let error):
                    completion(.failure(error: error))
                }
            }
        } else {
            completion(.success(response: effects))
        }
    }
}
