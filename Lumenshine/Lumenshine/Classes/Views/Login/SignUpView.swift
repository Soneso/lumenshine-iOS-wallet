//
//  SignUpView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/9/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SignUpView: UIView, LoginViewProtocol {
    
    // MARK: - Properties
    fileprivate let viewModel: LoginViewModelType
    fileprivate let verticalSpacing = 40.0
    fileprivate let contentView = UIView()
    fileprivate let scrollView = UIScrollView()
    fileprivate let passwordHintButton = Material.IconButton()
    
    // MARK: - UI properties
    var textField1 = TextField()
    var textField2 = TextField()
    var textField3 = TextField()
    var submitButton = RaisedButton()
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func hintAction(sender: UIButton) {
        viewModel.showPasswordHint()
    }
}

fileprivate extension SignUpView {
    func prepare() {
        prepareContentView()
        prepareTextFields()
        prepareLoginButton()
        prepareHintButton()
    }
    
    func prepareContentView() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(self)
        }
    }
    
    func prepareTextFields() {
        textField1.keyboardType = .emailAddress
        textField1.autocapitalizationType = .none
        textField1.placeholder = R.string.localizable.username()
        textField1.placeholderAnimation = .hidden
        textField1.detailColor = Stylesheet.color(.red)
        textField1.dividerActiveColor = Stylesheet.color(.cyan)
        textField1.placeholderActiveColor = Stylesheet.color(.cyan)
        
        textField2.isSecureTextEntry = true
        textField2.placeholder = R.string.localizable.password()
        textField2.placeholderAnimation = .hidden
        textField2.detailColor = Stylesheet.color(.red)
        textField2.dividerActiveColor = Stylesheet.color(.cyan)
        textField2.placeholderActiveColor = Stylesheet.color(.cyan)
        textField2.isVisibilityIconButtonEnabled = true
        
        textField3.isSecureTextEntry = true
        textField3.placeholder = R.string.localizable.repeat_password()
        textField3.placeholderAnimation = .hidden
        textField3.detailColor = Stylesheet.color(.red)
        textField3.dividerActiveColor = Stylesheet.color(.cyan)
        textField3.placeholderActiveColor = Stylesheet.color(.cyan)
        textField3.isVisibilityIconButtonEnabled = true
        
        contentView.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(40)
            make.right.equalTo(-50)
        }
        
        contentView.addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
        
        contentView.addSubview(textField3)
        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
    }
    
    func prepareHintButton() {
        passwordHintButton.image = R.image.question()
        passwordHintButton.shapePreset = .circle
        passwordHintButton.backgroundColor = Stylesheet.color(.white)
        passwordHintButton.addTarget(self, action: #selector(hintAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(passwordHintButton)
        passwordHintButton.snp.makeConstraints { make in
            make.left.equalTo(textField2.snp.right).offset(10)
            make.centerY.equalTo(textField2)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.signup()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //        submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}


