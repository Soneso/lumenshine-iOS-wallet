//
//  KnownCurrenciesTableViewCell.swift
//  Lumenshine
//
//  Created by Soneso on 27/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

fileprivate enum AddButtonTitles: String {
    case add = "add"
    case validatingAndAdding = "validating & adding"
}

class KnownCurrenciesTableViewCell: UITableViewCell {
    @IBOutlet weak var assetCodeLabel: UILabel!
    @IBOutlet weak var authorizationLabel: UILabel!
    @IBOutlet weak var issuerPublicKeyLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var expansionView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    private let walletManager = WalletManager()
    private let passwordManager = PasswordManager()
    
    private var authService: AuthService {
        get {
            return Services.shared.auth
        }
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        resetValidationError()
        setButtonAsValidating()
    
        if isPasswordValid, let assetCode = assetCodeLabel.text?.getAssetCode(), let issuerAccountId = issuerPublicKeyLabel.text?.lastLine, let issuerKeyPair = try? KeyPair(accountId: issuerAccountId) {
            guard self.hasEnoughFunding else {
                self.showFundingAlert()
                self.setButtonAsNormal()
                return
            }
            
            passwordManager.getMnemonic(password: !passwordTextField.isHidden ? passwordTextField.text : nil) { (result) -> (Void) in
                switch result {
                case .success(mnemonic: let mnemonic):
                    let assetType: Int32 = assetCode.count < 5 ? AssetType.ASSET_TYPE_CREDIT_ALPHANUM4 : AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
                    if let asset = Asset(type: assetType, code: assetCode, issuer: issuerKeyPair) {
                        let transactionHelper = TransactionHelper()
                        transactionHelper.addTrustLine(asset: asset, userMnemonic: mnemonic) { (result) -> (Void) in
                            switch result {
                            case .success:
                                break
                            case .failure(error: let error):
                                print("Error: \(error)")
                                self.setButtonAsNormal()
                            }
                            
                            self.dissmissView()
                        }
                    }
                case .failure(error: let error):
                    if error == BiometricStatus.enterPasswordPressed.rawValue {
                        self.passwordTextField.isHidden = false
                    } else {
                        self.showPasswordValidationError(validationError: ValidationErrors.InvalidPassword)
                    }
                    
                    self.setButtonAsNormal()
                }
            }
        } else {
            setButtonAsNormal()
        }
    }
    
    func expand() {
        expansionView.isHidden = false
    }
    
    func collapse() {
        expansionView.isHidden = true
    }
    
    private var isPasswordValid: Bool {
        get {
            if passwordTextField.isHidden {
                return true
            }
            
            if let password = passwordTextField.text, password.isValidPassword() {
                return true
            }
            
            showPasswordValidationError(validationError: ValidationErrors.MandatoryPassword)
            return false
        }
    }
    
    private func showPasswordValidationError(validationError: ValidationErrors) {
        passwordErrorLabel.isHidden = false
        passwordErrorLabel.text = validationError.rawValue
    }
    
    private func resetValidationError() {
        passwordErrorLabel.isHidden = true
    }
    
    private var hasEnoughFunding: Bool {
        get {
            if let parentViewController = parentContainerViewController() as? AddCurrencyViewController, let wallet = parentViewController.wallet {
                return walletManager.hasWalletEnoughFunding(wallet: wallet)
            }
            
            return false
        }
    }
    
    private func dissmissView() {
        parentContainerViewController()?.dismiss(animated: true)
    }
    
    private func showFundingAlert() {
        parentContainerViewController()?.displaySimpleAlertView(title: "Adding failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func setButtonAsValidating() {
        addButton.setTitle(AddButtonTitles.validatingAndAdding.rawValue, for: UIControlState.normal)
        addButton.isEnabled = false
    }
    
    private func setButtonAsNormal() {
        addButton.setTitle(AddButtonTitles.add.rawValue, for: UIControlState.normal)
        addButton.isEnabled = true
    }
}
