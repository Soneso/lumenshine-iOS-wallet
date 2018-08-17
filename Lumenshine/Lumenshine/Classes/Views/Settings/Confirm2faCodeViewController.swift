//
//  Confirm2faCodeViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/31/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class Confirm2faCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let hintLabel = UILabel()
    
    fileprivate let tfaSecretLabel = UILabel()
    fileprivate let tfaCopyButton = Button()
    
    fileprivate let submitButton = RaisedButton()
    fileprivate let tfaCodeTextField = TextField()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        
        prepareView()
    }
    
    override func resignFirstResponder() -> Bool {
        tfaCodeTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        if UIPasteboard.general.hasStrings {
            if let tfaCode = UIPasteboard.general.string,
                tfaCode.count == 6,
                CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: tfaCode)) {
                tfaCodeTextField.text = tfaCode
            }
        }
    }
}

// MARK: - Actions
extension Confirm2faCodeViewController {
    @objc
    func copyAction(sender: UIButton) {
        UIPasteboard.general.string = viewModel.tfaSecret
        
        snackbarController?.animate(snackbar: .visible, delay: 0)
        snackbarController?.animate(snackbar: .hidden, delay: 3)
    }
    
    @objc
    func submitAction(sender: UIButton) {
        guard let code = tfaCodeTextField.text else { return }
        viewModel.confirm2faSecret(tfaCode: code) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.showSuccess()
                case .failure(let error):
                    self.tfaCodeTextField.detail = error.errorDescription
                }
            }
        }
    }
}

extension Confirm2faCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submitAction(sender: submitButton)
        return true
    }
}

fileprivate extension Confirm2faCodeViewController {
    
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.change_2fa()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
        prepareTitleLabel()
        prepareSecretLabel()
        prepare2FACode()
    }
    
    func prepareTitleLabel() {
        
        titleLabel.text = R.string.localizable.new_2fa_secret()
        titleLabel.font = Stylesheet.font(.headline)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.green)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        hintLabel.text = R.string.localizable.lbl_2fa_hint()
        hintLabel.font = Stylesheet.font(.body)
        hintLabel.textColor = Stylesheet.color(.black)
        hintLabel.numberOfLines = 0
        
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareSecretLabel() {
        snackbarController?.snackbar.text = R.string.localizable.fa_secret_copy()
        if let secret = viewModel.tfaSecret {
            tfaSecretLabel.text = R.string.localizable.lbl_new_2fa_secret(secret)
        } else {
            present(error: .parsingFailed(message: R.string.localizable.fa_secret()))
        }
        tfaSecretLabel.font = Stylesheet.font(.footnote)
        tfaSecretLabel.textAlignment = .center
        tfaSecretLabel.textColor = Stylesheet.color(.black)
        
        view.addSubview(tfaSecretLabel)
        tfaSecretLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(50)
            make.left.equalTo(40)
        }
        
        tfaCopyButton.image = R.image.copy()
        tfaCopyButton.addTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
        
        view.addSubview(tfaCopyButton)
        tfaCopyButton.snp.makeConstraints { make in
            make.centerY.equalTo(tfaSecretLabel)
            make.left.equalTo(tfaSecretLabel.snp.right).offset(10)
            make.right.equalTo(-40)
            make.width.equalTo(40)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(tfaSecretLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepare2FACode() {
        
        tfaCodeTextField.placeholder = R.string.localizable.tfa_code()
        tfaCodeTextField.placeholderAnimation = .hidden
        tfaCodeTextField.detailColor = Stylesheet.color(.red)
        tfaCodeTextField.dividerActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        tfaCodeTextField.delegate = self
        
        view.addSubview(tfaCodeTextField)
        tfaCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(tfaSecretLabel.snp.bottom).offset(40)
            make.left.equalTo(50)
        }
        
        submitButton.title = R.string.localizable.next()
        submitButton.titleColor = Stylesheet.color(.black)
        submitButton.cornerRadiusPreset = .none
        submitButton.borderWidthPreset = .border2
        submitButton.depthPreset = .depth2
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.centerY.equalTo(tfaCodeTextField)
            make.left.equalTo(tfaCodeTextField.snp.right).offset(10)
            make.right.equalTo(-40)
            make.width.equalTo(80)
        }
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "tfa_code" {
                tfaCodeTextField.detail = error.errorDescription
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
    
    func showSuccess() {
        //show success alert
        let title = R.string.localizable.tfa_secret_changed()
        let alertView = UIAlertController(title: title,
                                          message: nil,
                                          preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default, handler: { action in
            self.viewModel.showSettings()
        })
        alertView.addAction(settingsAction)
        
        present(alertView, animated: true)
    }
}

