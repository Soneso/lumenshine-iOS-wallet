//
//  LoginViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool
}

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: LoginViewModel
    
    // MARK: - UI properties
    fileprivate let headerBar = ToolbarHeader()
    fileprivate let scrollView = UIScrollView()
    fileprivate let scrollContentView = UIView()
    
    fileprivate var contentView: LoginViewContentProtocol?
    
    init(viewModel: LoginViewModel) {
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
        showLogin(animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        if UIPasteboard.general.hasStrings {
            if let tfaCode = UIPasteboard.general.string,
                tfaCode.count == 6,
                CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: tfaCode)) {
//                contentView.textField3.text = tfaCode
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension LoginViewController {
    func setupContentView(_ contentView: UIView, animated: Bool = true) {
        if animated {
            let animation = CATransition()
            animation.duration = 0.3
            animation.type = kCATransitionReveal
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            contentView.layer.add(animation, forKey: kCATransitionReveal)
        }
        
        if let oldContent = self.contentView as? UIView {
            oldContent.removeFromSuperview()
        }
        scrollContentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView = contentView as? LoginViewContentProtocol
    }

    func showLogin(animated: Bool = true) {
        let contentView = LoginView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView, animated: animated)
        headerBar.selectItem(at: 0)
    }
    
    func showSignUp() {
        let contentView = SignUpView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        headerBar.selectItem(at: 1)
    }
    
    func showLostPassword() {
        viewModel.lostPassword = true
        let contentView = LostSecurityView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        headerBar.selectItem(at: 2)
    }
    
    func showLost2FA() {
        viewModel.lostPassword = false
        let contentView = LostSecurityView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        headerBar.selectItem(at: 2)
    }
    
    func showEmailConfirmation() {
        let contentView = EmailConfirmationView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        snackbarController?.snackbar.text = R.string.localizable.confirmation_mail_resent()
    }
    
    func showSuccess() {
        let contentView = LostSecuritySuccessView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        snackbarController?.snackbar.text = R.string.localizable.email_resent()
    }
}

extension LoginViewController: LoginViewDelegate {
    func didTapSubmitButton(email: String, password: String, tfaCode: String?) {
        showActivity()
        viewModel.loginStep1(email: email, password: password, tfaCode: tfaCode) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success: break
                    case .failure(let error):
                        let result = self?.contentView?.present(error: error)
                        if result == false {
                            let alert = AlertFactory.createAlert(error: error)
                            self?.present(alert, animated: true)
                        }
                    }
                })
            }
        }
    }
}

extension LoginViewController: SignUpViewDelegate {
    func didTapSubmitButton(email: String, password: String, repassword: String) {
        showActivity()
        viewModel.signUp(email: email, password: password, repassword: repassword) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success: break
                    case .failure(let error):
                        let result = self?.contentView?.present(error: error)
                        if result == false {
                            let alert = AlertFactory.createAlert(error: error)
                            self?.present(alert, animated: true)
                        }
                    }
                })
            }
        }
    }
}

extension LoginViewController: LostSecurityViewDelegate {
    func didTapNextButton(email: String?) {
        self.lostSecurity(email: email)
    }
}

extension LoginViewController: EmailConfirmationViewDelegate {
    func didTapResendButton() {
        viewModel.resendMailConfirmation { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.snackbarController?.animate(snackbar: .visible, delay: 0)
                    self?.snackbarController?.animate(snackbar: .hidden, delay: 3)
                case .failure(let error):
                    _ = self?.contentView?.present(error: error)
                }
            }
        }
    }
    
    func didTapDoneButton(email: String?) {
        self.lostSecurity(email: email)
    }
}

extension LoginViewController: LostSecuritySuccessViewDelegate {
    func didTapResendButton(email: String?) {
        showActivity()
        viewModel.lostSecurity(email: email) { [weak self] result in
            self?.hideActivity(completion: {
                switch result {
                case .success:
                    self?.snackbarController?.animate(snackbar: .visible, delay: 0)
                    self?.snackbarController?.animate(snackbar: .hidden, delay: 3)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self?.present(alert, animated: true)
                }
            })
        }
    }
}

fileprivate extension LoginViewController {
    func lostSecurity(email: String?) {
        showActivity()
        viewModel.lostSecurity(email: email) { [weak self] result in
            self?.hideActivity(completion: {
                switch result {
                case .success:
                    self?.viewModel.showSuccess()
                case .failure(let error):
                    _ = self?.contentView?.present(error: error)
                }
            })
        }
    }
}

extension LoginViewController: ToolbarHeaderDelegate {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int) {
        viewModel.barItemSelected(at: index)
    }
}

extension LoginViewController: HeaderMenuDelegate {
    func menuSelected(at index: Int) {
        viewModel.headerMenuSelected(at: index)
    }
}

fileprivate extension LoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareHeader()
        prepareCopyright()
        prepareContentView()
    }
    
    func prepareHeader() {
        headerBar.delegate = self
        headerBar.setTitle(viewModel.headerTitle)
//        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setItems(viewModel.barItems)
        
        view.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func prepareContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
        scrollContentView.cornerRadiusPreset = .cornerRadius4
        scrollContentView.depthPreset = .depth3
        scrollContentView.backgroundColor = Stylesheet.color(.white)
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-60)
            make.width.equalTo(view).offset(-30)
        }
    }
    
    func prepareCopyright() {
        let imageView = UIImageView(image: R.image.soneso())
        imageView.backgroundColor = Stylesheet.color(.clear)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
        }
        
        let background = UIImageView(image: R.image.soneso_background())
        background.contentMode = .scaleAspectFit
        
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(headerBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top)
        }
    }
}

