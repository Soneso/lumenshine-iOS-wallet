//
//  KnownInflationDestinationsTableViewCell.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

fileprivate enum SetOrRemoveButtonTitles: String {
    case set = "SET DESTINATION"
    case remove = "REMOVE"
    case validatingSet = "validating & setting"
    case validatingRemove = "validating & removing"
}

class KnownInflationDestinationsTableViewCell: UITableViewCell {
    @IBOutlet weak var expansionView: UIView!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var destinationPublicKeyLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    
    @IBOutlet weak var isCurrentlySetSwitch: UISwitch!
    
    @IBOutlet weak var setOrRemoveButton: UIButton!
    
    var canMasterKeySign: Bool!
    var wallet: FundedWallet! {
        didSet {
            setupPasswordView()
        }
    }
    
    private var passwordView: PasswordView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    @IBAction func setOrRemoveButtonAction(_ sender: UIButton) {
        addInflation()
    }
    
    @IBAction func detailsButtonAction(_ sender: UIButton) {
        detailsAction?()
    }
    
    var detailsAction: (() -> ())?
    
    private let walletManager = WalletManager()
    private let passwordManager = PasswordManager()
    private let inflationManager = InflationManager()
    
    func expand() {
        expansionView.isHidden = false
        setButtonAsNormal()
    }
    
    func collapse() {
        expansionView.isHidden = true
    }
    
    private func addInflation(biometricAuth: Bool = false) {
        passwordView.resetValidationErrors()
        setButtonAsValidating()
        
        if passwordView.validatePassword(biometricAuth: biometricAuth) {
            guard hasEnoughFunding else {
                showFundingAlert()
                setButtonAsNormal()
                return
            }
            
            if passwordView.useExternalSigning {
                let sourceKeyPair = try! KeyPair(publicKey: PublicKey(accountId:wallet.publicKey), privateKey:nil)
                if self.isCurrentlySetSwitch.isOn {
                    self.removeInflationDestination(sourceAccountKeyPair: sourceKeyPair)
                } else {
                    if let inflationDestinationAddress = self.destinationPublicKeyLabel.text {
                        self.setInflationDestination(sourceAccountKeyPair: sourceKeyPair, destination: inflationDestinationAddress)
                    }else {
                        // TODO improve, make sure not to show any cells that have no destination address
                        self.showUnknownErrorAlert()
                        setButtonAsNormal()
                    }
                }
            } else {
                validatePasswordAndSetInflation(biometricAuth: biometricAuth)
            }

        } else {
            setButtonAsNormal()
        }
    }
    
    private func validatePasswordAndSetInflation(biometricAuth: Bool) {
        passwordManager.getMnemonic(password: !biometricAuth ? passwordView.passwordTextField.text : nil) { (response) -> (Void) in
            switch response {
            case .success(mnemonic: let mnemonic):
                PrivateKeyManager.getKeyPair(forAccountID: self.wallet.publicKey, fromMnemonic: mnemonic, completion: { (response) -> (Void) in
                    switch response {
                    case .success(keyPair: let keyPair):
                        if let walletKeyPair = keyPair {
                            if self.isCurrentlySetSwitch.isOn {
                                self.removeInflationDestination(sourceAccountKeyPair: walletKeyPair)
                                return
                            } else {
                                if let inflationDestinationAddress = self.destinationPublicKeyLabel.text {
                                    self.setInflationDestination(sourceAccountKeyPair: walletKeyPair, destination: inflationDestinationAddress)
                                    return
                                }
                            }
                        }
                    case .failure(error: let error):
                        print(error)
                    }
                    self.showUnknownErrorAlert()
                    self.setButtonAsNormal()
                })
            case .failure(error: let error):
                print("Error: \(error)")
                self.passwordView.showInvalidPasswordError()
                self.setButtonAsNormal()
            }
        }
    }
    
    private func removeInflationDestination(sourceAccountKeyPair: KeyPair) {
        // set the inflation destination to the account itself.
        self.setInflationDestination(sourceAccountKeyPair: sourceAccountKeyPair, destination: self.wallet.publicKey)
    }
    
    private func setInflationDestination(sourceAccountKeyPair: KeyPair, destination: String) {
        let signer = passwordView.useExternalSigning ? passwordView.signersTextField.text : nil
        let seed = passwordView.useExternalSigning ? passwordView.seedTextField.text : nil
     
        inflationManager.checkAndSubmitInflationDestination(inflationAddress: destination,
                                                            sourceAccountKeyPair: sourceAccountKeyPair,
                                                            externalSigner: signer,
                                                            externalSignersSeed: seed) { (response) -> (Void) in
                                                                switch response {
                                                                case .success:
                                                                    self.dissmissView()
                                                                    break
                                                                case .failure(error: let error):
                                                                    print("Error: \(error)")
                                                                    if (error == InflationDestinationErrorCodes.accountNotFound) {
                                                                        self.showDestinationNotFoundAlert()
                                                                    } else {
                                                                        self.showUnknownErrorAlert()
                                                                    }
                                                                    self.setButtonAsNormal()
                                                                }
        }
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private func dissmissView() {
        viewContainingController()?.navigationController?.popViewController(animated: true)
    }
    
    private func showFundingAlert() {
        parentContainerViewController()?.displaySimpleAlertView(title: "Operation failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    private func showDestinationNotFoundAlert() {
        parentContainerViewController()?.displaySimpleAlertView(title: "Operation failed", message: "Inflation destination does not exist any more.")
    }
    private func showUnknownErrorAlert() {
        parentContainerViewController()?.displaySimpleAlertView(title: "Operation failed", message: "An error occured while trying to set the inflation destination. Please try again later.")
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
    
    private func setupView() {
        backgroundColor = Stylesheet.color(.clear)
        setOrRemoveButton.backgroundColor = Stylesheet.color(.green)
    }
    
    func setupPasswordView() {
        passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
        passwordView.neededSigningSecurity = .medium
        passwordView.externalSetup = true
        passwordView.hideTitleLabels = true
        passwordView.alwaysShowValidationPlaceholders = true
        passwordView.wallet = wallet
        
        passwordView.biometricAuthAction = {
            self.addInflation(biometricAuth: true)
        }
        
        if canMasterKeySign {
            passwordView.showPassword()
        } else {
            passwordView.showSigners()
        }
        
        passwordViewContainer.addSubview(passwordView)
        
        passwordView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for subView in passwordViewContainer.subviews {
            subView.removeFromSuperview()
        }
        
        passwordView = nil
    }
}
