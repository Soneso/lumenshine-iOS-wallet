//
//  PasswordView.swift
//  Lumenshine
//
//  Created by Soneso on 15/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

class PasswordView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var signersStackView: UIStackView!
    
    @IBOutlet weak var passwordValidationView: UIView!
    @IBOutlet weak var seedValidationView: UIView!
    @IBOutlet weak var seedInputView: UIView!
    @IBOutlet weak var passwordInputView: UIView!
    @IBOutlet weak var biometricAuthView: UIView!
    @IBOutlet weak var signersTitleView: UIView!
    @IBOutlet weak var passwordTitleView: UIView!
    
    @IBOutlet weak var passwordValidationErrorLabel: UILabel!
    @IBOutlet weak var seedValidationErrorLabel: UILabel!
    @IBOutlet weak var signersTitleLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signersTextField: UITextField!
    @IBOutlet weak var seedTextField: UITextField!
    
    var wallet: FundedWallet! {
        didSet {
            setup()
        }
    }
   
    var signerLabelTitle: String? {
        didSet {
            if let title = signerLabelTitle {
                signersTitleLabel.text = title
            }
        }
    }
    
    var useExternalSigning: Bool {
        get {
            return passwordStackView.isHidden
        }
    }
    
    var contentView: UIScrollView?
    var biometricAuthAction: (() -> ())?
    var externalSetup = false
    var hideTitleLabels: Bool = false
    var alwaysShowValidationPlaceholders = false
    var masterKeyNeededSecurity: MasterKeySecurityLevels!
    
    private let emptySpace = " "
    private let userManager = UserManager()
    private var availableSigners: [AccountSignerResponse]!
    private var signerPickerView: UIPickerView!
    
    @IBAction func biometricAuthButtonAction(_ sender: UIButton) {
        biometricAuthAction?()
    }
    
    func validatePassword(biometricAuth: Bool = false) -> Bool {
        if biometricAuth {
            return true
        }
        
        if passwordStackView.isHidden {
            return validateSignersSeed()
        }
        
        if let currentPassword = passwordTextField.text {
            if !currentPassword.isMandatoryValid() {
                setValidationError(view: passwordValidationView, label: passwordValidationErrorLabel, errorMessage: .Mandatory)
                return false
            }
            
            return true
        }
        
        return false
    }
    
    func showInvalidPasswordError() {
        setValidationError(view: passwordValidationView, label: passwordValidationErrorLabel, errorMessage: .InvalidPassword)
    }
    
    func resetValidationErrors() {
        if !alwaysShowValidationPlaceholders {
            passwordValidationView.isHidden = true
            seedValidationView.isHidden = true
            passwordValidationErrorLabel.text = nil
            seedValidationErrorLabel.text = nil
        } else {
            passwordValidationErrorLabel.text = emptySpace
            seedValidationErrorLabel.text = emptySpace
        }
    }
    
    func setup() {
        if !externalSetup {
            checkIfMasterKeyCanSignTransaction()
        }
        
        if BiometricHelper.isBiometricAuthEnabled {
            showBiometricAuthButton()
        }
        
        resetValidationErrors()
        
        if alwaysShowValidationPlaceholders {
            passwordStackView.spacing = CGFloat(2)
            signersStackView.spacing = CGFloat(2)
            setupHeightConstraints()
        }
    }
    
    func showSigners() {
        signersStackView.isHidden = false
        hideTitleLabelsIfNeeded()
        hideBiometricAuthButton()
        setupSigners()
    }
    
    func showPassword() {
        hideTitleLabelsIfNeeded()
        passwordStackView.isHidden = false
    }
    
    private func setupHeightConstraints() {
        setStaticHeightConstraint(for: passwordTextField)
        setStaticHeightConstraint(for: signersTextField)
        setStaticHeightConstraint(for: seedTextField)
    }
    
    private func setStaticHeightConstraint(for item: UIView) {
        item.snp.removeConstraints()
        item.snp.makeConstraints { (make) in
            make.height.equalTo(40).priority(.high)
        }
    }
    
    private func setValidationError(view: UIView, label: UILabel, errorMessage: ValidationErrors) {
        if !alwaysShowValidationPlaceholders {
            view.isHidden = false
        }
        
        label.text = errorMessage.rawValue
        contentView?.setContentOffset(CGPoint(x: 0, y: view.frame.center.y), animated: false)
    }
    
    private func checkIfMasterKeyCanSignTransaction() {
        userManager.canMasterKeySignOperation(accountID: wallet.publicKey, neededSecurity: masterKeyNeededSecurity) { (response) -> (Void) in
            switch response {
            case .success(canSign: let canSign):
                if !canSign {
                    self.showSigners()
                } else {
                    self.showPassword()
                }
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func hideTitleLabelsIfNeeded() {
        if hideTitleLabels {
            passwordTitleView.isHidden = true
            signersTitleView.isHidden = true
        }
    }
    
    private func hideBiometricAuthButton() {
        biometricAuthView.isHidden = true
    }
    
    private func showBiometricAuthButton() {
        biometricAuthView.isHidden = false
    }
    
    private func setupSigners() {
        userManager.getSignersList(accountID: wallet.publicKey) { (response) -> (Void) in
            switch response {
            case .success(signersList: let signersList):
                if signersList.count == 1 {
                    self.showNoMultiSigSupportError()
                } else {
                    self.setupSignersPicker(signerList: signersList)
                }
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func showNoMultiSigSupportError() {
        if let navController = viewContainingController()?.navigationController {
            navController.popViewController(animated: false)
            let noMultiSigSupportViewController = NoMultiSigSupportViewController()
            navController.pushViewController(noMultiSigSupportViewController, animated: true)
        }
    }
    
    private func setupSignersPicker(signerList: [AccountSignerResponse]) {
        if let masterKeyWeight = wallet.masterKeyWeight {
            availableSigners = signerList.filter({ (signer) -> Bool in
                return signer.weight > masterKeyWeight
            })
        }
        
        signerPickerView = UIPickerView()
        signerPickerView.delegate = self
        signerPickerView.dataSource = self
        signersTextField.text = availableSigners.first?.publicKey
        signersTextField.inputView = signerPickerView
        signersTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(signerDoneButtonTap))
    }
    
    private func validateSignersSeed() -> Bool {
        if let currentSeed = seedTextField.text {
            if !currentSeed.isMandatoryValid() {
                setValidationError(view: seedValidationView, label: seedValidationErrorLabel, errorMessage: .Mandatory)
                return false
            }

            if let signerKeyPair = try? KeyPair(secretSeed: currentSeed) {
                if signerKeyPair.accountId != signersTextField.text {
                    setValidationError(view: seedValidationView, label: seedValidationErrorLabel, errorMessage: .InvalidSignerSeed)
                    return false
                }
                
                return true
            } else {
                setValidationError(view: seedValidationView, label: seedValidationErrorLabel, errorMessage: .InvalidSignerSeed)
                return false
            }
        }
        
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == signerPickerView {
            return availableSigners.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == signerPickerView {
            return availableSigners[row].publicKey
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }
    
    private func selectAsset(pickerView: UIPickerView, row: Int) {
        if pickerView == signerPickerView {
            signersTextField.text = availableSigners[row].publicKey
        }
    }
    
    @objc func signerDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: signerPickerView, row: signerPickerView.selectedRow(inComponent: 0))
    }
}
