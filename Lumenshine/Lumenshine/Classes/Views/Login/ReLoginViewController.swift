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
    fileprivate let accountButton = RaisedButton()
    fileprivate let usernameTextField = TextField()
    fileprivate let passwordTextField = TextField()
    
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
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: - Actions
extension ReLoginViewController {
    @objc
    func changeAccountAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func reloginAction(sender: UIButton) {
        guard let accountName = usernameTextField.text,
            let password = passwordTextField.text,
            !accountName.isEmpty,
            !password.isEmpty else {
                let alert = AlertFactory.createAlert(title: R.string.localizable.sign_in_error_msg(),
                                                     message: R.string.localizable.bad_credentials())
                present(alert, animated: true)
                return
        }
        
        passwordTextField.resignFirstResponder()
        passwordTextField.text = nil
        
        viewModel.loginStep1(email: accountName, tfaCode: nil) { result in
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
                                    let alert = AlertFactory.createAlert(error: error)
                                    self.present(alert, animated: true)
                                }
                            })
                        }
                    }
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

fileprivate extension ReLoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareTextFields()
        prepareLoginButton()
        prepareAccountButton()
    }
    
    func prepareTextFields() {
        usernameTextField.placeholder = R.string.localizable.username()
        passwordTextField.placeholder = R.string.localizable.password()
        
        passwordTextField.isSecureTextEntry = true
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
        usernameTextField.isEnabled = false
        
        usernameTextField.dividerActiveColor = Stylesheet.color(.cyan)
        usernameTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        view.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
        
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(40)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
        }
    }
    
    func prepareLoginButton() {
        loginButton.title = R.string.localizable.login()
        loginButton.backgroundColor = Stylesheet.color(.cyan)
        loginButton.titleColor = Stylesheet.color(.white)
        loginButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
    }
    
    func prepareAccountButton() {
        accountButton.title = R.string.localizable.account_different()
        accountButton.backgroundColor = Stylesheet.color(.cyan)
        accountButton.titleColor = Stylesheet.color(.white)
        accountButton.addTarget(self, action: #selector(changeAccountAction(sender:)), for: .touchUpInside)
        
        view.addSubview(accountButton)
        accountButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
    }
}

