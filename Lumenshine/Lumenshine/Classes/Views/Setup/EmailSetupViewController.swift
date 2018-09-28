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
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0

    
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
                    if tfaResponse.mailConfirmed == false {
                        self.errorLabel.text = R.string.localizable.lbl_please_confirm()
                    } else {
                        self.viewModel.nextStep(tfaResponse: tfaResponse)
                    }
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
        snackbarController?.snackbar.text = R.string.localizable.confirmation_mail_resent()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = R.string.localizable.lbl_email_confirmation()
        titleLabel.font = R.font.encodeSansSemiBold(size: 14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.red)
        titleLabel.numberOfLines = 2
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareHintLabel() {
        hintLabel.text = R.string.localizable.email_confirmation_hint()
        hintLabel.font = R.font.encodeSansRegular(size: 14)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.lightBlack)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        

        errorLabel.font = R.font.encodeSansRegular(size: 14)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.red)
        errorLabel.numberOfLines = 0
        
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(70)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
    }
    
    func prepareButtons() {
        submitButton.title = R.string.localizable.continue().uppercased()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(38)
        }
        
        resendButton.title = R.string.localizable.email_resend_confirmation().uppercased()
        resendButton.titleColor = Stylesheet.color(.white)
        resendButton.cornerRadiusPreset = .cornerRadius6
        resendButton.backgroundColor = Stylesheet.color(.darkBlue)
        resendButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        resendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        resendButton.addTarget(self, action: #selector(resendAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(260)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
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

