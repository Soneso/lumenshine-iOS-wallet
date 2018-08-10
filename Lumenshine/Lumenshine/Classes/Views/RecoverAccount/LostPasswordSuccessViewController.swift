//
//  LostPasswordSuccessViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/10/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LostPasswordSuccessViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ForgotPasswordViewModelType
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let hintLabel = UILabel()
    fileprivate let errorLabel = UILabel()
    
    fileprivate let submitButton = RaisedButton()
    fileprivate let resendButton = RaisedButton()
    
    fileprivate let contentView = UIView()
    fileprivate let scrollView = UIScrollView()
    
    
    init(viewModel: ForgotPasswordViewModelType) {
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
}

// MARK: - Actions
extension LostPasswordSuccessViewController {
    @objc
    func resendAction(sender: UIButton) {
        viewModel.lostPassword(email: viewModel.email) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.snackbarController?.animate(snackbar: .visible, delay: 0)
                    self?.snackbarController?.animate(snackbar: .hidden, delay: 3)
                case .failure(let error):
                    self?.present(error: error)
                }
            }
        }
    }
    
    @objc
    func submitAction(sender: UIButton) {
        viewModel.showLogin()
    }
}

fileprivate extension LostPasswordSuccessViewController {
    
    func prepareView() {
        prepareContentView()
        prepareTitleLabel()
        prepareHintLabel()
        prepareButtons()
        snackbarController?.snackbar.text = R.string.localizable.email_resent()
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
    
    func prepareTitleLabel() {
        titleLabel.text = R.string.localizable.lost_password()
        titleLabel.font = Stylesheet.font(.title1)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.blue)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func prepareHintLabel() {
        errorLabel.text = R.string.localizable.lost_password_email()
        errorLabel.font = Stylesheet.font(.footnote)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.green)
        errorLabel.numberOfLines = 0
        
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        hintLabel.text = R.string.localizable.lost_password_email_hint()
        hintLabel.font = Stylesheet.font(.footnote)
        hintLabel.textAlignment = .left
        hintLabel.textColor = Stylesheet.color(.black)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareButtons() {
        resendButton.title = R.string.localizable.resend_email()
        resendButton.titleColor = Stylesheet.color(.black)
        resendButton.titleLabel?.font = Stylesheet.font(.caption2)
        resendButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        resendButton.cornerRadiusPreset = .none
        resendButton.borderWidthPreset = .border2
        resendButton.depthPreset = .depth2
        resendButton.addTarget(self, action: #selector(resendAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        submitButton.title = R.string.localizable.done()
        submitButton.titleColor = Stylesheet.color(.black)
        submitButton.titleLabel?.font = Stylesheet.font(.caption2)
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        submitButton.cornerRadiusPreset = .none
        submitButton.borderWidthPreset = .border2
        submitButton.depthPreset = .depth2
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(resendButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func present(error: ServiceError) {
        let alert = AlertFactory.createAlert(error: error)
        self.present(alert, animated: true)
    }
}
