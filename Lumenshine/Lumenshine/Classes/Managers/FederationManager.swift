//
//  FederationManager.swift
//  Lumenshine
//
//  Created by Soneso on 30/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

enum AddressEnum {
    case success(response: String)
    case failure(error: FederationError)
}

typealias FederationClosure = (_ response: AddressEnum) -> (Void)

class FederationManager {
    private var userManager = UserManager()
    
    func resolveFederationAddress(forDomain domain: String, completion: @escaping FederationClosure) {
        Federation.forDomain(domain: domain) { (response) -> (Void) in
            DispatchQueue.main.async {
                switch response {
                case .success(response: let federation):
                        completion(.success(response: federation.federationAddress))
                case .failure(error: let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func resolveAndCheckFederationAddressStatus(forDomain domain: String, currency: AccountBalanceResponse, completion: @escaping AddressStatusClosure) {
        resolveFederationAddress(forDomain: domain) { (result) -> (Void) in
            switch result {
            case .success(response: let address):
                self.userManager.checkAddressStatus(forAccountID: address, asset: currency, completion: { (addressResult) -> (Void) in
                    switch addressResult {
                    case .success(isFunded: let isFunded, isTrusted: let isTrusted):
                        DispatchQueue.main.async {
                            completion( .success(isFunded: isFunded, isTrusted: isTrusted))
                        }
                    case .failure:
                        DispatchQueue.main.async {
                            completion( .failure)
                        }
                    }
                })
                
            case .failure(error: let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    completion( .failure)
                }
            }
        }
    }
}
