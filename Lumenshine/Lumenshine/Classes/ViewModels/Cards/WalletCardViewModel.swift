//
//  WalletCardViewModel.swift
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

class WalletCardViewModel : CardViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var card: Card?
    fileprivate let stellarSdk: StellarSDK
    fileprivate var funded: Bool = false
    
    var wallet: Wallet
    
    var receivePaymentAction: (() -> ())?
    var sendAction: (() -> ())?
    var depositAction: (() -> ())?
    var reloadCardsClosure: (() -> ())?
    var reloadClosure: ((Bool) -> ())?
    
    init(walletResponse: WalletsResponse) {
        self.stellarSdk = StellarSDK()
        
        self.wallet = Wallet(walletResponse: walletResponse)
        
        Services.shared.userManager.walletDetailsFor(wallets: [walletResponse]) { result in
            switch result {
            case .success(let wallets):
                guard let wallet = wallets.first else { return }
                self.wallet = wallet
                self.reloadClosure?(true)
            case .failure(let error):
                print("Account details failure: \(error)")
            }
        }
    }
    deinit {
        print("wallet cardviewmodel deinit")
    }
    init(wallet: Wallet) {
        self.stellarSdk = StellarSDK()
        
        self.wallet = wallet
        funded = wallet.isFunded
    }
    
    func refreshContent(userManager: UserManager) {
        
        if (wallet as? FundedWallet)?.showOnHomescreen == false {
            self.reloadCardsClosure?()
        }
        
        if !Services.shared.walletService.isWalletNeedsRefresh(accountId: wallet.publicKey) {
            return
        }
        
        userManager.walletDetails(wallet: wallet) { [weak self] result in
            switch result {
            case .success(let wallets):
                guard let wallet = wallets.first else { return }
                self?.wallet = wallet
                
                self?.reloadClosure?(false)
                
                Services.shared.walletService.removeFromWalletsToRefresh(accountId: wallet.publicKey)
                NotificationCenter.default.post(name: .updateUIAfterWalletRefresh, object: wallet)
                
            case .failure(let error):
                print("Account details failure: \(error)")
            }
        }
    }
    
    var type: CardType {
        return .wallet(status: wallet.status)
    }
    
    var imageURL: URL? {
        guard let urlString = card?.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var image: UIImage? {
        return nil
    }
    
    var linkURL: URL? {
        guard let urlString = card?.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        return wallet.name
    }
    
    var detail: String? {
        return card?.detail
    }
    
    var nativeBalance: CoinUnit? {
        return wallet.nativeBalance
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
    
    @objc func didTapDepositButton() {
        depositAction?()
    }
    
    @objc func didTapSendButton() {
        sendAction?()
    }
    
    @objc func didTapReceiveButton() {
        receivePaymentAction?()
    }
    
    @objc func didTapDetailsButton() {
        navigationCoordinator?.performTransition(transition: .showCardDetails(wallet))
    }
    
    @objc func didTapFundButton() {
        navigationCoordinator?.performTransition(transition: .showFundWallet(wallet))
    }
}

fileprivate extension WalletCardViewModel {
    func showBalances(_ balances: [AccountBalanceResponse]) {
        
    }
}
