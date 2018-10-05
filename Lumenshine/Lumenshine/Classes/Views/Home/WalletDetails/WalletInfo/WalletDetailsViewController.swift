//
//  WalletDetailsViewController.swift
//  Lumenshine
//
//  Created by Soneso on 03/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum CancelRevealButtonTitles: String {
    case cancel = "cancel"
    case reveal = "reveal"
    case revealing = "revealing"
}

class WalletDetailsViewController: UIViewController {
    @IBOutlet weak var balanceTitleLabel: UILabel!
    @IBOutlet weak var balanceValuesLabel: UILabel!
    @IBOutlet weak var availableValuesLabel: UILabel!
    @IBOutlet weak var privateKeyValueLabel: UILabel!
    @IBOutlet weak var inflationCoinLabel: UILabel!
    @IBOutlet weak var inflationShortDescriptionLabel: UILabel!
    @IBOutlet weak var inflationPublicKeyLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var secretRevealButton: UIButton!
    @IBOutlet weak var cancelRevealButton: UIButton!
    @IBOutlet weak var inflationDetailsButton: UIButton!
    
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var noInflationSetStackView: UIStackView!
    @IBOutlet weak var inflationButtonsStackView: UIStackView!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func sendButtonAction(_ sender: UIButton) {
        paymentOperationsVCManager.addViewController(forAction: WalletAction.send, wallet: wallet)
    }
    
    @IBAction func receiveButtonAction(_ sender: UIButton) {
        paymentOperationsVCManager.addViewController(forAction: WalletAction.receive, wallet: wallet)
    }
    
    @IBAction func secretRevealButtonAction(_ sender: UIButton) {
        resetPasswordValidation()
        if !isPasswordValid {
            return
        }
        
        if let password = passwordTextField.text {
            cancelRevealButton.setTitle(CancelRevealButtonTitles.revealing.rawValue, for: UIControlState.normal)
            cancelRevealButton.isEnabled = false
            
            passwordManager.getPrivateKey(fromPassword: password, forAccountID: wallet.publicKey) { (response) -> (Void) in
                switch response {
                case .success(privateKey: let privateKey):
                    self.privateKeyValueLabel.text = privateKey
                case .failure(error: let error):
                    print("Error: \(error)")
                    self.setPasswordValidationError(validationError: ValidationErrors.InvalidPassword)
                }
                
                self.cancelRevealButton.setTitle(CancelRevealButtonTitles.cancel.rawValue, for: UIControlState.normal)
                self.cancelRevealButton.isEnabled = true
            }
        }
    }
    
    @IBAction func cancelRevealButtonAction(_ sender: UIButton) {
        if passwordStackView.isHidden {
            passwordStackView.isHidden = false
            cancelRevealButton.setTitle(CancelRevealButtonTitles.cancel.rawValue, for: UIControlState.normal)
            cancelRevealButton.setTitleColor(nil, for: UIControlState.normal)
        } else {
            passwordStackView.isHidden = true
            resetPasswordValidation()
            passwordTextField.text = nil
            privateKeyValueLabel.text = PublicKeyLabelInitialValue
            cancelRevealButton.setTitle(CancelRevealButtonTitles.reveal.rawValue, for: UIControlState.normal)
            cancelRevealButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        }
    }
    
    @IBAction func setInflationDestinationButtonAction(_ sender: UIButton) {
        addSetInflationDestinationViewController()
    }
    
    @IBAction func inflationDetailsButtonAction(_ sender: UIButton) {
        let knownInflationDestinationDetailsViewController = KnownInflationDestinationDetailsViewController(nibName: "KnownInflationDestinationDetailsViewController", bundle: Bundle.main)
        knownInflationDestinationDetailsViewController.knownInflationDestination = currentInflationDestination
        let navController = BaseNavigationViewController(rootViewController: knownInflationDestinationDetailsViewController)
        present(navController, animated: true)
    }
    
    @IBAction func inflationChangeButtonAction(_ sender: UIButton) {
        if let inflationDestination = inflationPublicKeyLabel.text {
            addSetInflationDestinationViewController(currentInflationDestination: inflationDestination)
        }
    }
    
    @IBAction func inflationCopyKeyButtonAction(_ sender: UIButton) {
        if let value = inflationPublicKeyLabel.text {
            UIPasteboard.general.string = value
            let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
            self.present(alert, animated: true)
            alert.dismiss(animated: true)
        }
    }
    
    var wallet: FundedWallet!
    
