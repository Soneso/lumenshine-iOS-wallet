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
    private var titleView: TitleView!
    private let passwordManager = PasswordManager()
    
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var issuerPublicKeyLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceWarningLabel: UILabel!
    @IBOutlet weak var validationErrorLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var removeButton: UIButton!
        
    var currency: AccountBalanceResponse!
    var wallet: FundedWallet!
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
                    self.navigationController?.popViewController(animated: true)
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

