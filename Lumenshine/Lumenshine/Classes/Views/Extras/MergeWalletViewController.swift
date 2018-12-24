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

class MergeWalletViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ExtrasViewModelType
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let accountInputField = LSTextField()
    fileprivate let walletField = LSTextField()
    fileprivate let passwordInputField = LSTextField()
    
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
        
        
        guard let seed = accountInputField.text, !seed.isEmpty else {
            accountInputField.detail = R.string.localizable.empty_accountId_or_address()
            return
        }
        
        
        passwordInputField.text = nil
        _ = resignFirstResponder()
        
        mergeAccount(password: password, walletPK: "TODO", externalAccountID: "TODO")
    }
    
    @objc
    func touchIDLogin() {
        viewModel.authenticateUser() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let password):
                    self?.mergeAccount(password: password, walletPK: "TODO", externalAccountID: "TODO")
                case .failure(let error):
                    let alert = AlertFactory.createAlert(title: R.string.localizable.error(), message: error.errorDescription)
                    self?.present(alert, animated: true)
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
        prepareTextFields()
        prepareSubmitButton()
        
        if BiometricHelper.isBiometricAuthEnabled {
            prepareTouchButton()
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
        return self.viewModel.sortedWallets.map {
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
        walletField.setInputViewOptions(options: wallets, selectedIndex: 0) { newIndex in
            //self.viewModel.walletIndex = newIndex
        }
        
        passwordInputField.isSecureTextEntry = true
        passwordInputField.isVisibilityIconButtonEnabled = true
        passwordInputField.placeholder = R.string.localizable.password().uppercased()
        
        
        let walletLabel = UILabel()
        walletLabel.text = R.string.localizable.merge_close()
        walletLabel.font = R.font.encodeSansRegular(size: 13)
        walletLabel.adjustsFontSizeToFitWidth = true
        walletLabel.textColor = Stylesheet.color(.darkGray)
        
        let accountLabel = UILabel()
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
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "current_password" || parameter == "sep10_transaction" {
                passwordInputField.detail = error.errorDescription
            } else {
                let alert = AlertFactory.createAlert(error: error)
                self.present(alert, animated: true)
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
    
    func showMergeSuccess() {
        //viewModel.showConfirm2faSecret(tfaResponse: tfaSecretResponse)
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
    
    func mergeAccount(password: String, walletPK:String, externalAccountID:String) {
        showActivity(message: R.string.localizable.loading())
        viewModel.mergeWallet(password: password, walletPK: walletPK, externalAccountID: externalAccountID) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success:
                        self.showMergeSuccess()
                    case .failure(let error):
                        self.present(error: error)
                        // TODO show error to user!
                    }
                })
            }
        }
    }
}
