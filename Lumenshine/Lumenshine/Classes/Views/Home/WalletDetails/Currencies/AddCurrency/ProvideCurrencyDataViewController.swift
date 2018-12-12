//
//  ProvideCurrencyDataViewController.swift
//  Lumenshine
//
//  Created by Soneso on 24/08/2018.
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
    
    @IBOutlet weak var assetCodeTextField: UITextField!
    @IBOutlet weak var publicKeyTextField: UITextField!
    
    @IBOutlet weak var issuerValidationLabel: UILabel!
    
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
        
        addButton.setTitle(AddButtonTitles.validating.rawValue, for: UIControlState.normal)
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
            if passwordView.useExternalSigning {
                validateDestinationForExternalSigning(issuer: issuer, assetCode: assetCode)
            } else {
                validateDestinationAndPassword(issuer: issuer, assetCode: assetCode, biometricAuth: biometricAuth)
            }
        }
    }
    
    private func validateDestinationForExternalSigning(issuer: String, assetCode: String) {
        userManager.checkIfAccountExists(forAccountID: issuer) { (result) -> (Void) in
            if result {
                let trustorKeyPair = try! KeyPair(publicKey: PublicKey(accountId:self.wallet.publicKey), privateKey:nil)
                self.addTrustLine(trustingAccountKeyPair: trustorKeyPair, issuer: issuer, assetCode: assetCode)
            } else {
                self.showValidationError(for: self.issuerValidationStackView)
                self.issuerValidationLabel.text = self.IssuerDoesntExistValidationError
                self.resetAddButtonToDefault()
            }
        }
    }
    
    private func validateDestinationAndPassword(issuer: String, assetCode: String, biometricAuth: Bool) {
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
                                            self.addTrustLine(trustingAccountKeyPair: trustorKeyPair, issuer: issuer, assetCode: assetCode)
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
        passwordView.resetValidationErrors()
    }
    
    private func resetAddButtonToDefault() {
        self.addButton.setTitle(AddButtonTitles.add.rawValue, for: UIControlState.normal)
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
        let isPasswordValid = self.isPasswordValid(forBiometricAuth: biometricAuth)
        
        return isAssetCodeValid && isAddressValid && isPasswordValid
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
    
    private func addTrustLine(trustingAccountKeyPair:KeyPair, issuer: String, assetCode: String) {
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
            transactionHelper.addTrustLine(trustingAccountKeyPair:trustingAccountKeyPair, asset:asset) { (result) -> (Void) in
                self.hideActivity(completion: {
                    switch result {
                    case .success:
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
