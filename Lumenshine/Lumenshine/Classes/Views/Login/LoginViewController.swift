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
    fileprivate let touchIDButton = Button()
    fileprivate let signUpButton = RaisedButton()
    fileprivate let forgotPasswordButton = RaisedButton()
    fileprivate let forgot2faButton = RaisedButton()
    
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
                let alert = AlertFactory.createAlert(title: R.string.localizable.sign_in_error_msg(),
                                         message: R.string.localizable.bad_credentials())
                present(alert, animated: true)
                return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        tfaCodeTextField.resignFirstResponder()
        
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
        passwordTextField.text = nil
        tfaCodeTextField.text = nil
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
    func forgot2faAction(sender: UIButton) {
        viewModel.lost2faClick()
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if let email = usernameTextField.text,
//            !email.isEmpty {
//            tfaCodeTextField.isHidden = viewModel.enableTfaCode(email: email)
//        }
    }
}

fileprivate extension LoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareContentView()
        prepareTextFields()
        prepareLoginButton()
        prepareSignupButton()
        prepareForgotPasswordButton()
        prepareForgot2faButton()
        prepareTouchButton()
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
    
    func prepareTextFields() {
        usernameTextField.placeholder = R.string.localizable.username()
        passwordTextField.placeholder = R.string.localizable.password()
        tfaCodeTextField.placeholder = R.string.localizable.tfa_code()
        
        passwordTextField.isSecureTextEntry = true
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
        usernameTextField.delegate = self
        
        usernameTextField.dividerActiveColor = Stylesheet.color(.cyan)
        usernameTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.dividerActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        
        let spacing = 40
        
        contentView.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
        
        contentView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(spacing)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
        }
        
        contentView.addSubview(tfaCodeTextField)
        tfaCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(spacing)
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
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(30)
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
        
        contentView.addSubview(signUpButton)
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
        
        contentView.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
        }
    }
    
    func prepareForgot2faButton() {
        forgot2faButton.title = R.string.localizable.lost_2fa()
        forgot2faButton.backgroundColor = Stylesheet.color(.cyan)
        forgot2faButton.titleColor = Stylesheet.color(.white)
        forgot2faButton.addTarget(self, action: #selector(forgot2faAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(forgot2faButton)
        forgot2faButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(20)
            make.left.equalTo(usernameTextField)
            make.right.equalTo(usernameTextField)
            make.height.equalTo(50)
            make.bottom.equalTo(-20)
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
}

