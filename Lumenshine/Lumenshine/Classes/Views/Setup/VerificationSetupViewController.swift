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
        let indices = wordInputs.map {
            $0.textField.text
        }
        let result = viewModel.validateSetup(wordsIndices: indices)
        wordInputs.forEach {
            $0.makeInvalid(!result)
        }
        errorLabel.text = result == false ? R.string.localizable.invalid_input() : nil
        if result {
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
        stepLabel.font = Stylesheet.font(.headline)
        stepLabel.textAlignment = .center
        stepLabel.textColor = Stylesheet.color(.blue)
        
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        titleLabel.text = R.string.localizable.verify_mnemonic_title()
        titleLabel.font = Stylesheet.font(.headline)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.red)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareHintLabel() {
        hintLabel.text = R.string.localizable.verify_mnemonic_hint()
        hintLabel.font = Stylesheet.font(.subhead)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.black)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(45)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp.bottom).offset(25)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareWordsLabel() {
        wordsTitleLabel.text = R.string.localizable.verify_mnemonic_words_title()
        wordsTitleLabel.font = Stylesheet.font(.subhead)
        wordsTitleLabel.textAlignment = .center
        wordsTitleLabel.textColor = Stylesheet.color(.black)
        wordsTitleLabel.numberOfLines = 0
        
        contentView.addSubview(wordsTitleLabel)
        wordsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(45)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
    
    func prepareTextFields() {
        let words = viewModel.verificationWords
        for i in 0...3 {
            wordInputs[i].label.text = words[i]
            contentView.addSubview(wordInputs[i])
            wordInputs[i].snp.makeConstraints { make in
                if i == 0 {
                    make.top.equalTo(wordsTitleLabel.snp.bottom).offset(30)
                } else {
                    make.top.equalTo(wordInputs[i-1].snp.bottom).offset(10)
                }
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func prepareButtons() {
        errorLabel.font = Stylesheet.font(.footnote)
        errorLabel.textAlignment = .center
        errorLabel.textColor = Stylesheet.color(.red)
        errorLabel.numberOfLines = 0
        
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(wordInputs[3].snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        submitButton.title = R.string.localizable.finish_setup()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.backgroundColor = Stylesheet.color(.blue)
        submitButton.titleLabel?.font = Stylesheet.font(.caption2)
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        submitButton.cornerRadiusPreset = .none
        submitButton.borderWidthPreset = .border2
        submitButton.depthPreset = .depth2
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        backButton.title = R.string.localizable.back_mnemonic()
        backButton.titleColor = Stylesheet.color(.black)
        backButton.backgroundColor = Stylesheet.color(.yellow)
        backButton.titleLabel?.font = Stylesheet.font(.caption2)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        backButton.cornerRadiusPreset = .none
        backButton.borderWidthPreset = .border2
        backButton.depthPreset = .depth2
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-10)
        }
    }
}

