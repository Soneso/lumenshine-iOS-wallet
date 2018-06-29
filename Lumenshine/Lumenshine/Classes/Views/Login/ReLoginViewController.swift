//
//  ReLoginViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ReLoginViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let loginButton = RaisedButton()
    fileprivate let forgotPasswordButton = RaisedButton()
    fileprivate let passwordTextField = TextField()
    fileprivate let touchIDButton = Button()
    fileprivate let headerBar = ToolbarHeader()
    
    init(viewModel: LoginViewModelType) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool,
            touchEnabled == true,
            viewModel.canEvaluatePolicy() {
            touchIDLogin()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func resignFirstResponder() -> Bool {
        passwordTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: - Actions
extension ReLoginViewController {
    @objc
    func changeAccountAction(sender: UIButton) {
        viewModel.showLoginForm()
    }
    
    @objc
    func reloginAction(sender: UIButton) {
        guard let password = passwordTextField.text,
            !password.isEmpty else {
                passwordTextField.detail = R.string.localizable.invalid_password()
                return
        }
        
        passwordTextField.resignFirstResponder()
        passwordTextField.text = nil
        
        viewModel.loginStep1(email: "", tfaCode: nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let login1Response):
                    self.showActivity()
                    self.viewModel.verifyLogin1Response(login1Response, password: password) { response in
                        DispatchQueue.main.async {
                            self.hideActivity(completion: {
                                switch response {
                                case .success(let login2Response):
                                    self.viewModel.verifyLogin2Response(login2Response)
                                case .failure(let error):
                                    self.present(error: error)
                                }
                            })
                        }
                    }
                case .failure(let error):
                    self.present(error: error)
                }
            }
        }
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

extension ReLoginViewController: ToolbarHeaderDelegate {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int) {
        viewModel.barItemSelected(at: index)
    }
}

fileprivate extension ReLoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareHeader()
        prepareTextFields()
        prepareLoginButton()
        prepareForgotPasswordButton()
        
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool,
            touchEnabled == true,
            viewModel.canEvaluatePolicy() {
            prepareTouchButton()
        }
    }
    
    func prepareHeader() {
        headerBar.delegate = self
        headerBar.setTitle(viewModel.headerTitle)
        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setItems(viewModel.barItems, selectedAt: 1)
        
        view.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func prepareTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = R.string.localizable.password()
        passwordTextField.detailColor = Stylesheet.color(.red)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(40)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
    }
    
    func prepareLoginButton() {
        loginButton.title = R.string.localizable.submit()
        loginButton.backgroundColor = Stylesheet.color(.cyan)
        loginButton.titleColor = Stylesheet.color(.white)
        loginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        loginButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
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
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
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
        
        view.addSubview(touchIDButton)
        touchIDButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
    }
    
    func present(error: ServiceError) {
        passwordTextField.detail = error.errorDescription
    }
}

