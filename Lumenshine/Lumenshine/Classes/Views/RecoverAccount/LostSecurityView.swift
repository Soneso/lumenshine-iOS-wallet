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

extension LostSecurityView: LostSecurityContentViewProtocol {
    func present(error: ServiceError) {
        if let parameter = error.parameterName, parameter == "email" {
            viewModel.showEmailConfirmation()
        } else {
            emailTextField.detail = error.errorDescription
        }
    }
}


fileprivate extension LostSecurityView {
    
    func prepare() {
        backgroundColor = Stylesheet.color(.white)
        prepareTitleLabel()
        prepareEmailTextField()
        prepareResetButton()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = viewModel.title
        titleLabel.font = Stylesheet.font(.title1)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.blue)
        
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
        emailTextField.dividerActiveColor = Stylesheet.color(.cyan)
        emailTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        emailTextField.detailColor = Stylesheet.color(.red)
        emailTextField.placeholderAnimation = .hidden
        
        addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
    }
    
    func prepareResetButton() {
        nextButton.title = R.string.localizable.next()
        nextButton.titleColor = Stylesheet.color(.black)
        nextButton.titleLabel?.font = Stylesheet.font(.caption2)
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        nextButton.cornerRadiusPreset = .none
        nextButton.borderWidthPreset = .border2
        nextButton.depthPreset = .depth2
        nextButton.addTarget(self, action: #selector(didTapResetButton(sender:)), for: .touchUpInside)
        
        addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
    }
    
    @objc
    func didTapResetButton(sender: UIButton) {
        emailTextField.detail = nil
        delegate?.didTapNextButton(email: emailTextField.text)
    }
}

