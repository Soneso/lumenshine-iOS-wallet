//
//  NativeCurrencyFeeInfoViewController.swift
//  Lumenshine
//
//  Created by Soneso on 11/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk
import Material

class NativeCurrencyFeeInfoViewController: UIViewController {
    var currency: AccountBalanceResponse!
    var wallet: FundedWallet!
    
    private let userManager = UserManager()
    private let xlmAccountReserve = "1.0 XLM - account reserve"
    private let newLine = "\n"
    
    @IBOutlet weak var liabilitiesView: UIView!
    
    @IBOutlet weak var minimumBalanceLabel: UILabel!
    @IBOutlet weak var liabilitiesLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
        setupLabels()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        
        if let liabilities = CoinUnit(currency.sellingLiabilities) {
            if liabilities.isEqual(to: 0) {
                liabilitiesView.isHidden = true
            } else {
                let liabilitiesValue = "\(liabilities) XLM"
                addValueLine(toLabel: liabilitiesLabel, value: liabilitiesValue)
            }
        }
    }
    
    private func setupLabels() {
        addValueLine(toLabel: minimumBalanceLabel, value: xlmAccountReserve)
        
        userManager.getAccountDetails(forAccountID: wallet.publicKey) { (response) -> (Void) in
            switch response {
            case .success(details: let accountDetails):
                let trustlines = self.checkNumberOfTrustlines()
                let signers = self.checkNumberOfSigners(forAccount: accountDetails)
                let dataEntries = self.checkNumberOfDataEntries(forAccount: accountDetails)
                let offers = self.checkNumberOfOffers(nrOfTrustLines: trustlines.count, nrOfSigners: signers.count, nrOfDataEntries: dataEntries.count)
                self.calculateTotal(trustlines: trustlines.value, signers: signers.value, dataEntries: dataEntries.value, offers: offers.value)
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func addValueLine(toLabel label: UILabel, value: String) {
        if label.text?.isEmpty == false {
            label.text?.append(newLine)
        }
        
        label.text?.append(value)
    }
    
    private func checkNumberOfTrustlines() -> (count: Int, value: CoinUnit) {
        if wallet.balances.count > 1 {
            let nrOFTrustLines = wallet.balances.count - 1
            let amountValue = CoinUnit(nrOFTrustLines) * CoinUnit.Constants.baseReserver
            let value = "\(amountValue) XLM - \(nrOFTrustLines) \(nrOFTrustLines == 1 ? "trustline" : "trustlines") to other \(nrOFTrustLines == 1 ? "currency" : "currencies")"
            addValueLine(toLabel: minimumBalanceLabel, value: value)
            return (nrOFTrustLines, amountValue)
        }
        
        return (0, 0)
    }
    
    private func checkNumberOfSigners(forAccount account: AccountResponse) -> (count: Int, value: CoinUnit) {
        if account.signers.count > 1 {
            let nrOfSigners = account.signers.count - 1
            let amountValue = CoinUnit(nrOfSigners) * CoinUnit.Constants.baseReserver
            let value = "\(amountValue) XLM - \(nrOfSigners) additional \(nrOfSigners == 1 ? "signer" : "signers")"
            addValueLine(toLabel: minimumBalanceLabel, value: value)
            return (nrOfSigners, amountValue)
        }
        
        return (0, 0)
    }
    
    private func checkNumberOfDataEntries(forAccount account: AccountResponse) -> (count: Int, value: CoinUnit) {
        if account.data.count > 0 {
            let amountValue = CoinUnit(account.data.count) * CoinUnit.Constants.baseReserver
            let value = "\(amountValue) XLM - \(account.data.count) data \(account.data.count == 1 ? "entry" : "entries")"
            addValueLine(toLabel: minimumBalanceLabel, value: value)
            return (account.data.count, amountValue)
        }
        
        return (0, 0)
    }
    
    private func checkNumberOfOffers(nrOfTrustLines: Int, nrOfSigners: Int, nrOfDataEntries: Int) -> (count: Int, value: CoinUnit) {
        let minimumAccountBalanceWithoutOffers = CoinUnit((2 + (nrOfTrustLines + nrOfSigners + nrOfDataEntries))) * CoinUnit.Constants.baseReserver
        let nrOfOffers = Int((CoinUnit.minimumAccountBalance(forWallet: wallet) - minimumAccountBalanceWithoutOffers) / CoinUnit.Constants.baseReserver)
        
        if nrOfOffers > 0 {
            let amountValue = CoinUnit(nrOfOffers) * CoinUnit.Constants.baseReserver
            let value = "\(amountValue) XLM - \(nrOfOffers) \(nrOfOffers == 1 ? "offer" : "offers")"
            addValueLine(toLabel: minimumBalanceLabel, value: value)
            return (nrOfOffers, amountValue)
        }
        
        return (0, 0)
    }
    
    private func calculateTotal(trustlines: CoinUnit, signers: CoinUnit, dataEntries: CoinUnit, offers: CoinUnit) {
        let liabilities = CoinUnit(currency.sellingLiabilities)
        let additionalAmount = trustlines + signers + dataEntries + offers
        let totalValue = additionalAmount + (liabilities ?? 0) + 1
        let total = "\(totalValue) XLM"
        addValueLine(toLabel: totalAmountLabel, value: total)
    }
    
    @objc func closeAction() {
        dismiss(animated: true)
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Available XLM"
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
