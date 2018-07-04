//
//  ReLoginHomeView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol ReLoginViewProtocol {
    
    var passwordTextField: TextField { get }
    var submitButton: RaisedButton { get }
}

class ReLoginHomeView: UIView, ReLoginViewProtocol {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let forgotPasswordButton = RaisedButton()
    fileprivate let touchIDButton = Button()
    
    var submitButton = RaisedButton()
    var passwordTextField = TextField()
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
        
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool,
            touchEnabled == true,
            viewModel.canEvaluatePolicy() {
            touchIDLogin()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func touchIDLogin() {
        viewModel.authenticateUser() { [weak self] error in
            if error == nil {
                self?.viewModel.loginCompleted()
            }
        }
    }
    
    @objc
    func forgotPasswordAction(sender: UIButton) {
        viewModel.forgotPasswordClick()
    }
    
}

fileprivate extension ReLoginHomeView {
    func prepare() {
        prepareTextFields()
        prepareLoginButton()
        prepareForgotPasswordButton()
        
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool,
            touchEnabled == true,
            viewModel.canEvaluatePolicy() {
            prepareTouchButton()
        }
    }
    
    func prepareTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = R.string.localizable.password()
        passwordTextField.detailColor = Stylesheet.color(.red)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.submit()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(44)
        }
    }
    
    func prepareForgotPasswordButton() {
        forgotPasswordButton.title = R.string.localizable.lost_password()
        forgotPasswordButton.backgroundColor = Stylesheet.color(.cyan)
        forgotPasswordButton.titleColor = Stylesheet.color(.white)
        forgotPasswordButton.titleLabel?.adjustsFontSizeToFitWidth = true
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction(sender:)), for: .touchUpInside)
        
        addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(44)
        }
    }
    
    func prepareTouchButton() {
        switch viewModel.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
        }
        touchIDButton.addTarget(self, action: #selector(touchIDLogin), for: .touchUpInside)
        
        addSubview(touchIDButton)
        touchIDButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(forgotPasswordButton.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
    }
}
