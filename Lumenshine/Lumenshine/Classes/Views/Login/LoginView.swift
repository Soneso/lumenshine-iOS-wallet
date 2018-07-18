//
//  LoginView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/9/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol LoginViewProtocol {
    
    var textField1: TextField { get }
    var textField2: TextField { get }
    var textField3: TextField { get }
    var submitButton: RaisedButton { get }
}

class LoginView: UIView, LoginViewProtocol {

    // MARK: - Properties
    fileprivate let verticalSpacing = 40.0
    fileprivate let contentView = UIView()
    fileprivate let scrollView = UIScrollView()
    
    // MARK: - UI properties
    var textField1 = TextField()
    var textField2 = TextField()
    var textField3 = TextField()
    var submitButton = RaisedButton()
    
    init() {
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension LoginView {
    func prepare() {
        prepareContentView()
        prepareTextFields()
        prepareLoginButton()
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
        
        textField3.keyboardType = .numberPad
        textField3.placeholder = R.string.localizable.tfa_code()
        textField3.placeholderAnimation = .hidden
        textField3.detailColor = Stylesheet.color(.red)
        textField3.dividerActiveColor = Stylesheet.color(.cyan)
        textField3.placeholderActiveColor = Stylesheet.color(.cyan)
        
        contentView.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(40)
            make.right.equalTo(-40)
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
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.login()
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

