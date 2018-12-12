//
//  LostSecurityView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
    fileprivate let horizontalSpacing = 15.0
    fileprivate let emailTextField = LSTextField()
    fileprivate let nextButton = RaisedButton()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    
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
    
    func setTFACode(_ tfaCode: String) {}
}


fileprivate extension LostSecurityView {
    
    func prepare() {
        prepareTitleLabel()
        prepareDetail()
        prepareEmailTextField()
        prepareResetButton()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = viewModel.title
        titleLabel.textAlignment = .left
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareDetail() {
     detailLabel.text = viewModel.subtitle
     detailLabel.textColor = Stylesheet.color(.lightBlack)
     detailLabel.font = R.font.encodeSansRegular(size: 13)
     detailLabel.textAlignment = .left
     detailLabel.adjustsFontSizeToFitWidth = true
     detailLabel.numberOfLines = 0
     
     self.addSubview(detailLabel)
     detailLabel.snp.makeConstraints { (make) in
        make.top.equalTo(titleLabel.snp.bottom)
        make.left.equalTo(horizontalSpacing)
        make.right.equalTo(-horizontalSpacing)
     }
    }
 
    func prepareEmailTextField() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.placeholder = R.string.localizable.email().uppercased()
        
        addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(15)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareResetButton() {
        nextButton.title = R.string.localizable.next().uppercased()
        nextButton.titleColor = Stylesheet.color(.white)
        nextButton.backgroundColor = Stylesheet.color(.cyan)
        nextButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        nextButton.cornerRadiusPreset = .cornerRadius6
        nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
        nextButton.addTarget(self, action: #selector(didTapResetButton(sender:)), for: .touchUpInside)
        
        addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
    
    @objc
    func didTapResetButton(sender: UIButton) {
        emailTextField.detail = nil
        delegate?.didTapNextButton(email: emailTextField.text)
    }
}
