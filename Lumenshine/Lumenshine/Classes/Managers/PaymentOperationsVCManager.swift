//
//  PaymentOperationsVCManager.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class PaymentOperationsVCManager {
    private weak var parentViewController: UIViewController?
    private weak var sendViewController: SendViewController?
    private let walletManager = WalletManager()
    private let userManager = UserManager()
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    func addViewController(forAction: WalletAction, wallets: [Wallet], transactionResult: TransactionResult? = nil, paymentDestination: String? = nil) {
        var viewController: UIViewController
        switch (forAction) {
        case .receive:
            viewController = ReceivePaymentCardViewController()
            
        case .send:
            viewController = SendViewController()
            sendViewController = (viewController as! SendViewController)
            (viewController as! SendViewController).contactDestination = paymentDestination
            setupSendViewController(viewController: viewController as! SendViewController)
            
        case .transactionResult:
            viewController = TransactionResultViewController()
            setupTransactionResult(viewController: viewController as! TransactionResultViewController, transactionResult: transactionResult)
        
        case .deposit:
            viewController = DepositInfoViewController()
            (viewController as! DepositInfoViewController).walletsList = wallets
            (viewController as! DepositInfoViewController).baseViewController = self.parentViewController!.navigationController
            let composeVC = ComposeNavigationController(rootViewController: viewController)
            self.parentViewController?.present(composeVC, animated: true)
            
            return
        }
        
        (viewController as! WalletActionsProtocol).walletsList = wallets
        (viewController as! WalletActionsProtocol).closeAction = { [weak self] in
            self?.parentViewController?.navigationController?.popViewController(animated: true)
        }
        
        parentViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupSendViewControllerWithMultipleWallets(stellarAddress: String? = nil, publicKey: String? = nil) {
        walletManager.walletsForSendingPayment(stellarAddress: stellarAddress, publicKey: publicKey) { (response) -> (Void) in
            switch response {
            case .success(fundedWallets: let wallets, paymentDestination: let paymentDestination):
                self.addViewController(forAction: .send, wallets: wallets, paymentDestination: paymentDestination)
            case .noFunding:
                let alert = UIAlertController(title: "No funding", message: "Please fund your wallet first to be able to send a payment.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.parentViewController?.present(alert, animated: true, completion: nil)
            case .failure(error: let error):
                print(error)
            }
        }
    }
    
    func setupViewControllerWithMultipleWallets(forAction action: WalletAction) {
        userManager.walletsForCurrentUser { (response) -> (Void) in
            switch response {
            case .success(response: let wallets):
                self.addViewController(forAction: action, wallets: wallets)
            case .failure(error: let error):
                print(error)
            }
        }
    }
    
    private func setupSendViewController(viewController: SendViewController) {
        viewController.sendAction = { [weak self, weak viewController] (transactionData) in
            if let viewController = viewController, let wallet = viewController.wallet as? FundedWallet {
                let transactionHelper = TransactionHelper(transactionInputData: transactionData, wallet: wallet)

                switch transactionData.transactionType {
                case .sendPayment:
                    transactionHelper.sendPayment(completion: { [weak self] (result) in
                        self?.addViewController(forAction: WalletAction.transactionResult, wallets: [viewController.wallet], transactionResult: result)
                        if result.status == TransactionStatus.success {
                            Services.shared.walletService.addWalletToRefresh(accountId: wallet.publicKey)
                            if PrivateKeyManager.hasPublicKey(accountId: result.recipentPK) {
                                Services.shared.walletService.addWalletToRefresh(accountId: result.recipentPK)
                            }
                            NotificationCenter.default.post(name: .refreshWalletsNotification, object: true)
                        }
                    })

                case .createAndFundAccount:
                    transactionHelper.createAndFundAccount(completion: { [weak self] (result) in
                        self?.addViewController(forAction: WalletAction.transactionResult, wallets: [viewController.wallet], transactionResult: result)
                        if result.status == TransactionStatus.success {
                            Services.shared.walletService.addWalletToRefresh(accountId: wallet.publicKey)
                            if PrivateKeyManager.hasPublicKey(accountId: result.recipentPK) {
                                Services.shared.walletService.addWalletToRefresh(accountId: result.recipentPK)
                            }
                            NotificationCenter.default.post(name: .refreshWalletsNotification, object: true)
                        }
                    })
                }
            }
        }
    }
    
    private func closeAll() {
        self.parentViewController?.navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupTransactionResult(viewController: TransactionResultViewController, transactionResult: TransactionResult?) {
        if let transactionResult = transactionResult {
            viewController.result = transactionResult
        }
        
        viewController.closeAllAction = { [weak self] in
            self?.closeAll()
        }
        
        viewController.sendOtherAction = { [weak self] in
            self?.parentViewController?.navigationController?.popViewController(animated: true)
            self?.sendViewController?.clearValuesForNewPayment()
        }
    }
}
