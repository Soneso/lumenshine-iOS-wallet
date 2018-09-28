//
//  AccountCurrenciesViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 09/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

class IntrinsicView: UIView {
    var desiredHeight: CGFloat = 0
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: desiredHeight)
    }
}

class AccountCurrenciesViewController: UIViewController {
    @IBOutlet weak var currenciesStackView: UIStackView!
    @IBOutlet weak var loadingCurrenciesStackView: UIStackView!
    @IBOutlet weak var intrinsicView: IntrinsicView!
    
    var wallet: FundedWallet!
    let walletManager = WalletManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCurrencies()
    }

    @IBAction func didTapAddCurrency(_ sender: Any) {
        let addCurrencyViewController = AddCurrencyViewController(nibName: "AddCurrencyViewController", bundle: Bundle.main)
        addCurrencyViewController.wallet = wallet
        let navigationController = BaseNavigationViewController(rootViewController: addCurrencyViewController)
        present(navigationController, animated: true)
    }
    
    private func setupCurrencies() {
        activityIndicator(showLoading: true)
        self.walletManager.balancesWithAuthorizationForWallet(wallet: self.wallet) { (response) -> (Void) in
            switch response {
            case .success(let balances):
                var currencyViewHeight: CGFloat = 0
                for balance in balances {
                        if let _ = balance.assetCode, let _ = balance.assetIssuer {
                            let currencyView = Bundle.main.loadNibNamed("CurrencyView", owner:self, options:nil)![0] as! CurrencyView
                            currencyView.currency = balance
                            
                            currencyView.removeAction = { [weak balance] (tappedCurrency) in
                                if tappedCurrency == balance {
                                    self.removeCurrency(forCurrency: tappedCurrency)
                                }
                            }
                            
                            if currencyViewHeight == 0 {
                                currencyViewHeight = currencyView.frame.height
                            }
                            
                            self.currenciesStackView.addArrangedSubview(currencyView)
                        }
                    }
                
                self.calculateAndSetContentSize(nrOfCurrencies: balances.count, viewHeight: currencyViewHeight)
                self.activityIndicator(showLoading: false)
                
            case .failure(let error):
                self.displayErrorAlertView(message: error.localizedDescription)
                self.activityIndicator(showLoading: false)
            }
        }
    }
    
    private func activityIndicator(showLoading: Bool) {
        self.loadingCurrenciesStackView.isHidden = !showLoading
    }
    
    private func calculateAndSetContentSize(nrOfCurrencies: Int, viewHeight: CGFloat) {
        intrinsicView.desiredHeight = CGFloat(nrOfCurrencies) * viewHeight + CGFloat(10 * nrOfCurrencies)
        intrinsicView.invalidateIntrinsicContentSize()
    }
    
    private func removeCurrency(forCurrency currency: AccountBalanceResponse) {
        let removeCurrencyViewController = RemoveCurrencyViewController(nibName: "RemoveCurrencyViewController", bundle: Bundle.main)
        removeCurrencyViewController.currency = currency
        removeCurrencyViewController.wallet = wallet
        let navigationController = BaseNavigationViewController(rootViewController: removeCurrencyViewController)
        present(navigationController, animated: true)
    }
}
