//
//  KnownCurrenciesManager.swift
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

public class KnownCurrency {
    var name: String!
    var assetCode: String!
    var issuerPublicKey: String!
    var isAuthorized: Bool!
}

public enum KnownCurrenciesEnum {
    case success(response: [KnownCurrency])
    case failure(error: ServiceError)
}

public typealias KnownCurrenciesClosure = (_ response: KnownCurrenciesEnum) -> (Void)

class KnownCurrenciesManager {
    private var currenciesService: CurrenciesService {
        get {
            return Services.shared.currenciesService
        }
    }
    
    private var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    func getKnownCurrencies(completion: @escaping KnownCurrenciesClosure) {
        currenciesService.getKnownCurrencies { (response) -> (Void) in
            switch response {
            case .success(response: let knownCurrencies):
                var authorizationsCheckedCount = 0
                var knownCurrenciesToReturn = [KnownCurrency]()
                for currency in knownCurrencies {
                    let knownCurrency = KnownCurrency()
                    knownCurrency.name = currency.name
                    knownCurrency.assetCode = currency.assetCode
                    knownCurrency.issuerPublicKey = currency.issuerPublicKey
                    knownCurrenciesToReturn.append(knownCurrency)
                    
                    self.isAuthorizationRequired(forCurrency: knownCurrency, completion: { () -> (Void) in
                        authorizationsCheckedCount += 1
                        
                        if authorizationsCheckedCount == knownCurrencies.count {
                            DispatchQueue.main.async {
                                completion(.success(response: knownCurrenciesToReturn))
                            }
                        }
                    })
                }
            case .failure(error: let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    private func isAuthorizationRequired(forCurrency currency: KnownCurrency, completion: @escaping () -> (Void)) {
        Services.shared.walletService.getAccountDetails(accountId: currency.issuerPublicKey) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                currency.isAuthorized = accountDetails.flags.authRequired
                completion()
            case .failure(let error):
                print("Authorization check failed. Error: \(error)")
                completion()
            }
        }
    }
}
