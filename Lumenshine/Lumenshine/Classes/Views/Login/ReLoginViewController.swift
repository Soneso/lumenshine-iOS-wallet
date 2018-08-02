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
    fileprivate let headerBar = ToolbarHeader()
    
    fileprivate var contentView: ReLoginViewProtocol {
        didSet {
            prepareLoginButton()
        }
    }
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        self.contentView = ReLoginHomeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        setupContentView(contentView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func resignFirstResponder() -> Bool {
        contentView.passwordTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    func setupContentView(_ contentView: ReLoginViewProtocol) {
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
            contentView.passwordTextField.delegate = self
        }
    }
    
    func showHome() {
        let contentView = ReLoginHomeView(viewModel: viewModel)
        setupContentView(contentView)
    }
    
    func showFingerprint() {
        let contentView = ReLoginFingerView(viewModel: viewModel)
        setupContentView(contentView)
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
        guard let password = contentView.passwordTextField.text,
            !password.isEmpty else {
                contentView.passwordTextField.detail = R.string.localizable.invalid_password()
                return
        }
        
        contentView.passwordTextField.resignFirstResponder()
        contentView.passwordTextField.text = nil
        
        showActivity()
        viewModel.loginStep1(email: "", password: password, tfaCode: nil) { result in
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

extension ReLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reloginAction(sender: contentView.submitButton)
        return true
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
        prepareLoginButton()
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
    
    func prepareLoginButton() {
        contentView.submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
    }
    
    func present(error: ServiceError) {
        contentView.passwordTextField.detail = error.errorDescription
    }
}

