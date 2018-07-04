//
//  ReLoginFingerView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ReLoginFingerView: UIView, ReLoginViewProtocol {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let hintLabel = UILabel()
    
    var submitButton = RaisedButton()
    var passwordTextField = TextField()
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension ReLoginFingerView {
    func prepare() {
        prepareHintLabel()
        prepareTextFields()
        prepareLoginButton()
    }
    
    func prepareHintLabel() {
        hintLabel.text = viewModel.hintText
        hintLabel.textColor = Stylesheet.color(.black)
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
    }
    
    func prepareTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = R.string.localizable.password()
        passwordTextField.detailColor = Stylesheet.color(.red)
        passwordTextField.dividerActiveColor = Stylesheet.color(.cyan)
        passwordTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        
        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(40)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.submit()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //        submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(44)
        }
    }
}

