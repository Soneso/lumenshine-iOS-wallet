//
//  ProvideCurrencyDataViewController.swift
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

fileprivate enum AddButtonTitles: String {
    case add = "SUBMIT"
    case validating = "Validating & adding"
}

fileprivate enum AlphanumericTypesMaximumLength: Int {
    case alphanumeric4 = 4
    case alphanumeric12 = 12
}

class ProvideCurrencyDataViewController: UIViewController {
    
    @IBOutlet weak var currencyValidationStackView: UIStackView!
    @IBOutlet weak var issuerValidationStackView: UIStackView!
    @IBOutlet weak var limitValidationStackView: UIStackView!
    @IBOutlet weak var assetCodeTextField: UITextField!
    @IBOutlet weak var publicKeyTextField: UITextField!
    @IBOutlet weak var limitTextField: UITextField!
    @IBOutlet weak var issuerValidationLabel: UILabel!
    @IBOutlet weak var limitValidationLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    var wallet: FundedWallet!
    private var walletManager = WalletManager()
    private var passwordView: PasswordView!
    private let IssuerDoesntExistValidationError = "Issuer does not exist"
    private let passwordManager = PasswordManager()
    private let userManager = UserManager()
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        addCurrency()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.backgroundColor = Stylesheet.color(.blue)
        setupPasswordView()
    }
    
    private func addCurrency(forBiometricAuth biometricAuth: Bool = false) {
        resetValidationErrors()
        publicKeyTextField.resignFirstResponder()
        assetCodeTextField.resignFirstResponder()
        limitTextField.resignFirstResponder()
        
        addButton.setTitle(AddButtonTitles.validating.rawValue, for: UIControl.State.normal)
        addButton.isEnabled = false
        showActivity(message: R.string.localizable.validateing())
        
        if isInputDataValid(forBiometricAuth: biometricAuth) {
            guard hasEnoughFunding else {
                hideActivity(completion: {
                    self.showFundingAlert()
                })
                return
            }
            
            validatePasswordAndDestination(forBiometricAuth: biometricAuth)
        } else {
            hideActivity(completion: {
                self.resetAddButtonToDefault()
            })
        }
    }
    
    private func validatePasswordAndDestination(forBiometricAuth biometricAuth: Bool) {
        if let assetCode = assetCodeTextField.text, let issuer = publicKeyTextField.text {
            
            var limit:Decimal? = nil
            if let limitText = limitTextField.text {
                let correctedLimit = limitText.replacingOccurrences(of: ",", with: ".")
                limit = Decimal(string: correctedLimit)
                if let limitCheck = limit, limitCheck < 0 || limitCheck >= 922337203685.4775807 {
                    limit = nil
                }
            }
            
            if passwordView.useExternalSigning {
                validateDestinationForExternalSigning(issuer: issuer, assetCode: assetCode, limit: limit)
            } else {
                validateDestinationAndPassword(issuer: issuer, assetCode: assetCode, limit:limit, biometricAuth: biometricAuth)
            }
        }
    }
    
    private func validateDestinationForExternalSigning(issuer: String, assetCode: String, limit:Decimal?) {
        userManager.checkIfAccountExists(forAccountID: issuer) { (result) -> (Void) in
            if result {
                let trustorKeyPair = try! KeyPair(publicKey: PublicKey(accountId:self.wallet.publicKey), privateKey:nil)
                self.addTrustLine(trustingAccountKeyPair: trustorKeyPair, issuer: issuer, assetCode: assetCode, limit:limit)
            } else {
                self.showValidationError(for: self.issuerValidationStackView)
                self.issuerValidationLabel.text = self.IssuerDoesntExistValidationError
                self.resetAddButtonToDefault()
            }
        }
    }
    
    private func validateDestinationAndPassword(issuer: String, assetCode: String, limit:Decimal?, biometricAuth: Bool) {
        userManager.checkIfAccountExists(forAccountID: issuer) { (accountExists) -> (Void) in
            if accountExists {
                let password = !biometricAuth ? self.passwordView.passwordTextField.text : nil
                self.passwordManager.getMnemonic(password: password) { (passwordResult) -> (Void) in
                    DispatchQueue.main.async {
                        switch passwordResult {
                        case .success(mnemonic: let mnemonic):
                            PrivateKeyManager.getKeyPair(forAccountID: self.wallet.publicKey, fromMnemonic: mnemonic) { (response) -> (Void) in
                                DispatchQueue.main.async {
                                    switch response {
                                    case .success(keyPair: let keyPair):
                                        if let trustorKeyPair = keyPair {
                                            self.addTrustLine(trustingAccountKeyPair: trustorKeyPair, issuer: issuer, assetCode: assetCode, limit:limit)
                                            return
                                        }
                                    case .failure(error: let error):
                                        print(error)
                                    }
                                    self.hideActivity(completion: {
                                        self.showSigningAlert()
                                        self.resetAddButtonToDefault()
                                    })
                                }
                            }
                        case .failure(error: let error):
                            if error != BiometricStatus.enterPasswordPressed.rawValue {
                                self.passwordView.showInvalidPasswordError()
                            }
                            self.resetAddButtonToDefault()
                            self.hideActivity()
                        }
                    }
                }
            } else {
                self.showValidationError(for: self.issuerValidationStackView)
                self.issuerValidationLabel.text = self.IssuerDoesntExistValidationError
                self.resetAddButtonToDefault()
                self.hideActivity()
            }
        }
    }
    
    private func setupPasswordView() {
        passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
        passwordView.neededSigningSecurity = .medium
        passwordView.hideTitleLabels = true
        passwordView.wallet = wallet
        passwordView.passwordHintView.isHidden = false
        passwordView.passwordHintLabel.text = "Password required to add currency"
        
        passwordView.biometricAuthAction = {
            self.addCurrency(forBiometricAuth: true)
        }
        
        passwordViewContainer.addSubview(passwordView)
        
        passwordView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func showValidationError(for stackView: UIStackView) {
        stackView.isHidden = false
    }
    
    private func resetValidationErrors() {
        currencyValidationStackView.isHidden = true
        issuerValidationStackView.isHidden = true
        limitValidationStackView.isHidden = true
        passwordView.resetValidationErrors()
    }
    
    private func resetAddButtonToDefault() {
        self.addButton.setTitle(AddButtonTitles.add.rawValue, for: UIControl.State.normal)
        self.addButton.isEnabled = true
    }
    
    private var isAddressValid: Bool {
        get {
            if let address = publicKeyTextField.text, address.isMandatoryValid() {
                if address.isBase64Valid() {
                    return true
                }
                
                showValidationError(for: issuerValidationStackView)
                issuerValidationLabel.text = ValidationErrors.InvalidAddress.rawValue
                return false
            } else {
                showValidationError(for: issuerValidationStackView)
                issuerValidationLabel.text = ValidationErrors.Mandatory.rawValue
            }
            
            return false
        }
    }
    private var isLimitValid: Bool {
        if let limitText = limitTextField.text, limitText.trimmed.count > 0 {
            let correctedLimit = limitText.replacingOccurrences(of: ",", with: ".")
            if let limitDecimal = Decimal(string: correctedLimit), limitDecimal >= 0, limitDecimal <= 922337203685.4775807 {
                return true
            } else {
                showValidationError(for: limitValidationStackView)
                return false
            }
        }
        return true
    }
    
    private var isAssetCodeValid: Bool {
        get {
            if let assetCode = assetCodeTextField.text, assetCode.isAssetCodeValid() {
                return true
            }
            
            showValidationError(for: currencyValidationStackView)
            return false
        }
    }
    
    private func isPasswordValid(forBiometricAuth biometricAuth: Bool) -> Bool {
        return passwordView.validatePassword(biometricAuth: biometricAuth)
    }
    
    private func isInputDataValid(forBiometricAuth biometricAuth: Bool) -> Bool {
        let isAssetCodeValid = self.isAssetCodeValid
        let isAddressValid = self.isAddressValid
        let isLimitValid = self.isLimitValid
        let isPasswordValid = self.isPasswordValid(forBiometricAuth: biometricAuth)
        
        return isAssetCodeValid && isAddressValid && isLimitValid && isPasswordValid
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private func showFundingAlert() {
        self.displaySimpleAlertView(title: "Adding failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func showSigningAlert() {
        self.displaySimpleAlertView(title: "Adding failed", message: "A signing error occured.")
    }
    
    private func showTrnsactionFailedAlert() {
        self.displaySimpleAlertView(title: "Adding failed", message: "A transaction error occured.")
    }
    
    private func addTrustLine(trustingAccountKeyPair:KeyPair, issuer: String, assetCode: String, limit: Decimal?) {
        updateActivityMessage(message: R.string.localizable.sending())
        let signer = passwordView.useExternalSigning ? passwordView.signersTextField.text : nil
        let seed = passwordView.useExternalSigning ? passwordView.seedTextField.text : nil
        let transactionHelper = TransactionHelper(wallet: wallet, signer: signer, signerSeed: seed)
        
        var assetType: Int32? = nil
        
        if assetCode.count <= AlphanumericTypesMaximumLength.alphanumeric4.rawValue {
            assetType = AssetType.ASSET_TYPE_CREDIT_ALPHANUM4
        } else {
            assetType = AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
        }
        
        let issuerKeyPair = try? KeyPair(accountId: issuer)
        
        passwordView.clearSeedAndPasswordFields()
        if let assetType = assetType,
            let issuerKeyPair = issuerKeyPair,
            let asset = Asset(type: assetType, code: assetCode, issuer: issuerKeyPair) {
            transactionHelper.addTrustLine(trustingAccountKeyPair:trustingAccountKeyPair, asset:asset, limit:limit) { (result) -> (Void) in
                self.hideActivity(completion: {
                    switch result {
                    case .success:
                        Services.shared.walletService.addWalletToRefresh(accountId: self.wallet.publicKey)
                        NotificationCenter.default.post(name: .refreshWalletsNotification, object: false)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(error: let error):
                        print("Error: \(String(describing: error))")
                        self.showTrnsactionFailedAlert()
                        self.resetAddButtonToDefault()
                    }
                })
            }
        } else {
            hideActivity()
        }
    }
}
