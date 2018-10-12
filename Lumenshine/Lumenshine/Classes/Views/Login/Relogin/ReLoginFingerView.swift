//
//  ReLoginFingerView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol ReLoginFingerViewDelegate: class {
    func didTapActivateButton(password: String, tfaCode: String?)
}

class ReLoginFingerView: UIView {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let hintLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    fileprivate let submitButton = LSButton()
    fileprivate let passwordTextField = LSTextField()
    
    fileprivate let verticalSpacing = 25.0
    fileprivate let horizontalSpacing = 15.0
    
    weak var delegate: ReLoginFingerViewDelegate?
    
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
    
    func setTFACode(_ tfaCode: String) {}
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
        
        self.delegate?.didTapActivateButton(password: password, tfaCode: nil)
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
        hintLabel.font = R.font.encodeSansRegular(size: 14)
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .left
        hintLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
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
            make.top.equalTo(hintLabel.snp.bottom).offset(verticalSpacing)
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
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.activate().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
}

