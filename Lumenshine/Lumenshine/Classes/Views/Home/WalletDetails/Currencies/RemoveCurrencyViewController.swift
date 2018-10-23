//
//  RemoveCurrencyViewController.swift
//  Lumenshine
//
//  Created by Soneso on 23/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk
import Material

fileprivate enum RemoveButtonDescriptions: String {
    case Remove = "SUBMIT"
    case RemoveAndAbandon = "SUBMIT ANYWAY"
    case ValidatingAndRemoving = "validating & removing"
}

class RemoveCurrencyViewController: UIViewController {
    private let passwordManager = PasswordManager()
    
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var issuerPublicKeyLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceWarningLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    var currency: AccountBalanceResponse!
    var wallet: FundedWallet!
    private var walletManager = WalletManager()
    private var passwordView: PasswordView!
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        removeCurrency()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupLabelDescriptions()
        setupPasswordView()
        
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        removeButton.backgroundColor = Stylesheet.color(.blue)
    }
        
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private func removeCurrencyWithExternalSigning() {
        let signer = passwordView.signersTextField.text
        let seed = passwordView.seedTextField.text
        let transactionHelper = TransactionHelper(wallet: self.wallet, signer: signer, signerSeed: seed)
        passwordView.clearSeedAndPasswordFields()
        transactionHelper.removeTrustLine(currency: self.currency, completion: { (_) -> (Void) in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    private func removeCurrencyWithPassword(biometricAuth: Bool) {
        passwordManager.getMnemonic(password: !biometricAuth ? passwordView.passwordTextField.text : nil) { (result) -> (Void) in
            switch result {
            case .success(mnemonic: let mnemonic):
                let transactionHelper = TransactionHelper(wallet: self.wallet)
                transactionHelper.removeTrustLine(currency: self.currency, mnemonic: mnemonic, completion: { (_) -> (Void) in
                    self.navigationController?.popViewController(animated: true)
                })

            case .failure(error: let error):
                print("Error: \(error)")
                self.passwordView.showInvalidPasswordError()
                self.resetRemoveButton()
            }
        }
    }
    
    private func removeCurrency(biometricAuth: Bool = false) {
        passwordView.resetValidationErrors()
        removeButton.setTitle(RemoveButtonDescriptions.ValidatingAndRemoving.rawValue, for: UIControlState.normal)
        removeButton.isEnabled = false
        
        if !isInputDataValid(forBiometricAuth: biometricAuth) {
            self.resetRemoveButton()
            return
        }
        
        if !hasEnoughFunding {
            showFundingAlert()
            self.resetRemoveButton()
            return
        }
        
        if passwordView.useExternalSigning {
         removeCurrencyWithExternalSigning()
        } else {
            removeCurrencyWithPassword(biometricAuth: biometricAuth)
        }
    }
    
    private func isInputDataValid(forBiometricAuth biometricAuth: Bool) -> Bool {
        return passwordView.validatePassword(biometricAuth: biometricAuth)
    }
    
    private func showFundingAlert() {
        self.displaySimpleAlertView(title: "Removing failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func resetRemoveButton() {
        if let balance = CoinUnit(currency.balance), balance > 0.0 {
            removeButton.setTitle(RemoveButtonDescriptions.RemoveAndAbandon.rawValue, for: UIControlState.normal)
        } else {
            removeButton.setTitle(RemoveButtonDescriptions.Remove.rawValue, for: UIControlState.normal)
        }
        
        removeButton.isEnabled = true
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Remove currency"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]
    }
    
    private func setupLabelDescriptions() {
        currencyNameLabel.text = currency.assetCode ?? ""
        issuerPublicKeyLabel.text = "\(currency.assetIssuer ?? "")"
        
        if let balance = CoinUnit(currency.balance), let assetCode = currency.assetCode {
            balanceLabel.text = "Balance: \(balance) \(assetCode)"
            if balance > 0.0 {
                removeButton.setTitle(RemoveButtonDescriptions.RemoveAndAbandon.rawValue, for: UIControlState.normal)
            } else if balance == 0.0 {
                balanceWarningLabel.removeFromSuperview()
            }
        }
    }
    
    private func setupPasswordView() {
        passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
        passwordView.neededSigningSecurity = .medium
        passwordView.hideTitleLabels = true
        passwordView.wallet = wallet
        
        passwordView.biometricAuthAction = {
            self.removeCurrency(biometricAuth: true)
        }
        
        passwordViewContainer.addSubview(passwordView)
        
        passwordView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

