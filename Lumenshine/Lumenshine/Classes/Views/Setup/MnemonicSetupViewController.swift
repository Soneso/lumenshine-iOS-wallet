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
    
    fileprivate let verticalSpacing = 26.0
    fileprivate let horizontalSpacing = 15.0
    
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
        stepLabel.font = R.font.encodeSansRegular(size: 12)
        stepLabel.textAlignment = .center
        stepLabel.textColor = Stylesheet.color(.darkGray)
        
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        titleLabel.text = R.string.localizable.mnemonic_title()
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
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepareHintLabel() {
        hintLabel.text = R.string.localizable.mnemonic_hint_title()
        hintLabel.font = R.font.encodeSansSemiBold(size: 14)
        hintLabel.textAlignment = .center
        hintLabel.textColor = Stylesheet.color(.red)
        hintLabel.numberOfLines = 0
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        descriptionLabel.text = R.string.localizable.mnemonic_hint_lbl()
        descriptionLabel.font = R.font.encodeSansRegular(size: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = Stylesheet.color(.lightBlack)
        descriptionLabel.numberOfLines = 0
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(15)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        moreLabel.text = R.string.localizable.mnemonic_more_lbl()
        moreLabel.font = R.font.encodeSansRegular(size: 14)
        moreLabel.textColor = Stylesheet.color(.lightBlack)
        moreLabel.numberOfLines = 0
        
        contentView.addSubview(moreLabel)
        moreLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview().offset(-20)
        }
        
        moreButton.title = R.string.localizable.here()
        moreButton.titleColor = Stylesheet.color(.blue)
        moreButton.backgroundColor = Stylesheet.color(.white)
        moreButton.titleLabel?.font = R.font.encodeSansRegular(size: 14)
        moreButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        moreButton.addTarget(self, action: #selector(moreAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.left.equalTo(moreLabel.snp.right)
            make.centerY.equalTo(moreLabel)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.top.equalTo(moreLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func prepareWordsLabel() {
        wordsTitleLabel.text = R.string.localizable.mnemonic_words_title()
        wordsTitleLabel.font = R.font.encodeSansBold(size: 14)
        wordsTitleLabel.textAlignment = .center
        wordsTitleLabel.textColor = Stylesheet.color(.lightBlack)
        wordsTitleLabel.numberOfLines = 0
        
        contentView.addSubview(wordsTitleLabel)
        wordsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(moreLabel.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        wordsLabel.text = generateMnemonic()
        wordsLabel.font = R.font.encodeSansRegular(size: 14)
        wordsLabel.textAlignment = .left
        wordsLabel.textColor = Stylesheet.color(.lightBlack)
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
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(wordsLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(260)
            make.height.equalTo(38)
            make.bottom.equalTo(-20)
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
