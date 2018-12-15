//
//  AccountCurrenciesViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrencies()
    }

    @IBAction func didTapAddCurrency(_ sender: Any) {
        let addCurrencyViewController = AddCurrencyViewController(nibName: "AddCurrencyViewController", bundle: Bundle.main)
        addCurrencyViewController.wallet = wallet
        navigationController?.pushViewController(addCurrencyViewController, animated: true)
    }
    
    private func setupCurrencies() {

        var currencyViewHeight: CGFloat = 0
        for balance in self.wallet.balances {
            if let newAssetCode = balance.assetCode, let newIssuer = balance.assetIssuer{
                var alreadyExists = false
                for arrangedSubView in self.currenciesStackView.arrangedSubviews {
                    if let existingCurrencyView = arrangedSubView as? CurrencyView, newAssetCode == existingCurrencyView.assetCode, newIssuer == existingCurrencyView.issuerPK {
                            alreadyExists = true
                            break
                    }
                }
                if alreadyExists {
                    continue
                }
                let currencyView = Bundle.main.loadNibNamed("CurrencyView", owner:self, options:nil)![0] as! CurrencyView
                
                // TODO : add server method to check this.
                balance.authorized = true
                currencyView.currency = balance
                
                currencyView.removeAction = { [weak balance, weak self] (tappedCurrency) in
                    if tappedCurrency == balance {
                        self?.removeCurrency(forCurrency: tappedCurrency)
                    }
                }
                
                if currencyViewHeight == 0 {
                    currencyViewHeight = currencyView.frame.height
                }
                
                self.currenciesStackView.addArrangedSubview(currencyView)
            }
        }
        
        self.calculateAndSetContentSize(nrOfCurrencies: self.wallet.balances.count, viewHeight: currencyViewHeight)
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
        navigationController?.pushViewController(removeCurrencyViewController, animated: true)
    }
}
