//
//  MergeWalletViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 23/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import stellarsdk

class MergeWalletViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ExtrasViewModelType
    fileprivate var selectedWalletPK: String? = nil
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let accountLabel = UILabel()
    fileprivate let accountInputField = LSTextField()
    fileprivate let walletLabel = UILabel()
    fileprivate let walletField = LSTextField()
    fileprivate let passwordInputField = LSTextField()
    fileprivate let noWalletLabel = UILabel()
    fileprivate let successLabel = UILabel()
    
    fileprivate let submitButton = RaisedButton()
    fileprivate let touchIDButton = Button()
    
    fileprivate let verticalSpacing: CGFloat = 42.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: ExtrasViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func resignFirstResponder() -> Bool {
        accountInputField.resignFirstResponder()
        walletField.resignFirstResponder()
        passwordInputField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

extension MergeWalletViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        passwordInputField.detail = nil
        accountInputField.detail = nil
        walletField.detail = nil
        
        guard let password = passwordInputField.text,
            !password.isEmpty else {
                passwordInputField.detail = R.string.localizable.empty_password()
                return
        }
        
        
        guard let accountIdOrAddress = accountInputField.text, !accountIdOrAddress.isEmpty else {
            accountInputField.detail = R.string.localizable.empty_accountId_or_address()
            return
        }

        _ = resignFirstResponder()
        
        showActivity(message: R.string.localizable.loading())
        mergeAccount(accountIdOrAddress: accountIdOrAddress, password: password)
    }
    
    func mergeAccount(accountIdOrAddress:String, password:String) {
        if accountIdOrAddress.isFederationAddress() {
            Federation.resolve(stellarAddress: accountIdOrAddress, completion: { (response) -> (Void) in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let federationResponse):
                        if let pk = federationResponse.accountId {
                            do {
                                let dKeyPair = try KeyPair(publicKey: PublicKey(accountId: pk))
                                self.mergeAccount(destinationKeyPair: dKeyPair, password: password)
                            } catch {
                                self.hideActivity(completion: {
                                    self.accountInputField.detail = R.string.localizable.invalid_account_id_or_address()
                                })
                            }
                        } else {
                            //address not found
                            self.hideActivity(completion: {
                                self.accountInputField.detail = R.string.localizable.account_not_found()
                            })
                        }
                    case .failure(error: let error):
                        self.hideActivity(completion: {
                            switch error {
                            case FederationError.invalidAddress:
                                self.accountInputField.detail = R.string.localizable.invalid_account_id_or_address()
                            default:
                                self.accountInputField.detail = R.string.localizable.account_not_found()
                            }
                        })
                    }
                }
            })
        } else if accountIdOrAddress.isValidEd25519PublicKey(){
            do {
                let dKeyPair = try KeyPair(publicKey: PublicKey(accountId: accountIdOrAddress))
                self.mergeAccount(destinationKeyPair: dKeyPair, password: password)
            } catch {
                self.hideActivity(completion: {
                    self.accountInputField.detail = R.string.localizable.invalid_account_id_or_address()
                })
            }
        } else {
            self.hideActivity(completion: {
                self.accountInputField.detail = R.string.localizable.invalid_account_id_or_address()
            })
        }
    }
    
    func mergeAccount(destinationKeyPair: KeyPair, password:String ) {
        Services.shared.auth.authenticationData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let authResponse):
                   if let selectedPK = self.selectedWalletPK, let userSecurity = UserSecurity(from: authResponse), let decryptedUserData = try? UserSecurityHelper.decryptUserSecurity(userSecurity, password: password), let dc = decryptedUserData, let index = PrivateKeyManager.getIndexInMnemonic(forAccountID: selectedPK), let sourceKeyPair = try? stellarsdk.Wallet.createKeyPair(mnemonic: dc.mnemonic, passphrase: nil, index: index) {
                        self.passwordInputField.text = nil
                        self.mergeAccount(sourceKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair)
                    }
                    else {
                        self.hideActivity(completion: {
                            self.passwordInputField.detail = R.string.localizable.invalid_password()
                        })
                    }
                case .failure(let error):
                    self.hideActivity(completion: {
                        let alert = AlertFactory.createAlert(title: R.string.localizable.error(), message: error.errorDescription)
                        self.present(alert, animated: true)
                    })
                }
            }
        }
    }
    
    
    @objc
    func touchIDLogin() {
        
        guard let accountIdOrAddress = accountInputField.text, !accountIdOrAddress.isEmpty else {
            accountInputField.detail = R.string.localizable.empty_accountId_or_address()
            return
        }
        
        passwordInputField.text = nil
        _ = resignFirstResponder()
        showActivity(message: R.string.localizable.loading())

        viewModel.authenticateUser() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let password):
                    self?.mergeAccount(accountIdOrAddress:accountIdOrAddress, password:password)
                case .failure(let error):
                    self?.hideActivity(completion: {
                        let alert = AlertFactory.createAlert(title: R.string.localizable.error(), message: error.errorDescription)
                        self?.present(alert, animated: true)
                    })
                }
            }
        }
    }
}

extension MergeWalletViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submitAction(sender: submitButton)
        return true
    }
}

