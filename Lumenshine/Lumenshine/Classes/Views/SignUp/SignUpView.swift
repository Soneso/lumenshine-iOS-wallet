//
//  SignUpView.swift
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

protocol SignUpViewDelegate: class {
    func didTapSubmitButton(email: String, password: String, repassword: String, forename: String, lastname: String)
}

class SignUpView: UIView {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    fileprivate let verticalSpacing: CGFloat = 31.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let passwordHintButton = Material.IconButton()
    fileprivate let titleLabel = UILabel()
    
    // MARK: - UI properties
    fileprivate let emailTextField = LSTextField()
    fileprivate let forenameTextField = LSTextField()
    fileprivate let lastnameTextField = LSTextField()
    fileprivate let passwordTextField = LSTextField()
    fileprivate let repeatPasswordTextField = LSTextField()
    fileprivate let submitButton = RaisedButton()
    fileprivate let checkButton = CheckButton()
    fileprivate let termsButton = Button()
    
    weak var delegate: SignUpViewDelegate?
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignFirstResponder() -> Bool {
        emailTextField.resignFirstResponder()
        forenameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        repeatPasswordTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    private func scrollTextFieldToVisible(textField: LSTextField) {
        if let parent = self.superview, let scrollview = parent.superview as? UIScrollView {
            scrollview.setContentOffset(CGPoint(x: 0, y: textField.frame.center.y - 35), animated: true)
        }
    }
}

extension SignUpView: LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool {
        if let parameter = error.parameterName {
            if parameter == "email" {
                emailTextField.detail = error.errorDescription
                scrollTextFieldToVisible(textField: emailTextField)
            } else if parameter == "forename" {
                forenameTextField.detail = error.errorDescription
                scrollTextFieldToVisible(textField:forenameTextField)
            } else if parameter == "lastname" {
                lastnameTextField.detail = error.errorDescription
                scrollTextFieldToVisible(textField:lastnameTextField)
            } else if parameter == "password" {
                passwordTextField.detail = error.errorDescription
                scrollTextFieldToVisible(textField:passwordTextField)
            } else if parameter == "repassword" {
                repeatPasswordTextField.detail = error.errorDescription
                scrollTextFieldToVisible(textField:passwordTextField)
            }
            return true
        }
        return false
    }
    
    func setTFACode(_ tfaCode: String) {}
}

extension SignUpView {
    @objc
    func hintAction(sender: UIButton) {
        viewModel.showPasswordHint()
    }
    
    @objc
    func signUpAction(sender: UIButton) {
        if !submitButton.isEnabled { return }
        
        emailTextField.detail = nil
        forenameTextField.detail = nil
        lastnameTextField.detail = nil
        passwordTextField.detail = nil
        repeatPasswordTextField.detail = nil
        
        guard let email = emailTextField.text,
            !email.isEmpty else {
                emailTextField.detail = R.string.localizable.email_mandatory()
                scrollTextFieldToVisible(textField: emailTextField)
                return
        }
        
        guard let forename = forenameTextField.text,
            !forename.isEmpty else {
                forenameTextField.detail = R.string.localizable.forename_mandatory()
                scrollTextFieldToVisible(textField: forenameTextField)
                return
        }
        
        guard let lastname = lastnameTextField.text,
            !lastname.isEmpty else {
                lastnameTextField.detail = R.string.localizable.lastname_mandatory()
                scrollTextFieldToVisible(textField: lastnameTextField)
                return
        }
        
        guard let password = passwordTextField.text,
            !password.isEmpty else {
                passwordTextField.detail = R.string.localizable.invalid_password()
                scrollTextFieldToVisible(textField: passwordTextField)
                return
        }
        
        guard let repassword = repeatPasswordTextField.text,
            !repassword.isEmpty else {
                repeatPasswordTextField.detail = R.string.localizable.invalid_password()
                scrollTextFieldToVisible(textField: passwordTextField)
                return
        }
        _ = resignFirstResponder()
        delegate?.didTapSubmitButton(email: email, password: password, repassword: repassword, forename: forename, lastname: lastname)
    }
    
    @objc
    func agreeAction(sender: UIButton) {
        updateSubmitButton()
    }
    
