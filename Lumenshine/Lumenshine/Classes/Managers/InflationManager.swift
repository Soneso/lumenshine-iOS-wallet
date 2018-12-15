//
//  InflationManager.swift
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

public enum GetInflationDestinationEnum {
    case success(inflationDestinationAddress: String)
    case failure(error: HorizonRequestError?)
}

public enum GetKnownInflationDestinationEnum {
    case success(response: KnownInflationDestinationResponse)
    case failure(error: ServiceError?)
}

public enum InflationDestinationErrorCodes {
    case accountNotFound
    case transactionFailed
    case invalidTransactionInput
}

public enum SetInflationDestinationEnum {
    case success
    case failure(error: InflationDestinationErrorCodes)
}

public typealias GetInflationDestinationClosure = (_ completion: GetInflationDestinationEnum) -> (Void)
public typealias GetKnownInflationDestinationClosure = (_ response: GetKnownInflationDestinationEnum) -> (Void)
public typealias SetInflationDestinationClosure = (_ completion: SetInflationDestinationEnum) -> (Void)

class InflationManager {
    private var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    private var currenciesService: CurrenciesService {
        get {
            return Services.shared.currenciesService
        }
    }
    
    private let userManager = UserManager()
    
    func getKnownInflationDestinations(completion: @escaping GetKnownInflationDestinationsClosure) {
        currenciesService.getKnownInflationDestinations { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(response: let knownInflationDestinations):
                    completion(.success(response: knownInflationDestinations))
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }

    func getKnownInflationDestination(forPublicKey destinationPublicKey: String, completion: @escaping GetKnownInflationDestinationClosure) {
        currenciesService.getKnownInflationDestinations { (response) -> (Void) in
            switch response {
            case .success(response: let knownInflationDestinations):
                for inflationDestination in knownInflationDestinations {
                    if inflationDestination.destinationPublicKey == destinationPublicKey {
                        DispatchQueue.main.async {
                            completion(.success(response: inflationDestination))
                        }
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.failure(error: nil))
                }
            case .failure(error: let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func checkAndSubmitInflationDestination(inflationAddress: String,
                                                    sourceAccountKeyPair: KeyPair,
                                                    externalSigner: String?,
                                                    externalSignersSeed: String?,
                                                    completion: @escaping SetInflationDestinationClosure) {
        userManager.checkIfAccountExists(forAccountID: inflationAddress) { (accountExists) -> (Void) in
            if accountExists {
                Services.shared.walletService.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
                    switch response {
                    case .success(let accountResponse):
                        self.submitInflationDestination(accountResponse: accountResponse,
                                                        sourceAccountKeyPair: sourceAccountKeyPair,
                                                        inflationAddress: inflationAddress,
                                                        externalSigner: externalSigner,
                                                        externalSignersSeed: externalSignersSeed,
                                                        completion: { (response) -> (Void) in
                                                            DispatchQueue.main.async {
                                                                completion(response)
                                                            }

                        })
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
                        DispatchQueue.main.async {
                            completion(.failure(error: InflationDestinationErrorCodes.transactionFailed))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error: InflationDestinationErrorCodes.accountNotFound))
                }
            }
        }
    }
    
    private func submitInflationDestination(accountResponse: AccountResponse,
                                            sourceAccountKeyPair: KeyPair,
                                            inflationAddress: String,
                                            externalSigner: String? = nil,
                                            externalSignersSeed: String? = nil,
                                            completion: @escaping SetInflationDestinationClosure) {
        do {
            var network = Network.testnet
            if (Services.shared.usePublicStellarNetwork) {
                network = Network.public
            }
            
            let setInflationOperation = try SetOptionsOperation(inflationDestination: KeyPair(accountId: inflationAddress))
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [setInflationOperation],
                                              memo: Memo.none,
                                              timeBounds:nil)
            if let signer = externalSigner, let seed = externalSignersSeed {
                let signerKeyPair = try KeyPair.init(secretSeed: seed)
                
                if signerKeyPair.accountId != signer {
                    throw SignerErorr.signerMismatch
                }
                
                try transaction.sign(keyPair: signerKeyPair, network: network)
            } else {
                try transaction.sign(keyPair: sourceAccountKeyPair, network: network)
            }
            
            try self.stellarSDK.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Change inflation destination", horizonRequestError:error)
                    completion(.failure(error: InflationDestinationErrorCodes.transactionFailed))
                }
            }
        } catch {
            completion(.failure(error: InflationDestinationErrorCodes.invalidTransactionInput))
        }
    }
}
