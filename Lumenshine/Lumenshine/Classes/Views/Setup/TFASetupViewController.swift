//
//  TFASetupViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/16/18.
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
    fileprivate let tfaCodeTextField = TextField()
    
    fileprivate let hintLabel = UILabel()
    fileprivate let setupLabel = UILabel()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        prepareView()
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
extension TFASetupViewController {
    @objc
    func copyAction(sender: UIButton) {
        UIPasteboard.general.string = viewModel.tfaSecret
        
        snackbarController?.animate(snackbar: .visible, delay: 0)
        snackbarController?.animate(snackbar: .hidden, delay: 3)
    }
    
    @objc
    func submitAction(sender: UIButton) {
        guard let code = tfaCodeTextField.text else { return }
        viewModel.submit(tfaCode: code) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tfaResponse):
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
        stepLabel.font = Stylesheet.font(.headline)
        stepLabel.textAlignment = .center
        stepLabel.textColor = Stylesheet.color(.blue)
        
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        titleLabel.text = R.string.localizable.lbl_tfa()
        titleLabel.font = Stylesheet.font(.headline)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.red)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareSecretLabel() {
        snackbarController?.snackbar.text = R.string.localizable.fa_secret_copy()
        
        tfaSecretLabel.text = R.string.localizable.lbl_tfa_secret(viewModel.tfaSecret)
        tfaSecretLabel.font = Stylesheet.font(.footnote)
        tfaSecretLabel.textAlignment = .center
        tfaSecretLabel.textColor = Stylesheet.color(.black)
        
        contentView.addSubview(tfaSecretLabel)
        tfaSecretLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalTo(40)
        }
        
        tfaCopyButton.image = R.image.copy()
        tfaCopyButton.addTarget(self, action: #selector(copyAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(tfaCopyButton)
        tfaCopyButton.snp.makeConstraints { make in
            make.centerY.equalTo(tfaSecretLabel)
            make.left.equalTo(tfaSecretLabel.snp.right).offset(10)
            make.right.equalTo(-40)
            make.width.equalTo(40)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
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
        
        contentView.addSubview(tfaCodeTextField)
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
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.centerY.equalTo(tfaCodeTextField)
            make.left.equalTo(tfaCodeTextField.snp.right).offset(10)
            make.right.equalTo(-40)
            make.width.equalTo(80)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareSetupLabel() {
        hintLabel.text = R.string.localizable.lbl_tfa_hint()
        hintLabel.font = Stylesheet.font(.body)
        hintLabel.textColor = Stylesheet.color(.red)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(tfaCodeTextField.snp.bottom).offset(50)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        setupLabel.text = R.string.localizable.lbl_tfa_setup()
        setupLabel.font = Stylesheet.font(.body)
        setupLabel.textColor = Stylesheet.color(.black)
        setupLabel.numberOfLines = 0
        
        contentView.addSubview(setupLabel)
        setupLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
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
