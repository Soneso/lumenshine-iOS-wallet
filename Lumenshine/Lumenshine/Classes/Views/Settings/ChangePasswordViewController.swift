//
//  ChangePasswordViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/27/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import IHKeyboardAvoiding

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    
    fileprivate let textField1 = TextField()
    fileprivate let textField2 = TextField()
    fileprivate let textField3 = TextField()
    fileprivate let submitButton = RaisedButton()
    fileprivate let passwordHintButton = Material.IconButton()
    
    fileprivate let verticalSpacing = 40.0
    
    init(viewModel: SettingsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = KeyboardDismissingView()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        
        KeyboardAvoiding.avoidingView = self.view
        KeyboardAvoiding.paddingForCurrentAvoidingView = -200.0
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
        viewModel.changePassword(currentPass: currentPassword, newPass: newPassword, repeatPass: repassword) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success:
                        self.showSuccess()
                    case .failure(let error):
                        self.present(error: error)
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
        prepareTextFields()
        prepareSubmitButton()
        prepareHintButton()
    }
    
    func prepareTextFields() {
        textField1.isSecureTextEntry = true
        textField1.placeholder = R.string.localizable.current_password()
        textField1.placeholderAnimation = .hidden
        textField1.detailColor = Stylesheet.color(.red)
        textField1.dividerActiveColor = Stylesheet.color(.cyan)
        textField1.placeholderActiveColor = Stylesheet.color(.cyan)
        textField1.isVisibilityIconButtonEnabled = true
        
        textField2.isSecureTextEntry = true
        textField2.placeholder = R.string.localizable.new_password()
        textField2.placeholderAnimation = .hidden
        textField2.detailColor = Stylesheet.color(.red)
        textField2.dividerActiveColor = Stylesheet.color(.cyan)
        textField2.placeholderActiveColor = Stylesheet.color(.cyan)
        textField2.isVisibilityIconButtonEnabled = true
        
        textField3.isSecureTextEntry = true
        textField3.placeholder = R.string.localizable.repeat_new_password()
        textField3.placeholderAnimation = .hidden
        textField3.detailColor = Stylesheet.color(.red)
        textField3.dividerActiveColor = Stylesheet.color(.cyan)
        textField3.placeholderActiveColor = Stylesheet.color(.cyan)
        textField3.isVisibilityIconButtonEnabled = true
        
        view.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(40)
            make.right.equalTo(-50)
        }
        
        view.addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
        }
        
        view.addSubview(textField3)
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
        
        view.addSubview(passwordHintButton)
        passwordHintButton.snp.makeConstraints { make in
            make.left.equalTo(textField2.snp.right).offset(10)
            make.centerY.equalTo(textField2)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.change_password()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview()
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
    
    func showSuccess() {
        //show success alert
        let title = R.string.localizable.password_changed()
        let alertView = UIAlertController(title: title,
                                          message: nil,
                                          preferredStyle: .alert)
        
        let homeAction = UIAlertAction(title: R.string.localizable.home(), style: .default, handler: { action in
            self.viewModel.showHome()
        })
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default, handler: { action in
            self.viewModel.showSettings()
        })
        alertView.addAction(homeAction)
        alertView.addAction(settingsAction)
        
        present(alertView, animated: true)
    }
}

