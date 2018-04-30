//
//  LoginViewController.swift
//  Stellargate
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
    fileprivate let touchIDButton = Button()
    fileprivate let signUpButton = RaisedButton()
    
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
        guard let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty,
            !newPassword.isEmpty else {
                showLoginFailedAlert()
                return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if viewModel.checkLogin(username: newAccountName, password: newPassword) {
            viewModel.loginCompleted()
            passwordTextField.text = nil
        } else {
            showLoginFailedAlert()
        }
    }
    
    @objc
    func signupAction(sender: UIButton) {
        viewModel.signUpClick()
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
        prepareTouchButton()
    }
    
    func prepareTextFields() {
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        usernameTextField.placeholder = R.string.localizable.username()
        passwordTextField.placeholder = R.string.localizable.password()
        passwordTextField.isSecureTextEntry = true
        
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
        loginButton.addTarget(self, action: #selector(loginAction(sender:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
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

