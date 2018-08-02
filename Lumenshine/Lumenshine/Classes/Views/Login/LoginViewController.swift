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
    fileprivate let headerBar = ToolbarHeader()
    
    fileprivate var contentView: LoginViewProtocol
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        self.contentView = LoginView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        showLogin()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        if UIPasteboard.general.hasStrings {
            if let tfaCode = UIPasteboard.general.string,
                tfaCode.count == 6,
                CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: tfaCode)) {
                contentView.textField3.text = tfaCode
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setupContentView(_ contentView: LoginViewProtocol) {
        if let content = contentView as? UIView {
            let animation = CATransition()
            animation.duration = 0.3
            animation.type = kCATransitionMoveIn
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            content.layer.add(animation, forKey: kCATransitionMoveIn)
            
            (self.contentView as! UIView).removeFromSuperview()
            view.addSubview(content)
            content.snp.makeConstraints { make in
                make.top.equalTo(headerBar.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            }
            
            self.contentView = contentView
            
            contentView.textField1.delegate = self
            contentView.textField2.delegate = self
            contentView.textField3.delegate = self
        }
    }

    func showLogin() {
        let contentView = LoginView()
        setupContentView(contentView)
        prepareLoginButton()
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            contentView.textField1.text = storedUsername
        }
        headerBar.selectItem(at: 0)
    }
    
    func showSignUp() {
        let contentView = SignUpView(viewModel: viewModel)
        setupContentView(contentView)
        prepareSignUpButton()
        headerBar.selectItem(at: 1)
    }
    
}

// MARK: - Action for checking username/password
extension LoginViewController {
    @objc
    func loginAction(sender: UIButton) {
        contentView.textField1.detail = nil
        contentView.textField2.detail = nil
        contentView.textField3.detail = nil
        
        // Check that text has been entered into both the username and password fields.
        guard let accountName = contentView.textField1.text,
            !accountName.isEmpty else {
                contentView.textField1.detail = R.string.localizable.invalid_email()
                return
        }
        
        guard let password = contentView.textField2.text,
            !password.isEmpty else {
                contentView.textField2.detail = R.string.localizable.invalid_password()
                return
        }
        
        _ = resignFirstResponder()
        UserDefaults.standard.setValue(accountName, forKey: "username")
        
        showActivity()
        viewModel.loginStep1(email: accountName, password: password, tfaCode: contentView.textField3.text) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success: break
                    case .failure(let error):
                        self.present(error: error)
                    }
                })
            }
        }
    }
    
    @objc
    func signUpAction(sender: UIButton) {
        contentView.textField1.detail = nil
        contentView.textField2.detail = nil
        contentView.textField3.detail = nil
        
        guard let email = contentView.textField1.text,
            !email.isEmpty else {
                contentView.textField1.detail = R.string.localizable.invalid_email()
                return
        }
        
        guard let password = contentView.textField2.text,
            !password.isEmpty else {
                contentView.textField2.detail = R.string.localizable.invalid_password()
                return
        }
        
        guard let repassword = contentView.textField3.text,
            !repassword.isEmpty else {
                contentView.textField3.detail = R.string.localizable.invalid_password()
                return
        }
        
        _ = resignFirstResponder()
        showActivity()
        viewModel.signUp(email: email, password: password, repassword: repassword) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success: break
                    case .failure(let error):
                        self.present(error: error)
                    }
                })
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let actions = contentView.submitButton.actions(forTarget: self, forControlEvent: .touchUpInside)
        if actions?.first == "loginActionWithSender:" {
            loginAction(sender: contentView.submitButton)
        } else {
            signUpAction(sender: contentView.submitButton)
        }
        return true
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
        prepareHeader()
        prepareLoginButton()
    }
    
    func prepareHeader() {
        headerBar.delegate = self
        headerBar.setTitle(viewModel.headerTitle)
        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setItems(viewModel.barItems)
        
        view.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func prepareLoginButton() {
        contentView.submitButton.addTarget(self, action: #selector(loginAction(sender:)), for: .touchUpInside)
    }
    
    func prepareSignUpButton() {
        contentView.submitButton.addTarget(self, action: #selector(signUpAction(sender:)), for: .touchUpInside)
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "email" {
                contentView.textField1.detail = error.errorDescription
            } else if parameter == "password" {
                contentView.textField2.detail = error.errorDescription
            } else if parameter == "tfa_code" || parameter == "repassword" {
                contentView.textField3.detail = error.errorDescription
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
}

