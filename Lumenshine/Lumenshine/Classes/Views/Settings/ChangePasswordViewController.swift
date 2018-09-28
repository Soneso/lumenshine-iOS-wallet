//
//  ChangePasswordViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/27/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let textField1 = LSTextField()
    fileprivate let textField2 = LSTextField()
    fileprivate let textField3 = LSTextField()
    fileprivate let submitButton = RaisedButton()
    fileprivate let passwordHintButton = Material.IconButton()
    
    fileprivate let verticalSpacing: CGFloat = 42.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: SettingsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func resignFirstResponder() -> Bool {
        textField1.resignFirstResponder()
        textField2.resignFirstResponder()
        textField3.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: - Action for checking username/password
extension ChangePasswordViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        textField1.detail = nil
        textField2.detail = nil
        textField3.detail = nil
        
        guard let currentPassword = textField1.text,
            !currentPassword.isEmpty else {
                textField1.detail = R.string.localizable.empty_password()
                return
        }
        
        guard let newPassword = textField2.text,
            !newPassword.isEmpty else {
                textField2.detail = R.string.localizable.empty_password()
                return
        }
        
        guard let repassword = textField3.text,
            !repassword.isEmpty else {
                textField3.detail = R.string.localizable.empty_password()
                return
        }
        
        _ = resignFirstResponder()
        
        showActivity()
        viewModel.changePassword(currentPass: currentPassword, newPass: newPassword, repeatPass: repassword) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success:
                        self?.viewModel.showSuccess()
                    case .failure(let error):
                        self?.present(error: error)
                    }
                })
            }
        }
    }
    
    @objc
    func hintAction(sender: UIButton) {
        viewModel.showPasswordHint()
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submitAction(sender: submitButton)
        return true
    }
}

fileprivate extension ChangePasswordViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.change_password()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareTitle()
        prepareTextFields()
        prepareSubmitButton()
        prepareHintButton()
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.change_password_hint()
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareTextFields() {
        textField1.isSecureTextEntry = true
        textField1.isVisibilityIconButtonEnabled = true
        textField1.placeholder = R.string.localizable.current_password().uppercased()
        
        textField2.isSecureTextEntry = true
        textField2.isVisibilityIconButtonEnabled = true
        textField2.placeholder = R.string.localizable.new_password().uppercased()
        textField2.dividerContentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: -2.0*horizontalSpacing)
        
        textField3.isSecureTextEntry = true
        textField3.isVisibilityIconButtonEnabled = true
        textField3.placeholder = R.string.localizable.repeat_new_password().uppercased()
        
        view.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-3*horizontalSpacing)
        }
        
        view.addSubview(textField3)
        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareHintButton() {
        let image = R.image.question()?.resize(toWidth: 20)
        passwordHintButton.image = image?.tint(with: Stylesheet.color(.gray))
        passwordHintButton.addTarget(self, action: #selector(hintAction(sender:)), for: .touchUpInside)
        
        view.addSubview(passwordHintButton)
        passwordHintButton.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.centerY.equalTo(textField2)
            make.width.height.equalTo(44)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.change_password().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing+20)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(42)
            make.bottom.lessThanOrEqualTo(-20)
        }
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "current_password" || parameter == "public_key_188" {
                textField1.detail = error.errorDescription
            } else if parameter == "new_password" {
                textField2.detail = error.errorDescription
            } else if parameter == "re_password" {
                textField3.detail = error.errorDescription
            } else {
                let alert = AlertFactory.createAlert(error: error)
                self.present(alert, animated: true)
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
}

