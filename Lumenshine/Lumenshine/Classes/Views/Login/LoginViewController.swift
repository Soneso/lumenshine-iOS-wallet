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
    fileprivate let loginButton = RaisedButton()
    fileprivate let usernameTextField = TextField()
    fileprivate let passwordTextField = TextField()
    fileprivate let tfaCodeTextField = TextField()
    fileprivate let touchIDButton = Button()
    fileprivate let signUpButton = RaisedButton()
    fileprivate let forgotPasswordButton = RaisedButton()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let touchBool = viewModel.canEvaluatePolicy()
//        if touchBool {
//            self.touchIDLoginAction()
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}

// MARK: - Action for checking username/password
extension LoginViewController {
    @objc
    func loginAction(sender: UIButton) {
        // Check that text has been entered into both the username and password fields.
        guard let accountName = usernameTextField.text,
            let password = passwordTextField.text,
            !accountName.isEmpty,
            !password.isEmpty else {
                showLoginFailedAlert()
                return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        tfaCodeTextField.resignFirstResponder()
        
        UserDefaults.standard.setValue(accountName, forKey: "username")
        passwordTextField.text = nil
        
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
    
    @objc
    func signupAction(sender: UIButton) {
        viewModel.signUpClick()
    }
    
    @objc
    func forgotPasswordAction(sender: UIButton) {
        viewModel.forgotPasswordClick()
    }
    
    @objc
    func touchIDLoginAction() {
        viewModel.authenticateUser() { [weak self] error in
            if let message = error {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
                
            } else {
                self?.viewModel.loginCompleted()
            }
        }
    }
}

fileprivate extension LoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareTextFields()
        prepareLoginButton()
        prepareSignupButton()
        prepareForgotPasswordButton()
        prepareTouchButton()
    }
    
    func prepareTextFields() {
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        usernameTextField.placeholder = R.string.localizable.username()
        passwordTextField.placeholder = R.string.localizable.password()
        tfaCodeTextField.placeholder = R.string.localizable.tfa_code()
        
        passwordTextField.isSecureTextEntry = true
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
        
        usernameTextField.dividerActiveColor = Stylesheet.color(.cyan)
        usernameTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.dividerActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
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
        
        view.addSubview(tfaCodeTextField)
        tfaCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
        }
    }
    
    func prepareLoginButton() {
        loginButton.title = R.string.localizable.login()
        loginButton.backgroundColor = Stylesheet.color(.cyan)
        loginButton.titleColor = Stylesheet.color(.white)
        loginButton.addTarget(self, action: #selector(loginAction(sender:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(40)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
    }
    
    func prepareSignupButton() {
        signUpButton.title = R.string.localizable.signup()
        signUpButton.backgroundColor = Stylesheet.color(.cyan)
        signUpButton.titleColor = Stylesheet.color(.white)
        signUpButton.addTarget(self, action: #selector(signupAction(sender:)), for: .touchUpInside)
        
        view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
    }
    
    func prepareForgotPasswordButton() {
        forgotPasswordButton.title = R.string.localizable.forgot_password()
        forgotPasswordButton.backgroundColor = Stylesheet.color(.cyan)
        forgotPasswordButton.titleColor = Stylesheet.color(.white)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction(sender:)), for: .touchUpInside)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
    }
    
    func prepareTouchButton() {
        touchIDButton.isHidden = true//!viewModel.canEvaluatePolicy()
        
        switch viewModel.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
        }
        touchIDButton.addTarget(self, action: #selector(touchIDLoginAction), for: .touchUpInside)
    }
    
    func showLoginFailedAlert() {
        let alertView = UIAlertController(title: R.string.localizable.sign_in_error_msg(),
                                          message: R.string.localizable.bad_credentials(),
                                          preferredStyle:. alert)
        let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
}

