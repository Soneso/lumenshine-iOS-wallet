//
//  UserManager.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 05/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public enum SigningSecurityLevel {
    case high
    case medium
    case low
}

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

public enum AddressStatusEnum {
    case success(isFunded: Bool, isTrusted: Bool?)
    case failure
}

public enum CanSignerSignOperationEnum {
    case success(canSign: Bool)
    case failure(error: HorizonRequestError)
}

public enum GetSignersListEnum {
    case success(signersList: [AccountSignerResponse])
    case failure(error: HorizonRequestError)
}

public enum HasAccountTrustlineResponseEnum {
    case success(hasTrustline: Bool, currency: AccountBalanceResponse?)
    case failure(error: HorizonRequestError)
}

public typealias BoolClosure = (_ response:BoolEnum) -> (Void)
public typealias CoinClosure = (_ response:CoinEnum) -> (Void)
public typealias WalletsClosure = (_ response:WalletsEnum) -> (Void)
public typealias AddressStatusClosure = (_ response: AddressStatusEnum) -> (Void)
public typealias CanSignerSignOperationClosure = (_ response: CanSignerSignOperationEnum) -> (Void)
public typealias GetSignersListClosure = (_ response: GetSignersListEnum) -> (Void)
public typealias HasAccountTrustlineResponseClosure = (_ response: HasAccountTrustlineResponseEnum) -> (Void)
public typealias CoinUnit = Double

