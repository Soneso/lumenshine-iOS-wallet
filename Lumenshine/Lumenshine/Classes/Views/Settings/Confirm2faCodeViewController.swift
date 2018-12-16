//
//  Confirm2faCodeViewController.swift
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

class Confirm2faCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let hintLabel = UILabel()
    
    fileprivate let tfaSecretLabel = UILabel()
    fileprivate let tfaCopyButton = Button()
    fileprivate let tfaCodeTextField = LSTextField()
    
    fileprivate let cancelButton = RaisedButton()
    fileprivate let submitButton = RaisedButton()
    fileprivate let errorLabel = UILabel()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MenuViewModel.backgroudTimePeriod = 120
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MenuViewModel.backgroudTimePeriod = 10
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
                tfaCodeTextField.pasteText(tfaCode)
            }
        }
    }
}

// MARK: - Actions
extension Confirm2faCodeViewController {
    @objc
    func copyAction(sender: UIButton) {
        UIPasteboard.general.string = viewModel.tfaSecret
        let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
        self.present(alert, animated: true)
        let when = DispatchTime.now() + 0.75
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true)
        }
        //snackbarController?.animate(snackbar: .visible, delay: 0)
        //snackbarController?.animate(snackbar: .hidden, delay: 3)
    }
    
    @objc
    func submitAction(sender: UIButton) {
        guard let code = tfaCodeTextField.text else {
            tfaCodeTextField.detail = R.string.localizable.invalid_input()
            return
        }
        
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: code)) {
            self.tfaCodeTextField.detail = R.string.localizable.tfa_code_numeric_msg()
            return
        }
        if code.trimmed.count != 6 {
            self.tfaCodeTextField.detail = R.string.localizable.tfa_code_6_digits_messgae()
            return
        }
        
        viewModel.confirm2faSecret(tfaCode: code.trimmed) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.viewModel.showSuccess()
                case .failure(let error):
                    self?.tfaCodeTextField.detail = error.errorDescription
                }
            }
        }
    }
    
    @objc
    func cancelAction(sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
        snackbarController?.navigationItem.titleLabel.text = R.string.localizable.change_2fa()
        snackbarController?.navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        snackbarController?.navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        prepareTitleLabel()
        prepareSecretLabel()
        prepare2FACode()
        prepareButtons()
    }
    
    func prepareTitleLabel() {
        
        titleLabel.text = R.string.localizable.new_2fa_secret()
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.green)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        hintLabel.text = R.string.localizable.lbl_2fa_hint()
        hintLabel.font = R.font.encodeSansRegular(size: 14)
        hintLabel.textColor = Stylesheet.color(.lightBlack)
        hintLabel.numberOfLines = 0
        hintLabel.adjustsFontSizeToFitWidth = true
        
        
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepareSecretLabel() {
        snackbarController?.snackbar.text = R.string.localizable.fa_secret_copy()
        if let secret = viewModel.tfaSecret {
            tfaSecretLabel.text = R.string.localizable.lbl_tfa_secret(secret)
        } else {
            present(error: .parsingFailed(message: R.string.localizable.fa_secret()))
        }
        tfaSecretLabel.font = R.font.encodeSansSemiBold(size: 14)
        tfaSecretLabel.textAlignment = .center
        tfaSecretLabel.textColor = Stylesheet.color(.black)
        
        view.addSubview(tfaSecretLabel)
        tfaSecretLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(30)
        }
        
        tfaCopyButton.image = R.image.copy()
        tfaCopyButton.addTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
        
        view.addSubview(tfaCopyButton)
        tfaCopyButton.snp.makeConstraints { make in
            make.centerY.equalTo(tfaSecretLabel)
            make.left.equalTo(tfaSecretLabel.snp.right).offset(10)
            make.width.equalTo(30)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(tfaSecretLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepare2FACode() {
        tfaCodeTextField.keyboardType = .numberPad
        tfaCodeTextField.placeholder = R.string.localizable.tfa_code()
        tfaCodeTextField.delegate = self
        tfaCodeTextField.placeholderAnimation = .hidden
        
        view.addSubview(tfaCodeTextField)
        tfaCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(tfaSecretLabel.snp.bottom).offset(35)
            make.left.equalTo(2*horizontalSpacing)
            make.right.equalTo(-2*horizontalSpacing)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepareButtons() {
        cancelButton.title = R.string.localizable.cancel().uppercased()
        cancelButton.backgroundColor = Stylesheet.color(.darkGray)
        cancelButton.titleColor = Stylesheet.color(.white)
        cancelButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        cancelButton.cornerRadiusPreset = .cornerRadius6
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
        
        submitButton.title = R.string.localizable.next().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(50)
            make.right.equalTo(view.snp.centerX).offset(-15)
            make.width.equalTo(100)
            make.height.equalTo(38)
        }
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.centerY.equalTo(cancelButton)
            make.left.equalTo(view.snp.centerX).offset(15)
            make.width.equalTo(100)
            make.height.equalTo(38)
        }
        
        errorLabel.text = R.string.localizable.lbl_cancel_2fa_secret()
        errorLabel.font = R.font.encodeSansRegular(size: 14)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.lightBlack)
        errorLabel.numberOfLines = 0
        
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.lessThanOrEqualTo(-20)
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
}
