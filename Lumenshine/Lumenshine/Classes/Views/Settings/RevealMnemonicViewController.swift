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
    fileprivate let textField1 = TextField()
    fileprivate let submitButton = RaisedButton()
    
    fileprivate let verticalSpacing = 40.0
    
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
        
        showActivity()
        viewModel.showBackupMnemonic(password: password) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success(let decryptedUserData):
                        self.revealMnemonic(decryptedUserData.mnemonic)
                    case .failure(let error):
                        self.present(error: error)
                    }
                })
            }
        }
    }
}

fileprivate extension RevealMnemonicViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.backup_mnemonic()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        prepareTitleLabel()
        prepareTextFields()
        prepareSubmitButton()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = R.string.localizable.reveal_backup_mnemonic()
        titleLabel.font = Stylesheet.font(.subhead)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Stylesheet.color(.black)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareTextFields() {
        textField1.isSecureTextEntry = true
        textField1.placeholder = R.string.localizable.password()
        textField1.placeholderAnimation = .hidden
        textField1.detailColor = Stylesheet.color(.red)
        textField1.dividerActiveColor = Stylesheet.color(.cyan)
        textField1.placeholderActiveColor = Stylesheet.color(.cyan)
        textField1.isVisibilityIconButtonEnabled = true
        
        view.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.reveal()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview()
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
    
    func revealMnemonic(_ mnemonic: String) {
        viewModel.showMnemonic(mnemonic)
    }
}



