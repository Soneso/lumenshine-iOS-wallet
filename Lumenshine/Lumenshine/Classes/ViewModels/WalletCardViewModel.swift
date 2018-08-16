//
//  WalletCardViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/20/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

class WalletCardViewModel : CardViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var card: Card?
    fileprivate let stellarSdk: StellarSDK
    fileprivate var funded: Bool = false
    
    var wallet: Wallet?
    
    var receivePaymentAction: (() -> ())?
    var sendAction: (() -> ())?
    
    init(user: User, card: Card? = nil) {
        self.card = card
        self.stellarSdk = StellarSDK()
        
        stellarSdk.accounts.getAccountDetails(accountId: user.publicKeyIndex0) { response in
            switch response {
            case .success(let accountDetails):
                self.funded = accountDetails.balances.count > 0
                self.showBalances(accountDetails.balances)
            case .failure(let error):
                print("Account details failure: \(error)")
            }
        }
    }
    
    init(wallet: Wallet) {
        self.stellarSdk = StellarSDK()
        
        self.wallet = wallet
        funded = wallet.isFounded
    }
    
    var type: CardType {
        if funded {
            return .wallet(status: .founded)
        } else {
            return .wallet(status: .unfounded)
        }
    }
    
    var imageURL: URL? {
        guard let urlString = card?.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var linkURL: URL? {
        guard let urlString = card?.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        return wallet?.name
    }
    
    var detail: String? {
        return card?.detail
    }
    
    var nativeBalance: CoinUnit? {
        return wallet?.nativeBalance
    }
    
    var bottomTitles: [String]? {
        if !funded {
            return [R.string.localizable.fund_wallet()]
        } else {
            return [R.string.localizable.send(),
                    R.string.localizable.receive(),
                    R.string.localizable.details()]
        }
    }
    
    func barButtonSelected(at index: Int) {
        switch type {
        case .web:
            guard let url = linkURL else { return }
            navigationCoordinator?.performTransition(transition: .showOnWeb(url))
        default:
            break
        }
    }
    
    @objc func didTapSendButton() {
        sendAction?()
    }
    
    @objc func didTapReceiveButton() {
        receivePaymentAction?()
    }
    
    @objc func didTapDetailsButton() {
        navigationCoordinator?.performTransition(transition: .showCardDetails(wallet!))
    }
    
    @objc func didTapHelpButton() {
        navigationCoordinator?.performTransition(transition: .showWalletCardInfo)
    }
    
    @objc func didTapFundButton() {
        navigationCoordinator?.performTransition(transition: .showScan(wallet))
    }
    
}

fileprivate extension WalletCardViewModel {
    func showBalances(_ balances: [AccountBalanceResponse]) {
        
    }
}
