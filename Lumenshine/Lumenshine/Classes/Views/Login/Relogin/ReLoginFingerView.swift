//
//  ReLoginFingerView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ReLoginFingerView: UIView {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let hintLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    fileprivate let submitButton = RaisedButton()
    fileprivate let passwordTextField = TextField()
    
    weak var delegate: ReLoginViewDelegate?
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReLoginFingerView: ReLoginViewProtocol {
    func present(error: ServiceError) -> Bool {
        passwordTextField.detail = error.errorDescription
        return true
    }
}

extension ReLoginFingerView {
    @objc
    func submitAction(sender: UIButton) {
        guard let password = passwordTextField.text,
            !password.isEmpty else {
                passwordTextField.detail = R.string.localizable.invalid_password()
                return
        }
        
        passwordTextField.resignFirstResponder()
        passwordTextField.text = nil
        
        self.delegate?.didTapSubmitButton(password: password, tfaCode: nil)
    }
}

extension ReLoginFingerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitAction(sender: submitButton)
        return true
    }
}

fileprivate extension ReLoginFingerView {
    func prepare() {
        prepareHintLabel()
        prepareTitle()
        prepareTextFields()
        prepareLoginButton()
    }
    
    func prepareHintLabel() {
        hintLabel.text = viewModel.hintText
        hintLabel.textColor = Stylesheet.color(.lightBlack)
        hintLabel.font = R.font.encodeSansRegular(size: 13)
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .left
        hintLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.password().uppercased()
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansRegular(size: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareTextFields() {
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = R.string.localizable.password().uppercased()
        passwordTextField.placeholderAnimation = .hidden
        passwordTextField.font = R.font.encodeSansRegular(size: 15)
        passwordTextField.detailColor = Stylesheet.color(.red)
        passwordTextField.detailLabel.font = R.font.encodeSansRegular(size: 12)
        passwordTextField.dividerActiveColor = Stylesheet.color(.gray)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.gray)
        
        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.submit().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.titleLabel?.font = R.font.encodeSansRegular(size: 16)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
        }
    }
}

