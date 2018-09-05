//
//  LostSecurityView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol LostSecurityViewDelegate: class {
    func didTapNextButton(email: String?)
}

class LostSecurityView: UIView {
    // MARK: - Properties
    fileprivate let viewModel: LostSecurityViewModelType
    
    // MARK: - UI properties
    fileprivate let emailTextField = TextField()
    fileprivate let nextButton = RaisedButton()
    fileprivate let titleLabel = UILabel()
    
    weak var delegate: LostSecurityViewDelegate?
    
    init(viewModel: LostSecurityViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LostSecurityView: LoginViewContentProtocol {
    func present(error: ServiceError) -> Bool {
        if let parameter = error.parameterName, parameter == "email" {
            viewModel.showEmailConfirmation()
        } else {
            emailTextField.detail = error.errorDescription
        }
        return true
    }
}


fileprivate extension LostSecurityView {
    
    func prepare() {
        prepareTitleLabel()
        prepareEmailTextField()
        prepareResetButton()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = viewModel.title
        titleLabel.font = R.font.encodeSansRegular(size: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func prepareEmailTextField() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.placeholder = R.string.localizable.email()
        emailTextField.dividerActiveColor = Stylesheet.color(.gray)
        emailTextField.placeholderActiveColor = Stylesheet.color(.gray)
        emailTextField.detailColor = Stylesheet.color(.red)
        emailTextField.placeholderAnimation = .hidden
        emailTextField.font = R.font.encodeSansRegular(size: 15)
        emailTextField.detailLabel.font = R.font.encodeSansRegular(size: 13)
        
        addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
    }
    
    func prepareResetButton() {
        nextButton.title = R.string.localizable.next().uppercased()
        nextButton.titleColor = Stylesheet.color(.white)
        nextButton.backgroundColor = Stylesheet.color(.cyan)
        nextButton.titleLabel?.font = R.font.encodeSansRegular(size: 16)
        nextButton.cornerRadiusPreset = .cornerRadius6
        nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
        nextButton.addTarget(self, action: #selector(didTapResetButton(sender:)), for: .touchUpInside)
        
        addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
        }
    }
    
    @objc
    func didTapResetButton(sender: UIButton) {
        emailTextField.detail = nil
        delegate?.didTapNextButton(email: emailTextField.text)
    }
}

