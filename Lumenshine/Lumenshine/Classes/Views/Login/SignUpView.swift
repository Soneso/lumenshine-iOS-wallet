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
    fileprivate let detailLabel = UILabel()
    
    // MARK: - UI properties
    fileprivate let textField1 = LSTextField()
    fileprivate let textField2 = LSTextField()
    fileprivate let textField3 = LSTextField()
    fileprivate let submitButton = RaisedButton()
    
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
}

extension SignUpView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signUpAction(sender: submitButton)
        return true
    }
}

fileprivate extension SignUpView {
    func prepare() {
        prepareTitle()
        prepareDetail()
        prepareTextFields()
        prepareLoginButton()
        prepareHintButton()
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.signup().uppercased()
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareDetail() {
        detailLabel.text = R.string.localizable.login_fill()
        detailLabel.textColor = Stylesheet.color(.lightBlack)
        detailLabel.font = R.font.encodeSansRegular(size: 12)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
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
        textField2.dividerContentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: -2.0*horizontalSpacing)

        textField3.isSecureTextEntry = true
        textField3.isVisibilityIconButtonEnabled = true
        textField3.placeholder = R.string.localizable.repeat_password().uppercased()
        
        addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(15)
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
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.register().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.addTarget(self, action: #selector(signUpAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing+10)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
}


