//
//  PaymentOperationsVCManager.swift
//  Lumenshine
//
//  Created by Soneso on 26/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class PaymentOperationsVCManager {
    private weak var parentViewController: UIViewController?
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    func addViewController(forAction: WalletAction, wallet: Wallet, transactionResult: TransactionResult? = nil) {
        var viewController: UIViewController
        switch (forAction) {
        case .receive:
            viewController = ReceivePaymentCardViewController()
            break
            
        case .send:
            viewController = SendViewController()
            setupSendViewController(viewController: viewController as! SendViewController)
            
        case .transactionResult:
            viewController = TransactionResultViewController()
            setupTransactionResult(viewController: viewController as! TransactionResultViewController, transactionResult: transactionResult)
        }
        
        (viewController as! WalletActionsProtocol).wallet = wallet
        (viewController as! WalletActionsProtocol).closeAction = { [weak self] in
            self?.parentViewController?.navigationController?.popViewController(animated: true)
        }
        
        parentViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func setupSendViewController(viewController: SendViewController) {
        viewController.sendAction = { [weak self, weak viewController] (transactionData) in
            if let viewController = viewController, let wallet = viewController.wallet as? FundedWallet {
                let transactionHelper = TransactionHelper(transactionInputData: transactionData, wallet: wallet)

                switch transactionData.transactionType {
                case .sendPayment:
                    transactionHelper.sendPayment(completion: { [weak self] (result) in
                        self?.addViewController(forAction: WalletAction.transactionResult, wallet: viewController.wallet, transactionResult: result)
                    })

                case .createAndFundAccount:
                    transactionHelper.createAndFundAccount(completion: { [weak self] (result) in
                        self?.addViewController(forAction: WalletAction.transactionResult, wallet: viewController.wallet, transactionResult: result)
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
            self?.closeAll()
            self?.addViewController(forAction: WalletAction.send, wallet: viewController.wallet)
        }
    }
}
