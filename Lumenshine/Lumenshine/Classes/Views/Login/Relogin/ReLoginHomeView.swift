//
//  ReLoginHomeView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol ReLoginViewDelegate: class {
    func didTapSubmitButton(password: String, tfaCode: String?)
}

class ReLoginHomeView: UIView {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let forgotPasswordButton = LSButton()
    fileprivate let submitButton = LSButton()
    fileprivate let passwordTextField = LSTextField()
    fileprivate let tfaTextField = LSTextField()
    
    fileprivate let touchIDButton = Button()
    
    fileprivate let verticalSpacing = 25.0
    fileprivate let horizontalSpacing = 15.0
    
    weak var delegate: ReLoginViewDelegate?
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
        
        if BiometricHelper.isBiometricAuthEnabled {
            touchIDLogin()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func touchIDLogin() {
        viewModel.authenticateUser() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let password):
                    self?.delegate?.didTapSubmitButton(password: password, tfaCode: nil)
                case .failure(let error):
                    self?.passwordTextField.detail = error
                }
            }
        }
    }
    
    @objc
    func forgotPasswordAction(sender: UIButton) {
        viewModel.forgotPasswordClick()
    }
    
    @objc
    func reloginAction(sender: UIButton) {
        passwordTextField.detail = nil
        tfaTextField.detail = nil
        
        guard let password = passwordTextField.text,
            !password.isEmpty else {
                passwordTextField.detail = R.string.localizable.invalid_password()
                return
        }
        
        passwordTextField.resignFirstResponder()
        
        self.delegate?.didTapSubmitButton(password: password, tfaCode: tfaTextField.text)
    }
}

extension ReLoginHomeView: ReLoginViewProtocol {
    func present(error: ServiceError) -> Bool {
        if error.code == 1009 || error.parameterName == "tfa_code" {
            if tfaTextField.isHidden {
                tfaTextField.isHidden = false
                viewModel.remove2FASecret()
            } else {
                tfaTextField.detail = error.errorDescription
            }
        } else {
            passwordTextField.detail = error.errorDescription
        }
        return true
    }
}

extension ReLoginHomeView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reloginAction(sender: submitButton)
        return true
    }
}

fileprivate extension ReLoginHomeView {
    func prepare() {
        prepareTitle()
        prepareTextFields()
        prepareLoginButton()
        prepareForgotPasswordButton()
        
        if BiometricHelper.isBiometricAuthEnabled {
            prepareTouchButton()
        } else {
            updateBottomConstraints()
        }
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.password().uppercased()        
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareTextFields() {
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = R.string.localizable.password().uppercased()
        
        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        tfaTextField.placeholder = R.string.localizable.tfa_code().uppercased()
        tfaTextField.isHidden = true
        
        addSubview(tfaTextField)
        tfaTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.submit().uppercased()
        submitButton.setGradientLayer(color: Stylesheet.color(.green))
        submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(tfaTextField.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
        }
    }
    
    func prepareForgotPasswordButton() {
        forgotPasswordButton.title = R.string.localizable.lost_password()
        forgotPasswordButton.titleColor = Stylesheet.color(.blue)
        forgotPasswordButton.borderWidthPreset = .border1
        forgotPasswordButton.borderColor = Stylesheet.color(.blue)
        forgotPasswordButton.setGradientLayer(color: Stylesheet.color(.white))
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction(sender:)), for: .touchUpInside)
        
        addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
        }
    }
    
    func updateBottomConstraints() {
        forgotPasswordButton.snp.remakeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
    
    func prepareTouchButton() {
        let image = UIImage(named: BiometricHelper.touchIcon.name)
        touchIDButton.setImage(image,  for: .normal)
        touchIDButton.addTarget(self, action: #selector(touchIDLogin), for: .touchUpInside)
        
        addSubview(touchIDButton)
        touchIDButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
            make.width.height.equalTo(90)
        }
    }
}
