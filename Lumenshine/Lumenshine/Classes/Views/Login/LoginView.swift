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
    fileprivate let verticalSpacing = UIScreen.main.scale > 2 ? 40.0 : 20.0
    fileprivate let contentView = UIView()
    fileprivate let scrollView = UIScrollView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    
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
        backgroundColor = Stylesheet.color(.white)
//        prepareContentView()
        prepareTitle()
        prepareDetail()
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
    
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.login_continue().uppercased()
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansRegular(size: 24)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(verticalSpacing-10)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
    }
    
    func prepareDetail() {
        detailLabel.text = R.string.localizable.login_fill()
        detailLabel.textColor = Stylesheet.color(.darkGray)
        detailLabel.font = R.font.encodeSansRegular(size: 12)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        self.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
    }
    
    func prepareTextFields() {
        textField1.keyboardType = .emailAddress
        textField1.autocapitalizationType = .none
        textField1.placeholder = R.string.localizable.email().uppercased()
        textField1.placeholderAnimation = .hidden
        textField1.font = R.font.encodeSansRegular(size: 15)
//        textField1.textColor = Stylesheet.color(.gray)
        textField1.detailColor = Stylesheet.color(.red)
        textField1.detailLabel.font = R.font.encodeSansRegular(size: 13)
        textField1.dividerActiveColor = Stylesheet.color(.gray)
        textField1.placeholderActiveColor = Stylesheet.color(.gray)
        
        textField2.isSecureTextEntry = true
        textField2.isVisibilityIconButtonEnabled = true
        textField2.placeholder = R.string.localizable.password().uppercased()
        textField2.placeholderAnimation = .hidden
        textField2.font = R.font.encodeSansRegular(size: 15)
//        textField2.textColor = Stylesheet.color(.gray)
        textField2.detailColor = Stylesheet.color(.red)
        textField2.detailLabel.font = R.font.encodeSansRegular(size: 13)
        textField2.dividerActiveColor = Stylesheet.color(.gray)
        textField2.placeholderActiveColor = Stylesheet.color(.gray)
        
//        textField3.keyboardType = .numberPad
        textField3.placeholder = R.string.localizable.lbl_tfa_code().uppercased()
        textField3.placeholderAnimation = .hidden
        textField3.font = R.font.encodeSansRegular(size: 15)
//        textField3.textColor = Stylesheet.color(.gray)
        textField3.detailColor = Stylesheet.color(.red)
        textField3.detailLabel.font = R.font.encodeSansRegular(size: 13)
        textField3.dividerActiveColor = Stylesheet.color(.gray)
        textField3.placeholderActiveColor = Stylesheet.color(.gray)
        
        self.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(verticalSpacing-10)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        
        self.addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
        
        self.addSubview(textField3)
        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.login().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.font = R.font.encodeSansRegular(size: 20)
        //        submitButton.addTarget(self, action: #selector(reloginAction(sender:)), for: .touchUpInside)
        
        self.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
        }
    }
}

