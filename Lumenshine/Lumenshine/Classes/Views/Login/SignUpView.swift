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
    fileprivate let verticalSpacing = UIScreen.main.scale > 2 ? 40.0 : 20.0
    fileprivate let passwordHintButton = Material.IconButton()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    
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
        backgroundColor = Stylesheet.color(.white)
        prepareTitle()
        prepareDetail()
        prepareTextFields()
        prepareLoginButton()
        prepareHintButton()
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.signup().uppercased()
        titleLabel.textColor = Stylesheet.color(.darkBlue)
        titleLabel.font = R.font.encodeSansRegular(size: 24)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
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
        
        addSubview(detailLabel)
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
        textField1.detailColor = Stylesheet.color(.red)
        textField1.detailLabel.font = R.font.encodeSansRegular(size: 13)
        textField1.dividerActiveColor = Stylesheet.color(.gray)
        textField1.placeholderActiveColor = Stylesheet.color(.gray)
        
        textField2.isSecureTextEntry = true
        textField2.isVisibilityIconButtonEnabled = true
        textField2.placeholder = R.string.localizable.password().uppercased()
        textField2.placeholderAnimation = .hidden
        textField2.font = R.font.encodeSansRegular(size: 15)
        textField2.detailColor = Stylesheet.color(.red)
        textField2.detailLabel.font = R.font.encodeSansRegular(size: 13)
        textField2.dividerActiveColor = Stylesheet.color(.gray)
        textField2.placeholderActiveColor = Stylesheet.color(.gray)
        
        textField3.isSecureTextEntry = true
        textField3.isVisibilityIconButtonEnabled = true
        textField3.placeholder = R.string.localizable.repeat_password().uppercased()
        textField3.placeholderAnimation = .hidden
        textField3.font = R.font.encodeSansRegular(size: 15)
        textField3.detailColor = Stylesheet.color(.red)
        textField3.detailLabel.font = R.font.encodeSansRegular(size: 13)
        textField3.dividerActiveColor = Stylesheet.color(.gray)
        textField3.placeholderActiveColor = Stylesheet.color(.gray)
        
        addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(verticalSpacing-10)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        
        addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
        
        addSubview(textField3)
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
        
        addSubview(passwordHintButton)
        passwordHintButton.snp.makeConstraints { make in
//            make.left.equalTo(textField2.snp.right).offset(10)
            make.right.equalTo(-5)
            make.centerY.equalTo(textField2)
        }
    }
    
    func prepareLoginButton() {
        submitButton.title = R.string.localizable.register().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.font = R.font.encodeSansRegular(size: 20)
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
        }
    }
}


