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
    fileprivate let forgotPasswordButton = RaisedButton()
    fileprivate let touchIDButton = Button()
    fileprivate let submitButton = RaisedButton()
    fileprivate let passwordTextField = LSTextField()
    fileprivate let tfaTextField = LSTextField()
    
    weak var delegate: ReLoginViewDelegate?
    
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
        if let code = error.code,
            code == 1000 {
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
        
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool,
            touchEnabled == true,
            viewModel.canEvaluatePolicy() {
            prepareTouchButton()
        } else {
            updateBottomConstraints()
        }
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.password().uppercased()
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansRegular(size: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareTextFields() {
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = R.string.localizable.password().uppercased()
        
        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        tfaTextField.placeholder = R.string.localizable.lbl_tfa_code().uppercased()
        tfaTextField.isHidden = true
        
        addSubview(tfaTextField)
        tfaTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
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
        submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(tfaTextField.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
    }
    
    func prepareForgotPasswordButton() {
        forgotPasswordButton.title = R.string.localizable.lost_password()
        forgotPasswordButton.backgroundColor = Stylesheet.color(.clear)
        forgotPasswordButton.titleColor = Stylesheet.color(.blue)
        forgotPasswordButton.cornerRadiusPreset = .cornerRadius6
        forgotPasswordButton.borderWidthPreset = .border1
        forgotPasswordButton.borderColor = Stylesheet.color(.blue)
        forgotPasswordButton.titleLabel?.font = R.font.encodeSansRegular(size: 16)
        forgotPasswordButton.titleLabel?.adjustsFontSizeToFitWidth = true
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction(sender:)), for: .touchUpInside)
        
        setGradientBackground(view: forgotPasswordButton)
        forgotPasswordButton.clipsToBounds = true
        
        addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
    }
    
    func updateBottomConstraints() {
        forgotPasswordButton.snp.remakeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
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
    
    func setGradientBackground(view: UIView) {
        let colorTop = Stylesheet.color(.white).cgColor
        let colorBottom = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: 160, height: 40))
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
