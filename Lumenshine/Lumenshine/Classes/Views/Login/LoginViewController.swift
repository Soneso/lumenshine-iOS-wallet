//
//  LoginViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let contentView = UIView()
    fileprivate let scrollView = UIScrollView()
    fileprivate let loginButton = RaisedButton()
    fileprivate let usernameTextField = TextField()
    fileprivate let passwordTextField = TextField()
    fileprivate let tfaCodeTextField = TextField()
    fileprivate let headerBar = ToolbarHeader()
    fileprivate let verticalSpacing = 40.0
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        if UIPasteboard.general.hasStrings {
            if let tfaCode = UIPasteboard.general.string,
                tfaCode.count == 6,
                CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: tfaCode)) {
                tfaCodeTextField.text = tfaCode
            }
        }
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
    
    override func resignFirstResponder() -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        tfaCodeTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }

}

// MARK: - Action for checking username/password
extension LoginViewController {
    @objc
    func loginAction(sender: UIButton) {
        usernameTextField.detail = nil
        passwordTextField.detail = nil
        tfaCodeTextField.detail = nil
        
        // Check that text has been entered into both the username and password fields.
        guard let accountName = usernameTextField.text,
            !accountName.isEmpty else {
                usernameTextField.detail = R.string.localizable.invalid_email()
                return
        }
        
        guard let password = passwordTextField.text,
            !password.isEmpty else {
                passwordTextField.detail = R.string.localizable.invalid_password()
                return
        }
        
        _ = resignFirstResponder()
        UserDefaults.standard.setValue(accountName, forKey: "username")
        
        viewModel.loginStep1(email: accountName, tfaCode: tfaCodeTextField.text) { result in
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
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

extension LoginViewController: ToolbarHeaderDelegate {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int) {
        viewModel.barItemSelected(at: index)
    }
}

extension LoginViewController: HeaderMenuDelegate {
    func menuSelected(at index: Int) {
        
    }
}

fileprivate extension LoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareContentView()
        prepareHeader()
        prepareTextFields()
        prepareLoginButton()
    }
    
    func prepareContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(view)
        }
    }
    
    func prepareHeader() {
        headerBar.delegate = self
        headerBar.setTitle(viewModel.headerTitle)
        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setItems(viewModel.barItems)
        
        contentView.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func prepareTextFields() {
        passwordTextField.isSecureTextEntry = true
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
//        usernameTextField.delegate = self
        
        usernameTextField.placeholder = R.string.localizable.username()
        usernameTextField.placeholderAnimation = .hidden
        usernameTextField.detailColor = Stylesheet.color(.red)
        usernameTextField.dividerActiveColor = Stylesheet.color(.cyan)
        usernameTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        passwordTextField.placeholder = R.string.localizable.password()
        passwordTextField.placeholderAnimation = .hidden
        passwordTextField.detailColor = Stylesheet.color(.red)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        tfaCodeTextField.placeholder = R.string.localizable.tfa_code()
        tfaCodeTextField.placeholderAnimation = .hidden
        tfaCodeTextField.detailColor = Stylesheet.color(.red)
        tfaCodeTextField.dividerActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        contentView.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
        
        contentView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
        }
        
        contentView.addSubview(tfaCodeTextField)
        tfaCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
        }
    }
    
    func prepareLoginButton() {
        loginButton.title = R.string.localizable.login()
        loginButton.backgroundColor = Stylesheet.color(.cyan)
        loginButton.titleColor = Stylesheet.color(.white)
        loginButton.addTarget(self, action: #selector(loginAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.height.equalTo(50)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "email" {
                usernameTextField.detail = error.errorDescription
            } else if parameter == "password" {
                passwordTextField.detail = error.errorDescription
            } else if parameter == "tfa_code" {
                tfaCodeTextField.detail = error.errorDescription
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
}

