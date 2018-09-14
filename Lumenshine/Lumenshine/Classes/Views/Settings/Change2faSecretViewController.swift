//
//  Change2faSecretViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/31/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class Change2faSecretViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let textField1 = TextField()
    fileprivate let submitButton = RaisedButton()
    
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
extension Change2faSecretViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        textField1.detail = nil
        
        guard let password = textField1.text,
            !password.isEmpty else {
                textField1.detail = R.string.localizable.empty_password()
                return
        }
        
        textField1.text = nil
        _ = resignFirstResponder()
        
        showActivity()
        viewModel.change2faSecret(password: password) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success(let tfaSecretResponse):
                        self.show2faSecret(tfaSecretResponse)
                    case .failure(let error):
                        self.present(error: error)
                    }
                })
            }
        }
    }
}

extension Change2faSecretViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submitAction(sender: submitButton)
        return true
    }
}

fileprivate extension Change2faSecretViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.change_2fa()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareTitle()
        prepareTextFields()
        prepareSubmitButton()
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.change_2fa_hint()
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansSemiBold(size: 12)
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
        textField1.placeholderAnimation = .hidden
        textField1.placeholderActiveColor = Stylesheet.color(.lightBlack)
        textField1.placeholderNormalColor = Stylesheet.color(.lightBlack)
        textField1.font = R.font.encodeSansSemiBold(size: 12)
        textField1.textColor = Stylesheet.color(.lightBlack)
        textField1.detailColor = Stylesheet.color(.red)
        textField1.detailLabel.font = R.font.encodeSansRegular(size: 11)
        textField1.detailVerticalOffset = 0
        textField1.dividerActiveColor = Stylesheet.color(.gray)
        
        view.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.next().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(38)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "current_password" || parameter == "public_key_188" {
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
    
    func show2faSecret(_ tfaSecretResponse: RegistrationResponse) {
        viewModel.showConfirm2faSecret(tfaResponse: tfaSecretResponse)
    }
}


