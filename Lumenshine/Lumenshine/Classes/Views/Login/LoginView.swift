//
//  LoginView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol LoginViewDelegate: class {
    func didTapSubmitButton(email: String, password: String, tfaCode: String?)
}

class LoginView: UIView {

    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let titleLabel = UILabel()
    
    // MARK: - UI properties
    fileprivate let textField1 = LSTextField()
    fileprivate let textField2 = LSTextField()
    fileprivate let textField3 = LSTextField()
    fileprivate let submitButton = LSButton()
    
    weak var delegate: LoginViewDelegate?
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignFirstResponder() -> Bool {
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

extension LoginView: LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool {
        if let parameter = error.parameterName {
            if parameter == "email" {
                textField1.detail = error.errorDescription
            } else if parameter == "password" {
                textField2.detail = error.errorDescription
            } else if parameter == "tfa_code" {
                textField3.detail = error.errorDescription
            }
            return true
        }
        return false
    }
    
    func setTFACode(_ tfaCode: String) {
        textField3.pasteText(tfaCode)
    }
}

extension LoginView {
    @objc
    func loginAction(sender: UIButton) {
        textField1.detail = nil
        textField2.detail = nil
        textField3.detail = nil
        
        // Check that text has been entered into both the username and password fields.
        guard let accountName = textField1.text,
            !accountName.isEmpty else {
                textField1.detail = R.string.localizable.invalid_email()
                return
        }
        
        guard let password = textField2.text,
            !password.isEmpty else {
                textField2.detail = R.string.localizable.invalid_password()
                return
        }
        _ = resignFirstResponder()
        //UserDefaults.standard.setValue(accountName, forKey: Keys.UserDefs.Username)
        delegate?.didTapSubmitButton(email: accountName, password: password, tfaCode: textField3.text)
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginAction(sender: submitButton)
        return true
    }
}

fileprivate extension LoginView {
    func prepare() {
        prepareTitle()
        prepareTextFields()
        prepareLoginButton()
        
        /*if let storedUsername = UserDefaults.standard.value(forKey: Keys.UserDefs.Username) as? String {
            textField1.text = storedUsername
        }*/
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.login_continue().uppercased()
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
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        
        textField1.keyboardType = .emailAddress
        textField1.autocapitalizationType = .none
        textField1.placeholder = R.string.localizable.email().uppercased()
        
        textField2.isSecureTextEntry = true
        textField2.isVisibilityIconButtonEnabled = true
        textField2.placeholder = R.string.localizable.password().uppercased()
        
        textField3.keyboardType = .numberPad
        textField3.placeholder = R.string.localizable.tfa_code_configured()
        
        self.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        self.addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
        
        self.addSubview(textField3)
        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.login().uppercased()
        submitButton.setGradientLayer(color: Stylesheet.color(.green))
        submitButton.addTarget(self, action: #selector(loginAction(sender:)), for: .touchUpInside)
        
        self.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing+10)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
}