    private var passwordManager = PasswordManager()
    private var inflationManager = InflationManager()
    private let PublicKeyLabelInitialValue = "****************************"
    private let InflationNoneSet = "none"
    private let InflationNoneSetHint = "Hint: Vote or earn free lumens by setting the inflation destination"
    private var currentInflationDestination: KnownInflationDestinationResponse!
    private var paymentOperationsVCManager: PaymentOperationsVCManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBalances()
        setupInflationDestination()
        paymentOperationsVCManager = PaymentOperationsVCManager(parentViewController: self)
    }
    
    private func setupBalances() {
        balanceTitleLabel.text = wallet.hasOnlyNative ? R.string.localizable.balance().uppercased() : R.string.localizable.balances().uppercased()
        var balanceValues = String()
        var availableValues = String()
        
        balanceValues.append("\(wallet.nativeBalance) \(NativeCurrencyNames.xlm.rawValue)\n")
        availableValues.append("\(wallet.nativeBalance.availableAmount(forWallet: wallet)) \(NativeCurrencyNames.xlm.rawValue)\n")
        
        for currency in wallet.uniqueAssetCodeBalances {
            if let assetCode = currency.assetCode, let balance = CoinUnit(currency.balance){
                balanceValues.append("\(balance) \(assetCode)\n")
                availableValues.append("\(balance) \(assetCode)\n")
            }
        }
        
        balanceValuesLabel.text = String(balanceValues.dropLast())
        availableValuesLabel.text = String(availableValues.dropLast())
    }
    
    private var isPasswordValid: Bool {
        get {
            if let password = passwordTextField.text, password.isMandatoryValid() {
                if password.isValidPassword() {
                    return true
                }
                
                setPasswordValidationError(validationError: ValidationErrors.InvalidPassword)
                return false
            } else {
                setPasswordValidationError(validationError: ValidationErrors.MandatoryPassword)
                return false
            }
        }
    }
    
    private func resetPasswordValidation() {
        passwordValidationLabel.isHidden = true
    }
    
    private func setPasswordValidationError(validationError: ValidationErrors) {
        passwordValidationLabel.text = validationError.rawValue
        passwordValidationLabel.isHidden = false
    }
    
    private func setUIForNoInflationSet() {
        inflationCoinLabel.text = InflationNoneSet
        inflationCoinLabel.textColor = UIColor.red
        inflationPublicKeyLabel.isHidden = true
        inflationShortDescriptionLabel.text = InflationNoneSetHint
        inflationShortDescriptionLabel.textColor = UIColor.green
    }
    
    private func setUIForInflationSet(knownInflationDestination: KnownInflationDestinationResponse) {
        inflationCoinLabel.text = knownInflationDestination.name
        inflationCoinLabel.textColor = UIColor.green
        inflationPublicKeyLabel.text = knownInflationDestination.issuerPublicKey
        inflationShortDescriptionLabel.text = knownInflationDestination.shortDescription
        inflationButtonsStackView.isHidden = false
        noInflationSetStackView.isHidden = true
        currentInflationDestination = knownInflationDestination
    }
    
    private func setUIForUnkownInflationSet(inflationAddress: String) {
        inflationCoinLabel.isHidden = true
        inflationPublicKeyLabel.text = inflationAddress
        inflationShortDescriptionLabel.isHidden = true
        inflationButtonsStackView.isHidden = false
        noInflationSetStackView.isHidden = true
        inflationDetailsButton.isHidden = true
    }
    
    private func checkForKnownInflationDestination(inflationAddress: String) {
        inflationManager.checkInflationDestination(inflationAddress: inflationAddress) { (response) -> (Void) in
            switch response {
            case .success(knownInflationDestination: let knownInflationDestination):
                self.setUIForInflationSet(knownInflationDestination: knownInflationDestination)
            case .failure(error: let error):
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
                self.setUIForUnkownInflationSet(inflationAddress: inflationAddress)
            }
        }
    }
    
    private func setupInflationDestination() {
        inflationManager.getInflationDestination(forAccount: wallet.publicKey) { (response) -> (Void) in
            switch response {
            case .success(inflationDestinationAddress: let inflationAddress):
                self.checkForKnownInflationDestination(inflationAddress: inflationAddress)
            case .failure(error: let error):
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
                self.setUIForNoInflationSet()
            }
        }
    }
    
    private func addSetInflationDestinationViewController(currentInflationDestination: String? = nil) {
        let setInflationDestinationViewController = SetInflationDestinationViewController(nibName: "SetInflationDestinationViewController", bundle: Bundle.main)
        setInflationDestinationViewController.wallet = wallet
        setInflationDestinationViewController.currentInflationDestination = currentInflationDestination
        let navController = BaseNavigationViewController(rootViewController: setInflationDestinationViewController)
        present(navController, animated: true)
    }
}
