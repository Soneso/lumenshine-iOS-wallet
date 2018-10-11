//
//  ProvideInflationDestinationViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum SetButtonTitles: String {
    case set = "SET"
    case validating = "validating & setting"
}

fileprivate enum PublicKeyValidationErrors: String {
    case mandatory = "Public key of destination account needed"
    case notFound = "Public key not found"
}

class ProvideInflationDestinationViewController: UIViewController {
    @IBOutlet weak var publicKeyValidationView: UIView!
    @IBOutlet weak var passwordValidationView: UIView!
    
    @IBOutlet weak var publicKeyTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var publicKeyValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var setButton: UIButton!
    
    @IBAction func setButtonAction(_ sender: UIButton) {
        resetValidationErrors()
        setButton.setTitle(SetButtonTitles.validating.rawValue, for: UIControlState.normal)
        setButton.isEnabled = false
        
        if self.isInputDataValid {
            guard self.hasEnoughFunding else {
                self.showFundingAlert()
                return
            }
            
            if let inflationDestination = publicKeyTextField.text{
                passwordManager.getMnemonic(password: !passwordTextField.isHidden ? passwordTextField.text : nil) { (response) -> (Void) in
                    switch response {
                    case .success(_):
                        self.setInflationDestination(inflationDestination: inflationDestination)
                    case .failure(error: let error):
                        if error == BiometricStatus.enterPasswordPressed.rawValue {
                            self.passwordTextField.isHidden = false
                        } else {
                            print("Error: \(error)")
                            self.showValidationError(for: self.passwordValidationView)
                            self.passwordValidationLabel.text = ValidationErrors.InvalidPassword.rawValue
                        }
                        
                        self.resetSetButtonToDefault()
                    }
                }
            }
        } else {
            resetSetButtonToDefault()
        }
    }
    
    var wallet: FundedWallet!
    private let passwordManager = PasswordManager()
    private var inputDataValidator = InputDataValidator()
    private let walletManager = WalletManager()
    private let inflationManager = InflationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BiometricHelper.isBiometricAuthEnabled {
            passwordTextField.isHidden = true
        }
        
        setButton.backgroundColor = Stylesheet.color(.green)
    }
    
    private func resetValidationErrors() {
        publicKeyValidationView.isHidden = true
        passwordValidationView.isHidden = true
    }
    
    private func resetSetButtonToDefault() {
        setButton.setTitle(SetButtonTitles.set.rawValue, for: UIControlState.normal)
        setButton.isEnabled = true
    }
    
    private func showValidationError(for view: UIView) {
        view.isHidden = false
    }
    
    private func showFundingAlert() {
        self.displaySimpleAlertView(title: "Setting failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func setInflationDestination(inflationDestination: String) {
        inflationManager.setInflationDestination(inflationAddress: inflationDestination, sourceAccountID: wallet.publicKey, completion: { (response) -> (Void) in
            switch response {
            case .success:
                break
            case .failure(error: let error):
                if error == InflationDestinationErrorCodes.accountNotFound {
                    self.showValidationError(for: self.publicKeyValidationView)
                    self.publicKeyValidationLabel.text = ValidationErrors.AddressNotFound.rawValue
                    self.resetSetButtonToDefault()
                    return
                }
                
                print("Error: \(error)")
            }
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
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
    
    private var isPasswordValid: Bool {
        get {
            if let password = passwordTextField.text, password.isMandatoryValid() {
                if password.isValidPassword() {
                    return true
                }
                
                showValidationError(for: passwordValidationView)
                passwordValidationLabel.text = ValidationErrors.InvalidPassword.rawValue
            } else {
                showValidationError(for: passwordValidationView)
                passwordValidationLabel.text = ValidationErrors.MandatoryPassword.rawValue
            }
            
            return false
        }
    }
    
    private var isInputDataValid: Bool {
        get {
            let isAddressValid = self.isAddressValid
            
            if passwordTextField.isHidden {
                if !isAddressValid {
                    return false
                }
                
                return true
            }
            
            let isPasswordValid = self.isPasswordValid
            return isAddressValid && isPasswordValid
        }
    }
}
