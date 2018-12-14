//
//  ProvideInflationDestinationViewController.swift
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

fileprivate enum SetButtonTitles: String {
    case set = "SET"
    case validating = "validating & setting"
}

fileprivate enum PublicKeyValidationErrors: String {
    case mandatory = "Public key of destination account needed"
    case notFound = "Public key not found"
}
// TODO: validate that user does not set destination to already setted destination
class ProvideInflationDestinationViewController: UIViewController {
    @IBOutlet weak var publicKeyValidationView: UIView!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    @IBOutlet weak var publicKeyTextField: UITextField!
    
    @IBOutlet weak var publicKeyValidationLabel: UILabel!
    
    @IBOutlet weak var setButton: UIButton!
    
    var wallet: FundedWallet!
    
    private let passwordManager = PasswordManager()
    private let walletManager = WalletManager()
    private let inflationManager = InflationManager()
    private var passwordView: PasswordView!
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet) // TODO: is this the current balance? May be updated in menatime
        }
    }
    
    private var isAddressValid: Bool {
        get {
            if let address = publicKeyTextField.text, address.isMandatoryValid() {
                if address.isBase64Valid() {
                    return true
                }
                
                showValidationError(for: publicKeyValidationView)
                publicKeyValidationLabel.text = ValidationErrors.InvalidAddress.rawValue
                return false
                
            } else {
                showValidationError(for: publicKeyValidationView)
                publicKeyValidationLabel.text = PublicKeyValidationErrors.mandatory.rawValue
            }
            
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasswordView()
        
        setButton.backgroundColor = Stylesheet.color(.green)
    }
    
    @IBAction func setButtonAction(_ sender: UIButton) {
        addInflation()
    }
    
    private func addInflation(biometricAuth: Bool = false) {
        passwordView.resetValidationErrors()
        publicKeyTextField.resignFirstResponder()
        setButton.setTitle(SetButtonTitles.validating.rawValue, for: UIControlState.normal)
        setButton.isEnabled = false
        showActivity(message: R.string.localizable.validateing())
        
        if isInputDataValid(biometricAuth: biometricAuth) {
            guard self.hasEnoughFunding else {
                hideActivity(completion: {
                    self.showFundingAlert()
                })
                return
            }
            
            if let inflationDestination = publicKeyTextField.text {
                if passwordView.useExternalSigning {
                    let sourceKeyPair = try! KeyPair(publicKey: PublicKey(accountId:wallet.publicKey), privateKey:nil)
                    self.setInflationDestination(sourceAccountKeyPair: sourceKeyPair, inflationDestination: inflationDestination)
                } else {
                    validatePasswordAndAddInflation(inflationDestination: inflationDestination, biometricAuth: biometricAuth)
                }
            }
        } else {
            hideActivity(completion: {
                self.resetSetButtonToDefault()
            })
        }
    }
    
    private func validatePasswordAndAddInflation(inflationDestination: String, biometricAuth: Bool) {
        passwordManager.getMnemonic(password: !biometricAuth ? passwordView.passwordTextField.text : nil) { (response) -> (Void) in
            switch response {
            case .success(mnemonic: let mnemonic):
                PrivateKeyManager.getKeyPair(forAccountID: self.wallet.publicKey, fromMnemonic: mnemonic, completion: { (response) -> (Void) in
                    switch response {
                    case .success(keyPair: let keyPair):
                        if let walletKeyPair = keyPair {
                            self.setInflationDestination(sourceAccountKeyPair: walletKeyPair, inflationDestination: inflationDestination)
                            return
                        }
                    case .failure(error: let error):
                        print(error)
                    }
                    self.hideActivity(completion: {
                        self.resetSetButtonToDefault()
                        self.showUnknownErrorAlert()
                    })
                })
            case .failure(error: let error):
                print("Error: \(error)")
                self.hideActivity(completion: {
                    self.resetSetButtonToDefault()
                    self.passwordView.showInvalidPasswordError()
                })
            }
        }
    }
    
    private func resetSetButtonToDefault() {
        self.setButton.setTitle(SetButtonTitles.set.rawValue, for: UIControlState.normal)
        self.setButton.isEnabled = true
    }
    
    private func showValidationError(for view: UIView) {
        view.isHidden = false
    }
    
    private func showFundingAlert() {
        self.displaySimpleAlertView(title: "Operation failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func showUnknownErrorAlert() {
        self.displaySimpleAlertView(title: "Operation failed", message: "An error occured while trying to set the inflation destination. Please try again later.")
    }
    
    private func setInflationDestination(sourceAccountKeyPair: KeyPair, inflationDestination: String) {
        updateActivityMessage(message: R.string.localizable.sending())
        let signer = passwordView.useExternalSigning ? passwordView.signersTextField.text : nil
        let seed = passwordView.useExternalSigning ? passwordView.seedTextField.text : nil
        
        passwordView.clearSeedAndPasswordFields()
        inflationManager.checkAndSubmitInflationDestination(inflationAddress: inflationDestination,
                                                 sourceAccountKeyPair: sourceAccountKeyPair,
                                                 externalSigner: signer,
                                                 externalSignersSeed: seed,
                                                 completion: { (response) -> (Void) in
                                                    self.hideActivity(completion: {
                                                        switch response {
                                                        case .success:
                                                            Services.shared.walletService.addWalletToRefresh(accountId: self.wallet.publicKey)
                                                            NotificationCenter.default.post(name: .refreshWalletsNotification, object: false)
                                                            self.navigationController?.popViewController(animated: true)
                                                            break
                                                        case .failure(error: let error):
                                                            self.resetSetButtonToDefault()
                                                            if error == InflationDestinationErrorCodes.accountNotFound {
                                                                self.showValidationError(for: self.publicKeyValidationView)
                                                                self.publicKeyValidationLabel.text = ValidationErrors.AddressNotFound.rawValue
                                                                return
                                                            }
                                                            print("Error: \(error)")
                                                            self.resetSetButtonToDefault()
                                                            self.showUnknownErrorAlert()
                                                        }
                                                    })
        })
    }
    
    private func isInputDataValid(biometricAuth: Bool) -> Bool {
        let isAddressValid = self.isAddressValid
        let isPasswordValid = passwordView.validatePassword(biometricAuth: biometricAuth)

        return isAddressValid && isPasswordValid
    }
    
    private func setupPasswordView() {
        passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
        passwordView.neededSigningSecurity = .medium
        passwordView.hideTitleLabels = true
        passwordView.wallet = wallet
        passwordView.passwordHintView.isHidden = false
        passwordView.passwordHintLabel.text = "Password required to set inflation destination"
        
        passwordView.biometricAuthAction = {
            self.addInflation(biometricAuth: true)
        }
        
        passwordViewContainer.addSubview(passwordView)
        
        passwordView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
