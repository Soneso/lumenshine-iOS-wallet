//
//  VerificationSetupViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/20/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class VerificationSetupViewController: SetupViewController {
    
    // MARK: - Properties
    
    // MARK: - UI properties
    fileprivate let stepLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    
    fileprivate let hintLabel = UILabel()
    
    fileprivate let wordsTitleLabel = UILabel()
    fileprivate let wordInputs : [InputField]
    
    fileprivate let errorLabel = UILabel()
    fileprivate let submitButton = RaisedButton()
    fileprivate let backButton = RaisedButton()
    
    fileprivate let verticalSpacing = 32.0
    fileprivate let horizontalSpacing = 15.0
    
    override init(viewModel: SetupViewModelType) {
        var inputs = [InputField]()
        for _ in 1...4 {
            inputs.append(InputField())
        }
        wordInputs = inputs
        super.init(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
}

// MARK: - Actions
extension VerificationSetupViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        if let result = viewModel.validateSetup(wordsIndices: wordInputs.map {$0.textField.text}) {
            for (index, field) in wordInputs.enumerated() {
                field.makeInvalid(result.contains(index))
            }
            errorLabel.text = R.string.localizable.invalid_input()
        } else {
            errorLabel.text = nil
            viewModel.confirmMnemonic { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let tfaResponse):
                        self.viewModel.nextStep(tfaResponse: tfaResponse)
                    case .failure(let error):
                        let alert = AlertFactory.createAlert(error: error)
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc
    func backAction(sender: UIButton) {
        viewModel.nextStep(tfaResponse: nil)
    }
}

fileprivate extension VerificationSetupViewController {
    
    func prepareView() {
        prepareTitleLabel()
        prepareHintLabel()
        prepareWordsLabel()
        prepareTextFields()
        prepareButtons()
    }
    
    func prepareTitleLabel() {
        stepLabel.text = R.string.localizable.step_3("3")
        stepLabel.font = R.font.encodeSansRegular(size: 13)
        stepLabel.textAlignment = .center
        stepLabel.textColor = Stylesheet.color(.darkGray)
        
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        titleLabel.text = R.string.localizable.verify_mnemonic_title()
        titleLabel.font = R.font.encodeSansSemiBold(size: 14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.red)
        titleLabel.numberOfLines = 2
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(5)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareHintLabel() {
        hintLabel.text = R.string.localizable.verify_mnemonic_hint()
        hintLabel.font = R.font.encodeSansRegular(size: 14)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.lightBlack)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepareWordsLabel() {
        wordsTitleLabel.text = R.string.localizable.verify_mnemonic_words_title()
        wordsTitleLabel.font = R.font.encodeSansRegular(size: 14)
        wordsTitleLabel.textAlignment = .center
        wordsTitleLabel.textColor = Stylesheet.color(.lightBlack)
        wordsTitleLabel.numberOfLines = 0
        
        contentView.addSubview(wordsTitleLabel)
        wordsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareTextFields() {
        let words = viewModel.verificationWords
        for i in 0...3 {
            wordInputs[i].label.text = words[i]
            contentView.addSubview(wordInputs[i])
            wordInputs[i].snp.makeConstraints { make in
                if i == 0 {
                    make.top.equalTo(wordsTitleLabel.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(wordInputs[i-1].snp.bottom).offset(7)
                }
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func prepareButtons() {
        errorLabel.font = R.font.encodeSansRegular(size: 12)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.red)
        errorLabel.numberOfLines = 0
        
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(wordInputs[3].snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        submitButton.title = R.string.localizable.finish()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(38)
        }
        
        backButton.title = R.string.localizable.back_mnemonic()
        backButton.titleColor = Stylesheet.color(.white)
        backButton.cornerRadiusPreset = .cornerRadius6
        backButton.backgroundColor = Stylesheet.color(.orange)
        backButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(260)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
        }
    }
}

