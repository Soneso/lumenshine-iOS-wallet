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
    var walletsForExternalMerge: [WalletsResponse] { get }
    var walletsForClose: [WalletsResponse] { get }
    func itemSelected(at indexPath: IndexPath)
    func mergeAccount(sourceKeyPair:KeyPair, destinationKeyPair:KeyPair, response: @escaping EmptyResponseClosure)
    func reloadWallets()
    func switchValue(at indexPath: IndexPath) -> Bool?
    func switchChanged(value: Bool, at indexPath: IndexPath)
}


class ExtrasViewModel: ExtrasViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate let user: User
    fileprivate let entries: [[ExtrasEntry]]
    var walletsForExternalMerge: [WalletsResponse] = []
    var walletsForClose: [WalletsResponse] = []
    
    init(user: User) {
        self.user = user
        self.entries = [[.mergeExternalAccount, .mergeWallet, .hideMemos]]
        //loadWallets()
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
            navigationCoordinator?.baseController.showActivity(message: R.string.localizable.loading())
            self.reloadWallets()
            navigationCoordinator?.baseController.hideActivity(completion: {
                self.navigationCoordinator?.performTransition(transition: .showMergeExternalAccount)
            })
        case .mergeWallet:
            navigationCoordinator?.baseController.showActivity(message: R.string.localizable.loading())
            self.reloadWallets()
            navigationCoordinator?.baseController.hideActivity(completion: {
                self.navigationCoordinator?.performTransition(transition: .showMergeWallet)
            })
        case .hideMemos:
            break
        }
    }
    
    func reloadWallets() {
        walletsForExternalMerge.removeAll()
        walletsForClose.removeAll()
        loadWallets()
    }
    
    func showExtras() {
        navigationCoordinator?.performTransition(transition: .showExtras)
    }
    
    func switchValue(at indexPath: IndexPath) -> Bool? {
        switch entry(at: indexPath) {
        case .hideMemos:
            if let hide = UserDefaults.standard.value(forKey: Keys.UserDefs.ShowMemos) as? Bool {
                return hide
            }
            return false
        default:
            return nil
        }
    }
    
    func switchChanged(value: Bool, at indexPath: IndexPath) {
        switch entry(at: indexPath) {
        case .hideMemos:
            if value == true {
                UserDefaults.standard.setValue(true, forKey:Keys.UserDefs.ShowMemos)
            } else {
                UserDefaults.standard.setValue(false, forKey:Keys.UserDefs.ShowMemos)
            }
        default: break
        }
    }
    
    func mergeAccount(sourceKeyPair:KeyPair, destinationKeyPair:KeyPair, response: @escaping EmptyResponseClosure) {
        
        if let sourceSeed = sourceKeyPair.seed {
            // check if source account exists
            Services.shared.walletService.getAccountDetails(accountId: sourceKeyPair.accountId) { (sourceDetailsResponse) -> (Void) in
                switch sourceDetailsResponse {
                case .success(let sourceAccountData):
                    // source account must not have any subentries
                    if sourceAccountData.subentryCount > 0 {
                        let error = ErrorResponse()
                        error.parameterName = "source_account"
                        if sourceAccountData.balances.count > 1 {
                            error.errorMessage = R.string.localizable.account_has_trustlines_no_merge()
                        } else if sourceAccountData.data.count > 0 {
                            error.errorMessage = R.string.localizable.account_has_data_entries_no_merge()
                        } else {
                            error.errorMessage = R.string.localizable.account_has_subentries_no_merge()
                        }
                        
                        response(.failure(error: .validationFailed(error: error)))
                        return
                    }
                    // check if destination account exists
                    Services.shared.walletService.getAccountDetails(accountId: destinationKeyPair.accountId) { (destinationDetailsResponse) -> (Void) in
                        switch destinationDetailsResponse {
                        case .success(_):
                            let transactionHelper = TransactionHelper(signer: sourceKeyPair.accountId, signerSeed: sourceSeed.secret)
                            transactionHelper.mergeAccount(sourceAccountResponse: sourceAccountData, sourceAccountKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair, completion: { (result) -> (Void) in
                                switch result {
                                case .success:
                                    response(.success)
                                case .failure (_):
                                    response(.failure(error: .genericError(message: "Transaction failed.")))
                                }
                            })
                        case .failure(_):
                            let error = ErrorResponse()
                            error.parameterName = "destination_account"
                            error.errorMessage = R.string.localizable.account_not_found()
                            response(.failure(error: .validationFailed(error: error)))
                        }
                    }
                case .failure(_):
                    let error = ErrorResponse()
                    error.parameterName = "source_account"
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
                        case .success(let accountDetails):
                            self?.walletsForExternalMerge.append(wallet)
                            if accountDetails.subentryCount == 0 {
                                self?.walletsForClose.append(wallet)
                            }
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