fileprivate extension MergeWalletViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.merge_wallet()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareTitle()
        
        if viewModel.walletsForClose.count != 0 {
            prepareTextFields()
            prepareSubmitButton()
            
            if BiometricHelper.isBiometricAuthEnabled {
                prepareTouchButton()
            }
        } else {
            noWalletLabel.text = R.string.localizable.no_wallet_for_close()
            noWalletLabel.textColor = Stylesheet.color(.red)
            noWalletLabel.font = R.font.encodeSansRegular(size: 15)
            noWalletLabel.adjustsFontSizeToFitWidth = true
            noWalletLabel.textAlignment = .center
            noWalletLabel.numberOfLines = 0
            
            view.addSubview(noWalletLabel)
            noWalletLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
                make.left.equalTo(horizontalSpacing)
                make.right.equalTo(-horizontalSpacing)
            }
        }
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.merge_wallet_hint()
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansRegular(size: 15)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    var wallets: [String] {
        return self.viewModel.walletsForClose.map {
            $0.walletName + " Wallet"
        }
    }
    
    func prepareTextFields() {
        accountInputField.placeholder = R.string.localizable.external_account_id()
        
        walletField.borderWidthPreset = .border2
        walletField.borderColor = Stylesheet.color(.gray)
        walletField.dividerNormalHeight = 1
        walletField.dividerActiveHeight = 1
        walletField.dividerNormalColor = Stylesheet.color(.gray)
        walletField.backgroundColor = .white
        walletField.textInset = horizontalSpacing
        
        selectedWalletPK = self.viewModel.walletsForClose.first?.publicKey
        walletField.setInputViewOptions(options: wallets, selectedIndex: 0) { newIndex in
            if self.viewModel.walletsForClose.count > newIndex {
                let wallet = self.viewModel.walletsForClose[newIndex]
                self.selectedWalletPK = wallet.publicKey
            }
        }
        
        passwordInputField.isSecureTextEntry = true
        passwordInputField.isVisibilityIconButtonEnabled = true
        passwordInputField.placeholder = R.string.localizable.password().uppercased()
        
        walletLabel.text = R.string.localizable.merge_close()
        walletLabel.font = R.font.encodeSansRegular(size: 13)
        walletLabel.adjustsFontSizeToFitWidth = true
        walletLabel.textColor = Stylesheet.color(.darkGray)
        
        accountLabel.text = R.string.localizable.merge_into()
        accountLabel.font = R.font.encodeSansRegular(size: 13)
        accountLabel.adjustsFontSizeToFitWidth = true
        accountLabel.textColor = Stylesheet.color(.darkGray)
        
        view.addSubview(walletLabel)
        walletLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(walletField)
        walletField.snp.makeConstraints { make in
            make.top.equalTo(walletLabel.snp.bottom).offset(5)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(accountLabel)
        accountLabel.snp.makeConstraints { make in
            make.top.equalTo(walletField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(accountInputField)
        accountInputField.snp.makeConstraints { make in
            make.top.equalTo(accountLabel.snp.bottom).offset(7)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(passwordInputField)
        passwordInputField.snp.makeConstraints { make in
            make.top.equalTo(accountInputField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.submit().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordInputField.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(38)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func showMergeSuccess() {
        
        titleLabel.text = R.string.localizable.success()
        titleLabel.textColor = Stylesheet.color(.green)
        titleLabel.font = R.font.encodeSansBold(size: 17)
        
        submitButton.isHidden = true
        accountInputField.isHidden = true
        passwordInputField.isHidden = true
        touchIDButton.isHidden = true
        walletField.isHidden = true
        accountLabel.isHidden = true
        walletLabel.isHidden = true
        
        successLabel.text = R.string.localizable.wallet_merged_and_closed()
        successLabel.textColor = Stylesheet.color(.lightBlack)
        successLabel.font = R.font.encodeSansRegular(size: 15)
        successLabel.adjustsFontSizeToFitWidth = true
        successLabel.textAlignment = .center
        successLabel.numberOfLines = 0
        
        view.addSubview(successLabel)
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        if let pk = selectedWalletPK {
            Services.shared.walletService.addWalletToRefresh(accountId: pk)
            Services.shared.walletService.removeCachedAccountDetails(accountId: pk)
        }
        viewModel.reloadWallets()
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "source_account" {
                walletField.detail = error.errorDescription
            } else if parameter == "seed" || parameter == "destination_account" {
                accountInputField.detail = error.errorDescription
            } else {
                let alert = AlertFactory.createAlert(error: error)
                self.present(alert, animated: true)
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
    
    func prepareTouchButton() {
        let image = UIImage(named: BiometricHelper.touchIcon.name)
        touchIDButton.setImage(image,  for: .normal)
        touchIDButton.addTarget(self, action: #selector(touchIDLogin), for: .touchUpInside)
        
        view.addSubview(touchIDButton)
        touchIDButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.width.height.equalTo(90)
        }
    }
    
    func mergeAccount(sourceKeyPair: KeyPair, destinationKeyPair: KeyPair) {
        viewModel.mergeAccount(sourceKeyPair:sourceKeyPair, destinationKeyPair:destinationKeyPair) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success:
                        self.showMergeSuccess()
                    case .failure(let error):
                        self.present(error: error)
                    }
                })
            }
        }
    }
}
