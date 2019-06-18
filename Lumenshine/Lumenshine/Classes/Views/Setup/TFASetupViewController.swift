//
//  TFASetupViewController.swift
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

class TFASetupViewController: SetupViewController {
    
    // MARK: - Properties
    
    // MARK: - UI properties
    fileprivate let stepLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    fileprivate let tfaSecretLabel = UILabel()
    fileprivate let tfaCopyButton = Button()
    
    fileprivate let submitButton = RaisedButton()
    fileprivate let tfaCodeTextField = LSTextField()
    
    fileprivate let hintLabel = UILabel()
    fileprivate let setupLabel = UILabel()
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    
    override init(viewModel: SetupViewModelType) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignFirstResponder() -> Bool {
        tfaCodeTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        prepareView()
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
extension TFASetupViewController {
    @objc
    func copyAction(sender: UIButton) {
        UIPasteboard.general.string = viewModel.tfaSecret
        let alert = UIAlertController(title: nil, message: R.string.localizable.copied_clipboard(), preferredStyle: .actionSheet)
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
        guard let code = tfaCodeTextField.text else { return }
        
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: code)) {
            self.tfaCodeTextField.detail = R.string.localizable.tfa_code_numeric_msg()
            return
        }
        if code.trimmed.count != 6 {
            self.tfaCodeTextField.detail = R.string.localizable.tfa_code_6_digits_messgae()
            return
        }
            
        viewModel.submit(tfaCode: code.trimmed) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tfaResponse):
                    if let tfaSecret = self.viewModel.tfaSecret {
                        TFAGeneration.createToken(tfaSecret: tfaSecret, email: self.viewModel.userEmail)
                    }
                    self.viewModel.nextStep(tfaResponse: tfaResponse)
                case .failure(let error):
                    self.tfaCodeTextField.detail = error.errorDescription
                }
            }
        }
    }
}

fileprivate extension TFASetupViewController {
    
    func prepareView() {
        prepareTitleLabel()
        prepareSecretLabel()
        prepare2FACode()
        prepareSetupLabel()
    }
    
    func prepareTitleLabel() {
        stepLabel.text = R.string.localizable.step_3("1")
        stepLabel.font = R.font.encodeSansRegular(size: 13)
        stepLabel.textAlignment = .center
        stepLabel.textColor = Stylesheet.color(.darkGray)
        
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        titleLabel.text = R.string.localizable.lbl_tfa()
        titleLabel.font = R.font.encodeSansSemiBold(size: 14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.red)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(5)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
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
        tfaSecretLabel.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        tfaSecretLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(tfaSecretLabel)
        tfaSecretLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(35)
            make.left.equalTo(30)
        }
        
        tfaCopyButton.image = R.image.copy()
        tfaCopyButton.addTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(tfaCopyButton)
        tfaCopyButton.snp.makeConstraints { make in
            make.centerY.equalTo(tfaSecretLabel)
            make.left.equalTo(tfaSecretLabel.snp.right).offset(10)
            make.right.equalTo(-30)
            make.width.equalTo(30)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
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
        
        contentView.addSubview(tfaCodeTextField)
        tfaCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(tfaSecretLabel.snp.bottom).offset(25)
            make.width.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepareSetupLabel() {
        hintLabel.text = R.string.localizable.lbl_tfa_hint()
        hintLabel.font = R.font.encodeSansRegular(size: 14)
        hintLabel.textColor = Stylesheet.color(.red)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(35)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        setupLabel.text = R.string.localizable.lbl_tfa_setup()
        setupLabel.font = R.font.encodeSansRegular(size: 14)
        setupLabel.textColor = Stylesheet.color(.lightBlack)
        setupLabel.numberOfLines = 0
        
        contentView.addSubview(setupLabel)
        setupLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(10)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        submitButton.title = R.string.localizable.next().uppercased()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(setupLabel.snp.bottom).offset(30)
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(38)
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
