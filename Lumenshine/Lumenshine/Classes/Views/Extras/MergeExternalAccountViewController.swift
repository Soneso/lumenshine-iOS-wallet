//
//  MergeExternalAccountViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 23/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class MergeExternalAccountViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ExtrasViewModelType
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let seedInputFiled = LSTextField()
    fileprivate let walletField = LSTextField()
    
    fileprivate let submitButton = RaisedButton()
    
    fileprivate let verticalSpacing: CGFloat = 42.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: ExtrasViewModelType) {
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
        seedInputFiled.resignFirstResponder()
        walletField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

extension MergeExternalAccountViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        seedInputFiled.detail = nil
        walletField.detail = nil
        
        guard let seed = seedInputFiled.text, !seed.isEmpty else {
            seedInputFiled.detail = R.string.localizable.empty_seed()
            return
        }
        
        _ = resignFirstResponder()
        
        mergeAccount(accountSeed:"TODO", walletPK:"TODO")
    }
}

extension MergeExternalAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submitAction(sender: submitButton)
        return true
    }
}

fileprivate extension MergeExternalAccountViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.merge_external_account()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareTitle()
        prepareTextFields()
        prepareSubmitButton()
        
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.merge_external_account_hint()
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansRegular(size: 15)
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
        seedInputFiled.placeholder = R.string.localizable.external_account_seed()
        
        walletField.borderWidthPreset = .border2
        walletField.borderColor = Stylesheet.color(.gray)
        walletField.dividerNormalHeight = 1
        walletField.dividerActiveHeight = 1
        walletField.dividerNormalColor = Stylesheet.color(.gray)
        walletField.backgroundColor = .white
        walletField.textInset = horizontalSpacing
        walletField.setInputViewOptions(options: viewModel.wallets, selectedIndex: 0) { newIndex in
            //self.viewModel.walletIndex = newIndex
        }
        
        let walletLabel = UILabel()
        walletLabel.text = R.string.localizable.merge_into()
        walletLabel.font = R.font.encodeSansRegular(size: 13)
        walletLabel.adjustsFontSizeToFitWidth = true
        walletLabel.textColor = Stylesheet.color(.darkGray)
        
        view.addSubview(seedInputFiled)
        seedInputFiled.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(walletLabel)
        walletLabel.snp.makeConstraints { make in
            make.top.equalTo(seedInputFiled.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        view.addSubview(walletField)
        walletField.snp.makeConstraints { make in
            make.top.equalTo(walletLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareSubmitButton() {
        submitButton.title = R.string.localizable.submit().uppercased()
        submitButton.backgroundColor = Stylesheet.color(.green)
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(walletField.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(38)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "seed" {
                seedInputFiled.detail = error.errorDescription
            } else {
                let alert = AlertFactory.createAlert(error: error)
                self.present(alert, animated: true)
            }
        } else {
            let alert = AlertFactory.createAlert(error: error)
            self.present(alert, animated: true)
        }
    }
    
    func showMergeSuccess() {
        //viewModel.showConfirm2faSecret(tfaResponse: tfaSecretResponse)
    }
    
    func mergeAccount(accountSeed:String, walletPK:String) {
        showActivity(message: R.string.localizable.loading())
        viewModel.mergeExternalAccount(accountSeed:accountSeed, walletPK:walletPK) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success:
                        self.showMergeSuccess()
                    case .failure(let error):
                        self.present(error: error)
                        // TODO show error to user!
                    }
                })
            }
        }
    }
}
