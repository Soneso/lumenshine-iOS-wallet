//
//  EmailConfirmationView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/9/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol EmailConfirmationViewDelegate: class {
    func didTapResendButton()
    func didTapDoneButton(email: String?)
}

class EmailConfirmationView: UIView {
    
    // MARK: - Properties
    
    fileprivate let viewModel: LostSecurityViewModelType
    
    // MARK: - UI properties
    fileprivate let horizontalSpacing = 15.0
    fileprivate let verticalSpacing = 14.0
    fileprivate let titleLabel = UILabel()
    fileprivate let hintLabel = UILabel()
    fileprivate let errorLabel = UILabel()
    
    fileprivate let submitButton = RaisedButton()
    fileprivate let resendButton = RaisedButton()
    
    weak var delegate: EmailConfirmationViewDelegate?
    
    init(viewModel: LostSecurityViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions
extension EmailConfirmationView {
    @objc
    func resendAction(sender: UIButton) {
        delegate?.didTapResendButton()
    }
    
    @objc
    func submitAction(sender: UIButton) {
        delegate?.didTapDoneButton(email: viewModel.lostEmail)
    }
}

extension EmailConfirmationView: LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool {
        if let parameter = error.parameterName, parameter == "email" {
            errorLabel.text = error.errorDescription
            return true
        }
        return false
    }
    
    func setTFACode(_ tfaCode: String) {}
}

fileprivate extension EmailConfirmationView {
    
    func prepareView() {
        prepareTitleLabel()
        prepareHintLabel()
        prepareButtons()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = viewModel.title        
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareHintLabel() {
        errorLabel.text = R.string.localizable.lbl_email_confirmation2()
        errorLabel.font = R.font.encodeSansRegular(size: 12)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.red)
        errorLabel.numberOfLines = 0
        
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        hintLabel.text = R.string.localizable.email_confirmation_hint2()
        hintLabel.font = R.font.encodeSansRegular(size: 12)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.lightBlack)
        hintLabel.numberOfLines = 0
        
        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareButtons() {
        submitButton.title = R.string.localizable.continue().uppercased()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(38)
        }
        
        resendButton.title = R.string.localizable.email_resend_confirmation().uppercased()
        resendButton.titleColor = Stylesheet.color(.white)
        resendButton.cornerRadiusPreset = .cornerRadius6
        resendButton.backgroundColor = Stylesheet.color(.orange)
        resendButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        resendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        resendButton.addTarget(self, action: #selector(resendAction(sender:)), for: .touchUpInside)
        
        addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(260)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
}

