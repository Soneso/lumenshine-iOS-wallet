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
import stellarsdk

class MergeExternalAccountViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ExtrasViewModelType
    fileprivate var selectedWalletPK: String? = nil
    
    // MARK: - UI properties
    
    fileprivate let titleLabel = UILabel()
    fileprivate let successLabel = UILabel()
    fileprivate let seedInputFiled = LSTextField()
    fileprivate let walletLabel = UILabel()
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
        
        guard let seed = seedInputFiled.text?.uppercased(), !seed.isEmpty else {
            seedInputFiled.detail = R.string.localizable.empty_seed()
            return
        }
        
        var sourceKeyPair:KeyPair? = nil
        
        do {
            sourceKeyPair = try KeyPair(secretSeed: seed)
        } catch {
            seedInputFiled.detail = R.string.localizable.invalid_secret_seed()
            return
        }
        
        _ = resignFirstResponder()
        
        var destinationKeyPair:KeyPair? = nil
        do {
            if let accountId = selectedWalletPK {
                destinationKeyPair = try KeyPair(publicKey: PublicKey(accountId: accountId))
            }
        } catch {
            walletField.detail = R.string.localizable.unknown_error()
            return
        }
        
        if let sourcekey = sourceKeyPair, let destinationkey = destinationKeyPair {
            mergeAccount(sourceKeyPair: sourcekey, destinationKeyPair: destinationkey)
        } else {
            walletField.detail = R.string.localizable.unknown_error()
        }
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
    
    var wallets: [String] {
        return self.viewModel.sortedWallets.map {
            $0.walletName + " Wallet"
        }
    }
    
    func prepareTextFields() {
        seedInputFiled.autocapitalizationType = .allCharacters
        seedInputFiled.placeholder = R.string.localizable.external_account_seed().uppercased()
        
        
        walletField.borderWidthPreset = .border2
        walletField.borderColor = Stylesheet.color(.gray)
        walletField.dividerNormalHeight = 1
        walletField.dividerActiveHeight = 1
        walletField.dividerNormalColor = Stylesheet.color(.gray)
        walletField.backgroundColor = .white
        walletField.textInset = horizontalSpacing
        
        selectedWalletPK = self.viewModel.sortedWallets.first?.publicKey
        walletField.setInputViewOptions(options: wallets, selectedIndex: 0) { newIndex in
            if self.viewModel.sortedWallets.count > newIndex {
                let wallet = self.viewModel.sortedWallets[newIndex]
                self.selectedWalletPK = wallet.publicKey
            }
        }
        
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
            make.top.equalTo(walletLabel.snp.bottom).offset(5)
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
            } else  if parameter == "wallet" {
                walletField.detail = error.errorDescription
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
        
        titleLabel.text = R.string.localizable.success()
        titleLabel.textColor = Stylesheet.color(.green)
        titleLabel.font = R.font.encodeSansBold(size: 17)
        
        submitButton.isHidden = true
        seedInputFiled.isHidden = true
        walletLabel.isHidden = true
        walletField.isHidden = true
        
        successLabel.text = R.string.localizable.external_account_merged()
        successLabel.textColor = Stylesheet.color(.lightBlack)
        successLabel.font = R.font.encodeSansRegular(size: 15)
        successLabel.adjustsFontSizeToFitWidth = true
        successLabel.textAlignment = .center
        successLabel.numberOfLines = 0
        
        view.addSubview(successLabel)
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func mergeAccount(sourceKeyPair: KeyPair, destinationKeyPair: KeyPair) {
        showActivity(message: R.string.localizable.loading())
        viewModel.mergeAccount(sourceKeyPair:sourceKeyPair, destinationKeyPair:destinationKeyPair) { result in
            DispatchQueue.main.async {
                self.hideActivity(completion: {
                    switch result {
                    case .success:
                        self.showMergeSuccess()
                    case .failure(let error):
                        self.present(error: error)
                    }
                })
            }
        }
    }
}
