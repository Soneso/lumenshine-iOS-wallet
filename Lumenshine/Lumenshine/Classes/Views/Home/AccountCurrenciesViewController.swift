//
//  AccountCurrenciesViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 09/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class AccountCurrenciesViewController: UIViewController {

    @IBOutlet weak var currenciesStackView: UIStackView!
    
    var wallet: FoundedWallet!
    let walletManager = WalletManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCurrencies()
    }

    @IBAction func didTapAddCurrency(_ sender: Any) {
        
    }
    
    private func setupCurrencies() {
        walletManager.balancesWithAuthorizationForWallet(wallet: wallet) { (response) -> (Void) in
            switch response {
            case .success(let balances):
                for balance in balances {
                    let currencyView = Bundle.main.loadNibNamed("CurrencyView", owner:self, options:nil)![0] as! CurrencyView
                    currencyView.currencyLabel.text = balance.assetCode ?? ""
                    currencyView.issuerLabel.text = "Issuer public key: \(balance.assetIssuer)"
                }
            case .failure(let error):
                self.displayErrorAlertView(message: error.localizedDescription)
            }
        }
    }
    
}
