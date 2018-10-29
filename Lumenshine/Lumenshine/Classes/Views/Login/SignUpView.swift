//
//  SignUpView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/9/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol SignUpViewDelegate: class {
    func didTapSubmitButton(email: String, password: String, repassword: String)
}

class SignUpView: UIView {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    fileprivate let verticalSpacing: CGFloat = 31.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let passwordHintButton = Material.IconButton()
    fileprivate let titleLabel = UILabel()
    //fileprivate let detailLabel = UILabel()
    
    // MARK: - UI properties
    fileprivate let textField1 = LSTextField()
    fileprivate let textField2 = LSTextField()
    fileprivate let textField3 = LSTextField()
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
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

extension SignUpView: LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool {
        if let parameter = error.parameterName {
            if parameter == "email" {
                textField1.detail = error.errorDescription
            } else if parameter == "password" {
                textField2.detail = error.errorDescription
            } else if parameter == "repassword" {
                textField3.detail = error.errorDescription
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
        
        textField1.detail = nil
        textField2.detail = nil
        textField3.detail = nil
        
        guard let email = textField1.text,
            !email.isEmpty else {
                textField1.detail = R.string.localizable.invalid_email()
                return
        }
        
        guard let password = textField2.text,
            !password.isEmpty else {
                textField2.detail = R.string.localizable.invalid_password()
                return
        }
        
        guard let repassword = textField3.text,
            !repassword.isEmpty else {
                textField3.detail = R.string.localizable.invalid_password()
                return
        }
        _ = resignFirstResponder()
        delegate?.didTapSubmitButton(email: email, password: password, repassword: repassword)
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
        //prepareDetail()
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
    
    /*func prepareDetail() {
        detailLabel.text = R.string.localizable.login_fill()
        detailLabel.textColor = Stylesheet.color(.lightBlack)
        detailLabel.font = R.font.encodeSansRegular(size: 13)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }*/
    
    func prepareTextFields() {
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        
        textField1.keyboardType = .emailAddress
        textField1.autocapitalizationType = .none
        textField1.placeholder = R.string.localizable.email().uppercased()
        textField1.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        textField2.isSecureTextEntry = true
        textField2.isVisibilityIconButtonEnabled = true
        textField2.placeholder = R.string.localizable.password().uppercased()
        textField2.dividerContentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: -2.0*horizontalSpacing)
        textField2.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)

        textField3.isSecureTextEntry = true
        textField3.isVisibilityIconButtonEnabled = true
        textField3.placeholder = R.string.localizable.repeat_password().uppercased()
        textField3.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        
        addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(-3*horizontalSpacing)
        }
        
        addSubview(textField3)
        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
    }
    
    func prepareHintButton() {
        let image = R.image.question()?.resize(toWidth: 20)
        passwordHintButton.image = image?.tint(with: Stylesheet.color(.gray))
//        passwordHintButton.shapePreset = .circle
        passwordHintButton.addTarget(self, action: #selector(hintAction(sender:)), for: .touchUpInside)
        
        addSubview(passwordHintButton)
        passwordHintButton.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.centerY.equalTo(textField2)
            make.width.height.equalTo(44)
        }
    }
    
    func prepareCheckButton() {
        
        checkButton.title = R.string.localizable.agree_to_abide()
//        checkButton.checkmarkColor = Stylesheet.color(.blue)
        checkButton.titleColor = Stylesheet.color(.lightBlack)
        checkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        checkButton.titleLabel?.font = R.font.encodeSansRegular(size: 13)
        checkButton.addTarget(self, action: #selector(agreeAction(sender:)), for: .touchUpInside)
        
        addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(10)
//            make.width.height.equalTo(40)
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
//            make.right.equalToSuperview()
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
        if textField1.text?.isEmpty ?? true ||
            textField2.text?.isEmpty ?? true ||
            textField3.text?.isEmpty ?? true ||
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


