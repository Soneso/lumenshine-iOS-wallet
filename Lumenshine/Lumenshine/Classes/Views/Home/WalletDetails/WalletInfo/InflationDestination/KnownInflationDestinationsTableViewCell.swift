//
//  KnownInflationDestinationsTableViewCell.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum SetOrRemoveButtonTitles: String {
    case set = "set destination"
    case remove = "remove"
    case validatingSet = "validating & setting"
    case validatingRemove = "validating & removing"
}

class KnownInflationDestinationsTableViewCell: UITableViewCell {
    @IBOutlet weak var expansionView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var issuerPublicKeyLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isCurrentlySetSwitch: UISwitch!
    
    @IBOutlet weak var setOrRemoveButton: UIButton!
    
    @IBAction func setOrRemoveButtonAction(_ sender: UIButton) {
        resetValidationError()
        setButtonAsValidating()
        
        if isPasswordValid {
            passwordManager.getMnemonic(password: !passwordTextField.isHidden ? passwordTextField.text : nil) { (response) -> (Void) in
                switch response {
                case .success(mnemonic: let mnemonic):
                    if self.isCurrentlySetSwitch.isOn {
                        self.removeInflationDestination(mnemonic: mnemonic)
                    } else {
                        self.setInflationDestination(sourceAccountID: self.wallet.publicKey)
                    }
                    
                case .failure(error: let error):
                    if error == BiometricStatus.enterPasswordPressed.rawValue {
                        self.passwordTextField.isHidden = false
                    } else {
                        print("Error: \(error)")
                        self.showPasswordValidationError(validationError: ValidationErrors.InvalidPassword)
                    }
                    
                    self.setButtonAsNormal()
                }
            }
        } else {
            setButtonAsNormal()
        }
    }
    
    @IBAction func detailsButtonAction(_ sender: UIButton) {
        detailsAction?()
    }
    
    var detailsAction: (() -> ())?
    
    private let walletManager = WalletManager()
    private let passwordManager = PasswordManager()
    private let inflationManager = InflationManager()
    
    func expand() {
        resetValidationError()
        expansionView.isHidden = false
        setButtonAsNormal()
    }
    
    func collapse() {
        expansionView.isHidden = true
    }
    
    private func removeInflationDestination(mnemonic: String) {
        setButtonAsNormal()
    }
    
    private func setInflationDestination(sourceAccountID: String) {
        if let inflationDestinationAddress = issuerPublicKeyLabel.text?.lines[1] {
            inflationManager.setInflationDestination(inflationAddress: inflationDestinationAddress, sourceAccountID: sourceAccountID) { (response) -> (Void) in
                switch response {
                case .success:
                    break
                case .failure(error: let error):
                    print("Error: \(error)")
                }
                
                self.dissmissView()
            }
        }
    }
    
    private func showPasswordValidationError(validationError: ValidationErrors) {
        passwordValidationLabel.isHidden = false
        passwordValidationLabel.text = validationError.rawValue
    }
    
    private var isPasswordValid: Bool {
        get {
            if passwordTextField.isHidden {
                return true
            }
            
            if let password = passwordTextField.text, password.isMandatoryValid() {
                if password.isValidPassword() {
                    return true
                }
                
                showPasswordValidationError(validationError: ValidationErrors.InvalidPassword)
            } else {
                showPasswordValidationError(validationError: ValidationErrors.MandatoryPassword)
            }
            
            return false
        }
    }
    
    private func resetValidationError() {
        passwordValidationLabel.isHidden = true
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private var wallet: FundedWallet {
        get {
            return (parentContainerViewController() as! SetInflationDestinationViewController).wallet
        }
    }
    
    private func dissmissView() {
        parentContainerViewController()?.dismiss(animated: true)
    }
    
    private func showFundingAlert() {
        parentContainerViewController()?.displaySimpleAlertView(title: "Operation failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func setButtonAsValidating() {
        if isCurrentlySetSwitch.isOn {
            setOrRemoveButton.setTitle(SetOrRemoveButtonTitles.validatingRemove.rawValue, for: UIControlState.normal)
            setOrRemoveButton.isEnabled = false
        } else {
            setOrRemoveButton.setTitle(SetOrRemoveButtonTitles.validatingSet.rawValue, for: UIControlState.normal)
            setOrRemoveButton.isEnabled = false
        }
    }
    
    private func setButtonAsNormal() {
        if isCurrentlySetSwitch.isOn {
            setOrRemoveButton.setTitle(SetOrRemoveButtonTitles.remove.rawValue, for: UIControlState.normal)
            setOrRemoveButton.isEnabled = true
        } else {
            setOrRemoveButton.setTitle(SetOrRemoveButtonTitles.set.rawValue, for: UIControlState.normal)
            setOrRemoveButton.isEnabled = true
        }
    }
}

