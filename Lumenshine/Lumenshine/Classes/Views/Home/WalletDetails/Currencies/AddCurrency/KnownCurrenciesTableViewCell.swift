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
    case add = "SUBMIT"
    case validatingAndAdding = "validating & adding"
}

class KnownCurrenciesTableViewCell: UITableViewCell {
    static var isReloading: (String, Bool) = ("", false)
    @IBOutlet weak var assetCodeLabel: UILabel!
    @IBOutlet weak var authorizationLabel: UILabel!
    @IBOutlet weak var issuerPublicKeyLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var expansionView: UIView!
    @IBOutlet weak var authorizationView: UIView!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    var wallet: FundedWallet! {
        didSet {
            setupPasswordView()
        }
    }
    
    var canWalletSign: Bool!
    var cellIndexPath: IndexPath!
    var passwordView: PasswordView!
    private let walletManager = WalletManager()
    private let passwordManager = PasswordManager()
    
    private var authService: AuthService {
        get {
            return Services.shared.auth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        addCurrency()
    }
    
    func expand() {
        expansionView.isHidden = false
    }
    
    func collapse() {
        expansionView.isHidden = true
    }
    
    private func addCurrency(biometricAuth: Bool = false) {
        passwordView.resetValidationErrors()
        setButtonAsValidating()
        
        if isPasswordValid(biometricAuth: biometricAuth), let assetCode = assetCodeLabel.text?.getAssetCode(), let issuerAccountId = issuerPublicKeyLabel.text, let issuerKeyPair = try? KeyPair(accountId: issuerAccountId) {
            guard hasEnoughFunding else {
                showFundingAlert()
                setButtonAsNormal()
                return
            }
            
            if passwordView.useExternalSigning {
                self.addTrustLine(assetCode: assetCode, issuerKeyPair: issuerKeyPair)
            } else {
                validatePasswordAndRemoveCurrency(biometricAuth: biometricAuth, assetCode: assetCode, issuerKeyPair: issuerKeyPair)
            }
            
        } else {
            setButtonAsNormal()
        }
    }
    
    private func validatePasswordAndRemoveCurrency(biometricAuth: Bool, assetCode: String, issuerKeyPair: KeyPair) {
        passwordManager.getMnemonic(password: !biometricAuth ? passwordView.passwordTextField.text : nil) { (result) -> (Void) in
            switch result {
            case .success(mnemonic: let mnemonic):
                self.addTrustLine(assetCode: assetCode, issuerKeyPair: issuerKeyPair, mnemonic: mnemonic)
            case .failure(error: let error):
                print("Get mnemonic error: \(error)")
                self.passwordView.showInvalidPasswordError()
                self.setButtonAsNormal()
            }
        }
    }
    
    private func isPasswordValid(biometricAuth: Bool) -> Bool {
        return passwordView.validatePassword(biometricAuth: biometricAuth)
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
    
    private func addTrustLine(assetCode: String, issuerKeyPair: KeyPair, mnemonic: String? = nil) {
        let assetType: Int32 = assetCode.count < 5 ? AssetType.ASSET_TYPE_CREDIT_ALPHANUM4 : AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
        if let asset = Asset(type: assetType, code: assetCode, issuer: issuerKeyPair) {
            let signer = passwordView.useExternalSigning ? passwordView.signersTextField.text : nil
            let seed = passwordView.useExternalSigning ? passwordView.seedTextField.text : nil
            let transactionHelper = TransactionHelper(wallet: wallet, signer: signer, signerSeed: seed)
            transactionHelper.addTrustLine(asset: asset, mnemonic: mnemonic) { (result) -> (Void) in
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
    }
    
    private func setupView() {
        backgroundColor = Stylesheet.color(.clear)
        authorizationLabel.textColor = Stylesheet.color(.red)
        addButton.backgroundColor = Stylesheet.color(.blue)
    }
    
    func setupPasswordView() {
        passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
        passwordView.neededSigningSecurity = .medium
        passwordView.externalSetup = true
        passwordView.hideTitleLabels = true
        passwordView.alwaysShowValidationPlaceholders = true
        passwordView.wallet = wallet
    
        passwordView.biometricAuthAction = {
            self.addCurrency(biometricAuth: true)
        }
        
        if canWalletSign {
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
