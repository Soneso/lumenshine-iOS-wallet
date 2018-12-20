//
//  NativeCurrencyFeeInfoViewController.swift
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
import Material

class NativeCurrencyFeeInfoViewController: UIViewController {
    var currency: AccountBalanceResponse!
    var wallet: FundedWallet!
    
    private let userManager = UserManager()
    private let xlmAccountReserve = "1.0 XLM"

    @IBOutlet weak var stackViewBackgroundView: UIView!
    @IBOutlet weak var trustLinesView: UIView!
    @IBOutlet weak var signersView: UIView!
    @IBOutlet weak var dataEntriesView: UIView!
    @IBOutlet weak var offersView: UIView!
    @IBOutlet weak var stackViewSeparatorView: UIView!
    @IBOutlet weak var liabilitiesView: UIView!
    
    @IBOutlet weak var totalReservesValueLabel: UILabel!
    @IBOutlet weak var networkReserveValueLabel: UILabel!
    @IBOutlet weak var trustlinesValueLabel: UILabel!
    @IBOutlet weak var signersValueLabel: UILabel!
    @IBOutlet weak var dataEntriesValueLabel: UILabel!
    @IBOutlet weak var offersValueLabel: UILabel!
    @IBOutlet weak var networkReserveLabel: UILabel!
    @IBOutlet weak var trustlinesLabel: UILabel!
    @IBOutlet weak var signersLabel: UILabel!
    @IBOutlet weak var dataEntriesLabel: UILabel!
    @IBOutlet weak var offersLabel: UILabel!
    @IBOutlet weak var minimumBalanceLabel: UILabel!
    @IBOutlet weak var liabilitiesInfoLabel: UILabel!
    @IBOutlet weak var liabilitiesValueLabel: UILabel!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }

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
        view.backgroundColor = Stylesheet.color(.lightGray)
        stackViewSeparatorView.backgroundColor = Stylesheet.color(.lightGray)
        stackViewBackgroundView.backgroundColor = Stylesheet.color(.helpButtonGray)
        dismissButton.backgroundColor = Stylesheet.color(.lightGray)
        dismissButton.setTitleColor(Stylesheet.color(.lightBlack), for: .normal)
        dismissButton.borderWidthPreset = .border1
        dismissButton.borderColor = Stylesheet.color(.lightBlack)
        
        if let liabilities = CoinUnit(currency.sellingLiabilities) {
            if liabilities.isEqual(to: 0) {
                liabilitiesView.isHidden = true
                liabilitiesInfoLabel.text = nil
            } else {
                let liabilitiesValue = "\(liabilities) XLM"
                liabilitiesValueLabel.text = liabilitiesValue
            }
        }
    }
    
    private func setupLabels() {
        setupUINetworkReserved()
        
        userManager.getAccountDetails(forAccountID: wallet.publicKey) { (response) -> (Void) in
            switch response {
            case .success(details: let accountDetails):
                let trustlines = self.checkNumberOfTrustlines()
                self.setupUI(forItem: trustlines, forView: self.trustLinesView, forLabel: self.trustlinesLabel, forValueLabel: self.trustlinesValueLabel)
                
                let signers = self.checkNumberOfSigners(forAccount: accountDetails)
                self.setupUI(forItem: signers, forView: self.signersView, forLabel: self.signersLabel, forValueLabel: self.signersValueLabel)
                
                let dataEntries = self.checkNumberOfDataEntries(forAccount: accountDetails)
                self.setupUI(forItem: dataEntries, forView: self.dataEntriesView, forLabel: self.dataEntriesLabel, forValueLabel: self.dataEntriesValueLabel)
                
                let offers = self.checkNumberOfOffers(nrOfTrustLines: trustlines.count, nrOfSigners: signers.count, nrOfDataEntries: dataEntries.count)
                self.setupUI(forItem: offers, forView: self.offersView, forLabel: self.offersLabel, forValueLabel: self.offersValueLabel)
                
                self.calculateTotal(trustlines: trustlines.value, signers: signers.value, dataEntries: dataEntries.value, offers: offers.value)
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func checkNumberOfTrustlines() -> (count: Int, value: CoinUnit) {
        if wallet.balances.count > 1 {
            let nrOFTrustLines = wallet.balances.count - 1
            let amountValue = CoinUnit(nrOFTrustLines) * CoinUnit.Constants.baseReserver
            return (nrOFTrustLines, amountValue)
        }

        return (0, 0)
    }
    
    private func checkNumberOfSigners(forAccount account: AccountResponse) -> (count: Int, value: CoinUnit) {
        if account.signers.count > 1 {
            let nrOfSigners = account.signers.count - 1
            let amountValue = CoinUnit(nrOfSigners) * CoinUnit.Constants.baseReserver
            return (nrOfSigners, amountValue)
        }

        return (0, 0)
    }
    
    private func checkNumberOfDataEntries(forAccount account: AccountResponse) -> (count: Int, value: CoinUnit) {
        if account.data.count > 0 {
            let amountValue = CoinUnit(account.data.count) * CoinUnit.Constants.baseReserver
            return (account.data.count, amountValue)
        }

        return (0, 0)
    }
    
    private func checkNumberOfOffers(nrOfTrustLines: Int, nrOfSigners: Int, nrOfDataEntries: Int) -> (count: Int, value: CoinUnit) {
        let minimumAccountBalanceWithoutOffers = CoinUnit((2 + (nrOfTrustLines + nrOfSigners + nrOfDataEntries))) * CoinUnit.Constants.baseReserver
        let nrOfOffers = Int((CoinUnit.minimumAccountBalance(forWallet: wallet) - minimumAccountBalanceWithoutOffers) / CoinUnit.Constants.baseReserver)

        if nrOfOffers > 0 {
            let amountValue = CoinUnit(nrOfOffers) * CoinUnit.Constants.baseReserver
            return (nrOfOffers, amountValue)
        }
        
        return (0, 0)
    }
    
    private func calculateTotal(trustlines: CoinUnit, signers: CoinUnit, dataEntries: CoinUnit, offers: CoinUnit) {
        let liabilities = CoinUnit(currency.sellingLiabilities)
        let additionalAmount = trustlines + signers + dataEntries + offers
        minimumBalanceLabel.text = "\(additionalAmount + 1) XLM"
        let totalValue = additionalAmount + (liabilities ?? 0) + 1
        let total = "\(totalValue) XLM"
        totalReservesValueLabel.text = total
    }
    
    private func setupUI(forItem item:(count: Int, value: CoinUnit), forView view: UIView, forLabel titleLabel: UILabel, forValueLabel valueLabel: UILabel) {
        if item.count == 0 {
            view.isHidden = true
            return
        }
        
        titleLabel.text?.append(" (\(item.count))")
        valueLabel.text = "\(item.value) XLM"
    }
    
    private func setupUINetworkReserved() {
        networkReserveValueLabel.text = xlmAccountReserve
    }
    
    @objc func closeAction() {
        dismiss(animated: true)
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Minimum balance"
        navigationItem.titleLabel.textColor = Stylesheet.color(.lightBlack)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
