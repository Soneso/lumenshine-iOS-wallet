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

fileprivate enum RemoveButtonDescriptions: String {
    case Remove = "remove"
    case RemoveAndAbandon = "remove & abandon credits"
    case ValidatingAndRemoving = "validating & removing"
}

class RemoveCurrencyViewController: UIViewController {
    private var titleView: TitleView!
    private let passwordManager = PasswordManager()
    
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var issuerPublicKeyLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceWarningLabel: UILabel!
    @IBOutlet weak var validationErrorLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true)
    }
    
    var currency: AccountBalanceResponse!
    var wallet: FoundedWallet!
    private var walletManager = WalletManager()
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        validationErrorLabel.isHidden = true
        removeButton.setTitle(RemoveButtonDescriptions.ValidatingAndRemoving.rawValue, for: UIControlState.normal)
        removeButton.isEnabled = false
        
        self.validatePassword()
        
        if !self.isInputDataValid {
            self.resetRemoveButton()
            return
        }
        
        if !hasEnoughFunding {
            showFundingAlert()
            self.resetRemoveButton()
            return
        }
        
        passwordManager.getMnemonic(password: !passwordTextField.isHidden ? passwordTextField.text : nil) { (result) -> (Void) in
            switch result {
            case .success(mnemonic: let mnemonic):
                let transactionHelper = TransactionHelper(wallet: self.wallet)
                transactionHelper.removeTrustLine(currency: self.currency, userMnemonic: mnemonic, completion: { (_) -> (Void) in
                    self.navigationController?.dismiss(animated: true)
                })
                
            case .failure(error: let error):
                print("Error: \(error)")
                if error == BiometricStatus.enterPasswordPressed.rawValue {
                    self.passwordTextField.isHidden = false
                } else {
                    self.validationErrorLabel.text = ValidationErrors.InvalidPassword.rawValue
                    self.validationErrorLabel.isHidden = false
                }

                self.resetRemoveButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupLabelDescriptions()
        
        if BiometricHelper.isBiometricAuthEnabled {
            passwordTextField.isHidden = true
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private var isInputDataValid: Bool {
        get {
            return validationErrorLabel.isHidden
        }
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
        titleView = Bundle.main.loadNibNamed("TitleView", owner:self, options:nil)![0] as! TitleView
        titleView.label.text = "\(wallet.name)\nRemove currency"
        titleView.frame.size = titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "arrow-left"), style:.plain, target: self, action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named: "question"), style:.plain, target: self, action: #selector(didTapHelp(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
    }
    
    private func setupLabelDescriptions() {
        currencyNameLabel.text = currency.assetCode ?? ""
        issuerPublicKeyLabel.text = "Issuer public key: \(currency.assetIssuer ?? "")"
        
        if let balance = CoinUnit(currency.balance), let assetCode = currency.assetCode {
            balanceLabel.text = "Balance: \(balance) \(assetCode)"
            if balance > 0.0 {
                removeButton.setTitle(RemoveButtonDescriptions.RemoveAndAbandon.rawValue, for: UIControlState.normal)
            } else if balance == 0.0 {
                balanceWarningLabel.removeFromSuperview()
            }
        }
    }
    
    private func validatePassword() {
        if passwordTextField.isHidden {
            return
        }
        
        if let password = self.passwordTextField.text {
                if !password.isMandatoryValid() {
                self.validationErrorLabel.text = ValidationErrors.MandatoryPassword.rawValue
                self.validationErrorLabel.isHidden = false

                return
            }
        }
    }
}

