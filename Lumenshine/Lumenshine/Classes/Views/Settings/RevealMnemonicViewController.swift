//
//  RevealMnemonicViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/7/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class RevealMnemonicViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let textField1 = LSTextField()
    fileprivate let submitButton = RaisedButton()
    fileprivate let touchIDButton = Button()
    
    fileprivate let verticalSpacing: CGFloat = 42.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: SettingsViewModelType) {
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
        textField1.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: - Action for checking username/password
extension RevealMnemonicViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        textField1.detail = nil
        
        guard let password = textField1.text,
            !password.isEmpty else {
                textField1.detail = R.string.localizable.empty_password()
                return
        }
        
        _ = resignFirstResponder()
        showBackupMnemonic(password: password)
    }
    
    @objc
    func touchIDLogin() {
        viewModel.authenticateUser() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let password):
                    self?.showBackupMnemonic(password: password)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(title: R.string.localizable.error(), message: error)
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

fileprivate extension RevealMnemonicViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.backup_mnemonic()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareTitleLabel()
        prepareTextFields()
        prepareSubmitButton()
        
        if BiometricHelper.isBiometricAuthEnabled {
            prepareTouchButton()
        }
    }
    
    func prepareTitleLabel() {
        titleLabel.text = R.string.localizable.reveal_backup_mnemonic()
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansRegular(size: 17)
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
    
    func prepareTextFields() {
        textField1.isSecureTextEntry = true
        textField1.isVisibilityIconButtonEnabled = true
        textField1.placeholder = R.string.localizable.password().uppercased()
        
        view.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(2*horizontalSpacing)
            make.right.equalTo(-2*horizontalSpacing)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.reveal().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(38)
            make.bottom.lessThanOrEqualToSuperview()
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
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "current_password" {
                textField1.detail = error.errorDescription
            } else {
                let alert = AlertFactory.createAlert(error: error)
                self.present(alert, animated: true)
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
    
    func showBackupMnemonic(password: String) {
        showActivity()
        viewModel.showBackupMnemonic(password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success(let decryptedUserData):
                        self?.viewModel.showMnemonic(decryptedUserData.mnemonic)
                    case .failure(let error):
                        self?.present(error: error)
                    }
                })
            }
        }
    }
}