public class UserManager: NSObject {
    var totalNativeFunds: CoinUnit?
    
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
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func walletsForCurrentUser(completion: @escaping WalletsClosure) {
        walletService.getWallets { (result) -> (Void) in
            switch result {
            case .success(let data):
                let sortedWallets = data.sorted(by: { $0.id < $1.id })
                self.walletDetailsFor(wallets: sortedWallets) { (result) -> (Void) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let wallets):
                            completion(.success(response: wallets))
                        case .failure(let error):
                            completion(.failure(error: error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func checkAddressStatus(forAccountID accountID: String, asset: AccountBalanceResponse, completion: @escaping AddressStatusClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { response in
            switch response {
            case .success(let accountDetails):
                
                var isTrusted = false
                
                if asset.assetIssuer == accountID {
                    isTrusted = true
                } else {
                    for balance in accountDetails.balances {
                        if balance.assetCode == asset.assetCode &&
                            balance.assetIssuer == asset.assetIssuer {
                            isTrusted = true
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(.success(isFunded: true, isTrusted: isTrusted))
                }
            case .failure(let error):
                switch error {
                case .notFound( _, _):
                    // does not exist => is not funded
                    DispatchQueue.main.async {
                        completion(.success(isFunded: false, isTrusted: false))
                    }
                default:
                    DispatchQueue.main.async {
                        completion(.failure)
                    }
                }
            }
        }
    }
    
    func checkIfAccountExists(forAccountID accountID: String, completion: @escaping ((Bool) -> (Void))) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { (accountResponse) -> (Void) in
            DispatchQueue.main.async {
                switch accountResponse {
                case .success(_):
                    completion(true)
                case .failure(let error):
                    // TODO: improve this, may be some other error
                    switch error {
                    case .notFound( _, _):
                        completion(false)
                    default:
                        // patch!
                        completion(false) // TODO handle error
                    }
                }
            }
        }
    }
    
    func createTestAccount(withAccountID accountID: String, completion: @escaping CreateTestAccountClosure) {
        stellarSDK.accounts.createTestAccount(accountId: accountID) { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(details: let details):
                    completion(.success(details: details))
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    /**
     neededSecurity:
     Low Security - "low": AllowTrust
     Medium Security - "medium": All else (e.g. payments)
     High Security - "high": AccountMerge, SetOptions for Signer and threshold
    **/
    func canSignerSignOperation(accountID: String, signerPublicKey:String, neededSecurity: SigningSecurityLevel, completion: @escaping CanSignerSignOperationClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(details: let accountDetails):
                    if let signerWeight = accountDetails.signers.first(where: { (nextSigner) -> Bool in
                        return nextSigner.publicKey == signerPublicKey
                    })?.weight {
                        
                        var neededThreshold = accountDetails.thresholds.highThreshold
                        
                        if (neededSecurity == SigningSecurityLevel.medium) {
                            neededThreshold = accountDetails.thresholds.medThreshold
                        } else if (neededSecurity == SigningSecurityLevel.low) {
                            neededThreshold = accountDetails.thresholds.lowThreshold
                        }
                        
                        if signerWeight >= neededThreshold {
                            completion(.success(canSign: true))
                        } else {
                            completion(.success(canSign: false))
                        }
                    }
                     else {
                        completion(.success(canSign: false))
                    }
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func getSignersThatCanSignOperation(accountID: String, neededSecurity: SigningSecurityLevel, completion: @escaping GetSignersListClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: accountID) { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(details: let accountDetails):
                    var signersThatCanSign: [AccountSignerResponse] = []
                    for nextSigner in accountDetails.signers {
                        var neededThreshold = accountDetails.thresholds.highThreshold
                        
                        if (neededSecurity == SigningSecurityLevel.medium) {
                            neededThreshold = accountDetails.thresholds.medThreshold
                        } else if (neededSecurity == SigningSecurityLevel.low) {
                            neededThreshold = accountDetails.thresholds.lowThreshold
                        }
                        
                        if nextSigner.weight >= neededThreshold {
                            signersThatCanSign.append(nextSigner)
                        }
                    }
                    completion(.success(signersList: signersThatCanSign))
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func hasAccountTrustline(forAccount account: String, forAssetCode assetCode: String, forAssetIssuer issuer: String, completion: @escaping HasAccountTrustlineResponseClosure) {
        // TODO: check if trustline is authorized
        stellarSDK.accounts.getAccountDetails(accountId: account) { (response) -> (Void) in
            switch response {
            case .success(details: let accountDetails):
                if let currency = accountDetails.balances.first(where: { (accountResponse) -> Bool in
                    return accountResponse.assetCode == assetCode && accountResponse.assetIssuer == issuer
                }) {
                    DispatchQueue.main.async {
                        completion(.success(hasTrustline: true, currency: currency))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(hasTrustline: false, currency: nil))
                }
                
            case .failure(error: let error): // TODO: check error, and handle
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func getAccountDetails(forAccountID account: String, completion: @escaping AccountResponseClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: account) { (response) -> (Void) in
            DispatchQueue.main.async {
                completion(response)
            }
        }
    }
    
    private func totalBalance(wallets: [WalletsResponse], completion: @escaping CoinClosure) {
        guard wallets.count > 0 else {
            completion(.success(response: 0))
            return
        }
        
        var completed = 0
        var callFailed = false
        var xlm: CoinUnit = 0
        for wallet in wallets {
            guard !callFailed else { return }
            
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
                    switch error {
                    case .notFound(_,_):
                        print(error.localizedDescription)
                    default:
                        guard !callFailed else { return }
                        callFailed = true
                        DispatchQueue.main.sync {
                            completion(.failure(error: .genericError(message: error.localizedDescription)))
                        }
                        return
                    }
                }
                
                completed += 1
                if completed == wallets.count {
                    DispatchQueue.main.async {
                        self.totalNativeFunds = xlm
                        completion(.success(response: xlm))
                    }
                }
            }
        }
    }
    
    func walletDetailsFor(wallets: [WalletsResponse], completion: @escaping WalletsClosure) {
        guard wallets.count > 0 else {
            completion(.success(response: []))
            return
        }
        
        var completed = 0
        var callFailed = false
        var walletDetails = [Wallet]()
        for wallet in wallets {
            guard !callFailed else { return }
            
            stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (result) -> (Void) in
                switch result {
                case .success(let accountDetails):
                    let walletDetail = FundedWallet(walletResponse: wallet, accountResponse: accountDetails)
                    walletDetails.append(walletDetail)
                case .failure(let error):
                    switch error {
                    case .notFound(_,_):
                        let unfundedWallet = UnfundedWallet(walletResponse: wallet)
                        walletDetails.append(unfundedWallet)
                    default:
                        guard !callFailed else { return }
                        callFailed = true
                        completion(.failure(error: .genericError(message: error.localizedDescription)))
                        return
                    }
                }
                
                completed += 1
                if completed == wallets.count {
                    completion(.success(response: walletDetails))
                }
            }
        }
    }
    
    func walletDetails(wallet: Wallet, completion: @escaping WalletsClosure) {
        stellarSDK.accounts.getAccountDetails(accountId: wallet.publicKey) { (result) -> (Void) in
            switch result {
            case .success(let accountDetails):
                let walletDetail = FundedWallet(wallet: wallet, accountResponse: accountDetails)
                completion(.success(response: [walletDetail]))
            case .failure(let error):
                switch error {
                case .notFound(_,_):
                    let unfundedWallet = UnfundedWallet(wallet: wallet)
                    completion(.success(response: [unfundedWallet]))
                default:
                    completion(.failure(error: .genericError(message: error.localizedDescription)))
                }
            }
        }
    }
}
