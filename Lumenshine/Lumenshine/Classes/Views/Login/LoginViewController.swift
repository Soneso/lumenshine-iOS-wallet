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
    fileprivate let headerBar = UIView()
    
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
    
//    @objc
//    func signupAction(sender: UIButton) {
//        viewModel.signUpClick()
//    }
//
//    @objc
//    func forgotPasswordAction(sender: UIButton) {
//        viewModel.forgotPasswordClick()
//    }
//    
//    @objc
//    func forgot2faAction(sender: UIButton) {
//        viewModel.lost2faClick()
//    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

extension LoginViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
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
        
        headerBar.backgroundColor = Stylesheet.color(.cyan)
        
        contentView.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = "Lumenshine"
        label.font = UIFont.systemFont(ofSize: 25.0)
        label.textColor = Stylesheet.color(.orange)
        label.textAlignment = .center
        label.sizeToFit()
        
        headerBar.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let label2 = UILabel()
        label2.text = "Welcome"
        label2.font = UIFont.systemFont(ofSize: 18.0)
        label2.textColor = Stylesheet.color(.white)
        label2.textAlignment = .center
        label2.sizeToFit()
        
        headerBar.addSubview(label2)
        label2.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        let tabBar = UITabBar()
        tabBar.delegate = self
        tabBar.backgroundImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.tintColor = Stylesheet.color(.yellow)
        tabBar.unselectedItemTintColor = Stylesheet.color(.white)
        tabBar.shadowImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.itemWidth = 90
        tabBar.itemSpacing = 50
        
        var items = [UITabBarItem]()
        for (index, value) in viewModel.barItems.enumerated() {
            let image = UIImage(named: value.1)
            let item = UITabBarItem(title: value.0, image: image, tag: index)
            items.append(item)
        }
        tabBar.items = items
        
        headerBar.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.top.equalTo(label2.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
    
    func prepareTextFields() {
        usernameTextField.placeholder = R.string.localizable.username()
        passwordTextField.placeholder = R.string.localizable.password()
        tfaCodeTextField.placeholder = R.string.localizable.tfa_code()
        
        passwordTextField.isSecureTextEntry = true
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
//        usernameTextField.delegate = self
        
        usernameTextField.dividerActiveColor = Stylesheet.color(.cyan)
        usernameTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.dividerActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        
        let spacing = 40
        
        contentView.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(spacing)
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
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.height.equalTo(50)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

