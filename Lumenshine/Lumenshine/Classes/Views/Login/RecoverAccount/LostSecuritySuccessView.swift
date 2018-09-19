//
//  LostSecuritySuccessView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/10/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol LostSecuritySuccessViewDelegate: class {
    func didTapResendButton(email: String?)
}

class LostSecuritySuccessView: UIView {
    
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
    
    weak var delegate: LostSecuritySuccessViewDelegate?
    
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
extension LostSecuritySuccessView {
    @objc
    func resendAction(sender: UIButton) {
        delegate?.didTapResendButton(email: viewModel.lostEmail)
    }
    
    @objc
    func submitAction(sender: UIButton) {
        viewModel.showLogin()
    }
}

extension LostSecuritySuccessView: LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool {
        return false
    }
    
    func setTFACode(_ tfaCode: String) {}
}

fileprivate extension LostSecuritySuccessView {
    
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
        errorLabel.text = viewModel.successDetail
        errorLabel.font = R.font.encodeSansRegular(size: 12)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.green)
        errorLabel.numberOfLines = 0
        
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        hintLabel.text = viewModel.successHint
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
        resendButton.title = R.string.localizable.resend_email().uppercased()
        resendButton.titleColor = Stylesheet.color(.white)
        resendButton.cornerRadiusPreset = .cornerRadius6
        resendButton.backgroundColor = Stylesheet.color(.orange)
        resendButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        resendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        resendButton.addTarget(self, action: #selector(resendAction(sender:)), for: .touchUpInside)
        
        addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(38)
        }
        
        submitButton.title = R.string.localizable.done().uppercased()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(resendButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(100)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
}
