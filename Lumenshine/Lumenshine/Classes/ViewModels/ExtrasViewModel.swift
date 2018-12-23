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
    var wallets: [String] { get }
    func itemSelected(at indexPath: IndexPath)
    func mergeExternalAccount(accountSeed:String, walletPK:String, response: @escaping EmptyResponseClosure)
    func mergeWallet(password:String, walletPK:String, externalAccountID:String, response: @escaping EmptyResponseClosure)
    func showMergeSuccess()
}


class ExtrasViewModel: ExtrasViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate let user: User
    fileprivate let entries: [[ExtrasEntry]]
    fileprivate var sortedWallets: [WalletsResponse] = []
    
    init(user: User) {
        self.user = user
        self.entries = [[.mergeExternalAccount, .mergeWallet]]
        getWallets()
    }
    
    func name(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).name
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    var wallets: [String] {
        return sortedWallets.map {
            $0.walletName
        }
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
    
    
    func mergeExternalAccount(accountSeed:String, walletPK:String, response: @escaping EmptyResponseClosure) {
        
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
    
    func getWallets() {
        Services.shared.walletService.getWallets { [weak self] (result) -> (Void) in
            switch result {
            case .success(let wallets):
                self?.sortedWallets = wallets.sorted(by: { $0.id < $1.id }) 
            case .failure(_):
                // TODO show error to user
                print("Failed to get wallets")
            }
        }
    }
}
