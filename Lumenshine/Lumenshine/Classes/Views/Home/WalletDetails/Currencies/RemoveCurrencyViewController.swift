//
//  RemoveCurrencyViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
        setupPasswordView()
        setupLabelDescriptions()
        
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
        let trustorKeyPair = try! KeyPair(publicKey: PublicKey(accountId:self.wallet.publicKey), privateKey:nil)
        updateActivityMessage(message: R.string.localizable.sending())
        transactionHelper.removeTrustLine(currency: self.currency, trustingAccountKeyPair: trustorKeyPair, completion: { (result) -> (Void) in
            self.hideActivity(completion: {
                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                    break
                case .failure(error: let error):
                    print("Error: \(String(describing: error))")
                    self.showTrnsactionFailedAlert()
                    self.resetRemoveButton()
                }
            })
        })
    }
    
    private func removeCurrencyWithPassword(biometricAuth: Bool) {
        
        passwordManager.getMnemonic(password: !biometricAuth ? passwordView.passwordTextField.text : nil) { (result) -> (Void) in
            switch result {
            case .success(mnemonic: let mnemonic):
                PrivateKeyManager.getKeyPair(forAccountID: self.wallet.publicKey, fromMnemonic: mnemonic) { (response) -> (Void) in
                    switch response {
                    case .success(keyPair: let keyPair):
                        if let trustorKeyPair = keyPair {
                            let transactionHelper = TransactionHelper(wallet: self.wallet)
                            self.passwordView.clearSeedAndPasswordFields()
                            self.updateActivityMessage(message: R.string.localizable.sending())
                            transactionHelper.removeTrustLine(currency: self.currency, trustingAccountKeyPair: trustorKeyPair, completion: { (result) -> (Void) in
                                self.hideActivity(completion: {
                                    switch result {
                                    case .success:
                                        Services.shared.walletService.addWalletToRefresh(accountId: self.wallet.publicKey)
                                        NotificationCenter.default.post(name: .refreshWalletsNotification, object: false)
                                        self.navigationController?.popViewController(animated: true)
                                    case .failure(error: let error):
                                        print("Error: \(String(describing: error))")
                                        self.showTrnsactionFailedAlert()
                                        self.resetRemoveButton()
                                    }
                                })
                            })
                            return
                        }
                    case .failure(error: let error):
                        print(error)
                    }
                    DispatchQueue.main.async {
                        self.hideActivity(completion: {
                            self.showSigningAlert()
                            self.resetRemoveButton()
                        })
                    }
                }
            case .failure(error: let error):
                print("Error: \(error)")
                self.passwordView.showInvalidPasswordError()
                self.resetRemoveButton()
                self.hideActivity()
            }
        }
    }
    
    private func removeCurrency(biometricAuth: Bool = false) {
        passwordView.resetValidationErrors()
        removeButton.setTitle(RemoveButtonDescriptions.ValidatingAndRemoving.rawValue, for: UIControl.State.normal)
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
        
        showActivity(message: R.string.localizable.validateing())
        
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
    
    private func showSigningAlert() {
        self.displaySimpleAlertView(title: "Removing failed", message: "A signing error occured.")
    }
    
    private func showTrnsactionFailedAlert() {
        self.displaySimpleAlertView(title: "Removing failed", message: "A transaction error occured.")
    }
    
    private func resetRemoveButton() {
        if let balance = CoinUnit(currency.balance), balance > 0.0 {
            removeButton.setTitle(RemoveButtonDescriptions.RemoveAndAbandon.rawValue, for: UIControl.State.normal)
        } else {
            removeButton.setTitle(RemoveButtonDescriptions.Remove.rawValue, for: UIControl.State.normal)
        }
        
        removeButton.isEnabled = true
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Remove currency"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    
    }
    
    private func setupLabelDescriptions() {
        currencyNameLabel.text = currency.assetCode ?? ""
        issuerPublicKeyLabel.text = "\(currency.assetIssuer ?? "")"
        
        if let balance = CoinUnit(currency.balance), let assetCode = currency.assetCode {
            balanceLabel.text = "Balance: \(balance) \(assetCode)"
            if balance > 0.0 {
                //removeButton.setTitle(RemoveButtonDescriptions.RemoveAndAbandon.rawValue, for: UIControlState.normal)
                removeButton.isHidden = true
                passwordView.isHidden = true
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
        passwordView.passwordHintView.isHidden = false
        passwordView.passwordHintLabel.text = "Password required to remove currency"
        
        passwordView.biometricAuthAction = {
            self.removeCurrency(biometricAuth: true)
        }
        
        passwordViewContainer.addSubview(passwordView)
        
        passwordView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