    @objc
    func termsAction(sender: UIButton) {
        viewModel.showTermsOfService()
    }
    
    @objc
    func editingDidChange(_ textField: TextField) {
        updateSubmitButton()
    }
}

extension SignUpView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signUpAction(sender: submitButton)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSubmitButton()
    }
}

fileprivate extension SignUpView {
    func prepare() {
        prepareTitle()
        prepareTextFields()
        prepareHintButton()
        prepareCheckButton()
        prepareLoginButton()
        updateSubmitButton()
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.join().uppercased()
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareTextFields() {
        emailTextField.delegate = self
        forenameTextField.delegate = self
        lastnameTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.placeholder = R.string.localizable.email().uppercased()
        emailTextField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        forenameTextField.placeholder = R.string.localizable.forename().uppercased()
        forenameTextField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        lastnameTextField.placeholder = R.string.localizable.lastname().uppercased()
        lastnameTextField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.isVisibilityIconButtonEnabled = true
        passwordTextField.placeholder = R.string.localizable.password().uppercased()
        passwordTextField.dividerContentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: -2.0*horizontalSpacing)
        passwordTextField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)

        repeatPasswordTextField.isSecureTextEntry = true
        repeatPasswordTextField.isVisibilityIconButtonEnabled = true
        repeatPasswordTextField.placeholder = R.string.localizable.repeat_password().uppercased()
        repeatPasswordTextField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        addSubview(forenameTextField)
        forenameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        addSubview(lastnameTextField)
        lastnameTextField.snp.makeConstraints { make in
            make.top.equalTo(forenameTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(forenameTextField)
            make.right.equalTo(-horizontalSpacing)
        }
        
        addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(lastnameTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(lastnameTextField)
            make.right.equalTo(-horizontalSpacing)
        }
        
        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(emailTextField)
            make.right.equalTo(-3*horizontalSpacing)
        }
        
        addSubview(repeatPasswordTextField)
        repeatPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(emailTextField)
            make.right.equalTo(emailTextField)
        }
    }
    
    func prepareHintButton() {
        let image = R.image.question()?.resize(toWidth: 20)
        passwordHintButton.image = image?.tint(with: Stylesheet.color(.gray))
        passwordHintButton.addTarget(self, action: #selector(hintAction(sender:)), for: .touchUpInside)
        
        addSubview(passwordHintButton)
        passwordHintButton.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.centerY.equalTo(passwordTextField)
            make.width.height.equalTo(44)
        }
    }
    
    func prepareCheckButton() {
        
        checkButton.title = R.string.localizable.agree_to_abide()
        checkButton.titleColor = Stylesheet.color(.lightBlack)
        checkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        checkButton.titleLabel?.font = R.font.encodeSansRegular(size: 13)
        checkButton.addTarget(self, action: #selector(agreeAction(sender:)), for: .touchUpInside)
        
        addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(repeatPasswordTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(10)
        }
        
        termsButton.title = R.string.localizable.terms_of_service().lowercased()
        termsButton.titleColor = Stylesheet.color(.blue)
        termsButton.backgroundColor = Stylesheet.color(.white)
        termsButton.titleLabel?.font = R.font.encodeSansRegular(size: 13)
        termsButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        termsButton.addTarget(self, action: #selector(termsAction(sender:)), for: .touchUpInside)
        
        addSubview(termsButton)
        termsButton.snp.makeConstraints { make in
            make.left.equalTo(checkButton.snp.right)
            make.centerY.equalTo(checkButton)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.signup().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.addTarget(self, action: #selector(signUpAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(checkButton.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
    
    func validateForm() -> Bool {
        if emailTextField.text?.isEmpty ?? true ||
            forenameTextField.text?.isEmpty ?? true ||
            lastnameTextField.text?.isEmpty ?? true ||
            passwordTextField.text?.isEmpty ?? true ||
            repeatPasswordTextField.text?.isEmpty ?? true ||
            !checkButton.isSelected {
            return false
        }
        return true
    }
    
    func updateSubmitButton() {
        if validateForm() {
            submitButton.isEnabled = true
            submitButton.backgroundColor = Stylesheet.color(.green)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = Stylesheet.color(.gray)
        }
    }
}
