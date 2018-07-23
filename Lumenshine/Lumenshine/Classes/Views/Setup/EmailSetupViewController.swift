//
//  EmailSetupViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class EmailSetupViewController: SetupViewController {
    
    // MARK: - Properties
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let hintLabel = UILabel()
    fileprivate let errorLabel = UILabel()
    
    fileprivate let submitButton = RaisedButton()
    fileprivate let resendButton = RaisedButton()

    
    override init(viewModel: SetupViewModelType) {
        super.init(viewModel: viewModel)
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
extension EmailSetupViewController {
    @objc
    func resendAction(sender: UIButton) {
        viewModel.resendMailConfirmation { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.snackbarController?.animate(snackbar: .visible, delay: 0)
                    self.snackbarController?.animate(snackbar: .hidden, delay: 3)
                case .failure(let error):
                    self.errorLabel.text = error.errorDescription
                }
            }
        }
    }
    
    @objc
    func submitAction(sender: UIButton) {
        viewModel.checkMailConfirmation { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tfaResponse):
                    self.viewModel.nextStep(tfaResponse: tfaResponse)
                case .failure(let error):
                    self.errorLabel.text = error.errorDescription
                }
            }
        }
    }
}

fileprivate extension EmailSetupViewController {
    
    func prepareView() {
        prepareTitleLabel()
        prepareHintLabel()
        prepareButtons()
        snackbarController?.snackbar.text = R.string.localizable.email_resent()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = R.string.localizable.lbl_email_confirmation()
        titleLabel.font = Stylesheet.font(.headline)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.red)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareHintLabel() {
        hintLabel.text = R.string.localizable.email_confirmation_hint()
        hintLabel.font = Stylesheet.font(.footnote)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.black)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(50)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        

        errorLabel.font = Stylesheet.font(.footnote)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.red)
        errorLabel.numberOfLines = 0
        
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
    }
    
    func prepareButtons() {
        submitButton.title = R.string.localizable.continue()
        submitButton.titleColor = Stylesheet.color(.black)
        submitButton.titleLabel?.font = Stylesheet.font(.caption2)
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        submitButton.cornerRadiusPreset = .none
        submitButton.borderWidthPreset = .border2
        submitButton.depthPreset = .depth2
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        resendButton.title = R.string.localizable.email_resend_confirmation()
        resendButton.titleColor = Stylesheet.color(.black)
        resendButton.titleLabel?.font = Stylesheet.font(.caption2)
        resendButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        resendButton.cornerRadiusPreset = .none
        resendButton.borderWidthPreset = .border2
        resendButton.depthPreset = .depth2
        resendButton.addTarget(self, action: #selector(resendAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "email" {
                errorLabel.text = error.errorDescription
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
}

