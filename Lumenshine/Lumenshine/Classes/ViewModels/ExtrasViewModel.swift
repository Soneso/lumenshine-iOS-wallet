//
//  ExtrasViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 23/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UIApplication
import stellarsdk

protocol ExtrasViewModelType: Transitionable, BiometricAuthenticationProtocol {
   
    func name(at indexPath: IndexPath) -> String
    var itemDistribution: [Int] { get }
    var sortedWallets: [WalletsResponse] { get }
    func itemSelected(at indexPath: IndexPath)
    func mergeAccount(sourceKeyPair:KeyPair, destinationKeyPair:KeyPair, response: @escaping EmptyResponseClosure)
    func mergeWallet(password:String, walletPK:String, externalAccountID:String, response: @escaping EmptyResponseClosure)
    func showMergeSuccess()
}


class ExtrasViewModel: ExtrasViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate let user: User
    fileprivate let entries: [[ExtrasEntry]]
    var sortedWallets: [WalletsResponse] = []
    
    init(user: User) {
        self.user = user
        self.entries = [[.mergeExternalAccount, .mergeWallet]]
        loadWallets()
    }
    
    func name(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).name
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        switch entry(at: indexPath) {
        case .mergeExternalAccount:
            navigationCoordinator?.performTransition(transition: .showMergeExternalAccount)
        case .mergeWallet:
            navigationCoordinator?.performTransition(transition: .showMergeWallet)
        }
    }
    
    func showMergeSuccess() {
        navigationCoordinator?.performTransition(transition: .showSuccess)
    }
    func showExtras() {
        navigationCoordinator?.performTransition(transition: .showExtras)
    }
    
    
    func mergeAccount(sourceKeyPair:KeyPair, destinationKeyPair:KeyPair, response: @escaping EmptyResponseClosure) {
        
        if let sourceSeed = sourceKeyPair.seed {
            
            Services.shared.walletService.getAccountDetails(accountId: sourceKeyPair.accountId) { (sourceDetailsResponse) -> (Void) in
                switch sourceDetailsResponse {
                case .success(let sourceAccountData):
                    Services.shared.walletService.getAccountDetails(accountId: destinationKeyPair.accountId) { (destinationDetailsResponse) -> (Void) in
                        switch destinationDetailsResponse {
                        case .success(_):
                            let transactionHelper = TransactionHelper(signer: sourceKeyPair.accountId, signerSeed: sourceSeed.secret)
                            transactionHelper.mergeAccount(sourceAccountResponse: sourceAccountData, sourceAccountKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair, completion: { (result) -> (Void) in
                                switch result {
                                case .success:
                                    response(.success)
                                case .failure (_):
                                    response(.failure(error: .genericError(message: "An error occured while connecting to stellar")))
                                }
                            })
                        case .failure(_):
                            let error = ErrorResponse()
                            error.parameterName = "wallet"
                            error.errorMessage = R.string.localizable.account_not_found()
                            response(.failure(error: .validationFailed(error: error)))
                        }
                    }
                case .failure(_):
                    let error = ErrorResponse()
                    error.parameterName = "seed"
                    error.errorMessage = R.string.localizable.account_not_found()
                    response(.failure(error: .validationFailed(error: error)))
                }
            }
           
        }  else {
            let error = ErrorResponse()
            error.parameterName = "seed"
            error.errorMessage = R.string.localizable.invalid_secret_seed()
            response(.failure(error: .validationFailed(error: error)))
        }
    }
    
    func mergeWallet(password:String, walletPK:String, externalAccountID:String, response: @escaping EmptyResponseClosure) {
        
    }
    
    // MARK: Biometric authentication
    func authenticateUser(completion: @escaping BiometricAuthResponseClosure) {
        BiometricHelper.authenticate(username: user.email, response: completion)
    }
    
}

fileprivate extension ExtrasViewModel {
    func entry(at indexPath: IndexPath) -> ExtrasEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func loadWallets() {
        Services.shared.walletService.getWallets(reload:false) { [weak self] (result) -> (Void) in
            switch result {
            case .success(let wallets):
                let allSortedWallets = wallets.sorted(by: { $0.id < $1.id })
                // add only funded wallets
                for wallet in allSortedWallets {
                    Services.shared.walletService.getAccountDetails(accountId: wallet.publicKey, ignoreCachingDuration: true) { (result) -> (Void) in
                        switch result {
                        case .success(_):
                            self?.sortedWallets.append(wallet)
                        default:
                            break
                        }
                    }
                }
            case .failure(_):
                // TODO show error to user
                print("Failed to get wallets")
            }
        }
    }
}
