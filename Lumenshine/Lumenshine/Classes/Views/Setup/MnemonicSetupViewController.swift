//
//  MnemonicSetupViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/20/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class MnemonicSetupViewController: SetupViewController {
    
    // MARK: - Properties
    
    // MARK: - UI properties
    fileprivate let stepLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    
    fileprivate let hintLabel = UILabel()
    fileprivate let descriptionLabel = UILabel()
    fileprivate let moreLabel = UILabel()
    fileprivate let moreButton = Button()
    
    fileprivate let wordsTitleLabel = UILabel()
    fileprivate let wordsLabel = UILabel()
    fileprivate let submitButton = RaisedButton()
    
    override init(viewModel: SetupViewModelType) {
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
extension MnemonicSetupViewController {
    
    @objc
    func submitAction(sender: UIButton) {
        viewModel.mnemonicVerification()
    }
    
    @objc
    func moreAction(sender: UIButton) {
        let hint = R.string.localizable.mnemonic_hint_lbl()
        let textVC = InfoViewController(info: hint)
        present(AppNavigationController(rootViewController: textVC), animated: true)
    }
}

fileprivate extension MnemonicSetupViewController {
    
    func prepareView() {
        prepareTitleLabel()
        prepareHintLabel()
        prepareWordsLabel()
        prepareButtons()
    }
    
    func prepareTitleLabel() {
        stepLabel.text = R.string.localizable.step_3("2")
        stepLabel.font = Stylesheet.font(.headline)
        stepLabel.textAlignment = .center
        stepLabel.textColor = Stylesheet.color(.blue)
        
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        titleLabel.text = R.string.localizable.mnemonic_title()
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
        hintLabel.text = R.string.localizable.mnemonic_hint_title()
        hintLabel.font = Stylesheet.font(.headline)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.red)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(45)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        
        descriptionLabel.text = R.string.localizable.mnemonic_hint_lbl()
        descriptionLabel.font = Stylesheet.font(.footnote)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = Stylesheet.color(.black)
        descriptionLabel.numberOfLines = 0
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(10)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        moreLabel.text = R.string.localizable.mnemonic_more_lbl()
        moreLabel.font = Stylesheet.font(.subhead)
        moreLabel.textColor = Stylesheet.color(.black)
        moreLabel.numberOfLines = 0
        
        contentView.addSubview(moreLabel)
        moreLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview().offset(-20)
        }
        
        moreButton.title = R.string.localizable.here()
        moreButton.titleColor = Stylesheet.color(.blue)
        moreButton.backgroundColor = Stylesheet.color(.white)
        moreButton.titleLabel?.font = Stylesheet.font(.subhead)
        moreButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        moreButton.addTarget(self, action: #selector(moreAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.left.equalTo(moreLabel.snp.right)
            make.centerY.equalTo(moreLabel)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.black)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(moreLabel.snp.bottom).offset(25)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func prepareWordsLabel() {
        wordsTitleLabel.text = R.string.localizable.mnemonic_words_title()
        wordsTitleLabel.font = Stylesheet.font(.headline)
        wordsTitleLabel.textAlignment = .center
        wordsTitleLabel.textColor = Stylesheet.color(.black)
        wordsTitleLabel.numberOfLines = 0
        
        contentView.addSubview(wordsTitleLabel)
        wordsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(moreLabel.snp.bottom).offset(45)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        wordsLabel.text = generateMnemonic()
        wordsLabel.font = Stylesheet.font(.subhead)
        wordsLabel.textAlignment = .left
        wordsLabel.textColor = Stylesheet.color(.black)
        wordsLabel.numberOfLines = 0
        
        contentView.addSubview(wordsLabel)
        wordsLabel.snp.makeConstraints { make in
            make.top.equalTo(wordsTitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    func prepareButtons() {
        submitButton.title = R.string.localizable.mnemonic_words_button_lbl()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.backgroundColor = Stylesheet.color(.red)
        submitButton.titleLabel?.font = Stylesheet.font(.caption2)
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        submitButton.cornerRadiusPreset = .none
        submitButton.borderWidthPreset = .border2
        submitButton.depthPreset = .depth2
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(wordsLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-10)
        }
    }
    
    func generateMnemonic() -> String {
        let words = viewModel.mnemonic24Word.components(separatedBy:" ")
        var mnemonic = ""
        
        for (index, word) in words.enumerated() {
            mnemonic += "\(index+1). \(word)\n"
        }
        return mnemonic
    }
}
