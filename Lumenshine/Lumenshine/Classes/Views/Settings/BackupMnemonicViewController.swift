//
//  BackupMnemonicViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/7/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class BackupMnemonicViewController: UIViewController {
    
    // MARK: - Properties
    fileprivate let mnemonic: String
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let wordsLabel = UILabel()
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate let verticalSpacing: CGFloat = 42.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(mnemonic: String) {
        self.mnemonic = mnemonic
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
        return super.resignFirstResponder()
    }
}

fileprivate extension BackupMnemonicViewController {
    
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = R.string.localizable.backup_mnemonic()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareContentView()
        prepareTitleLabel()
        prepareWordsLabel()
    }
    
    func prepareContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(view)
        }
    }
    
    func prepareTitleLabel() {
        titleLabel.text = R.string.localizable.mnemonic_words_title()
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareWordsLabel() {
        wordsLabel.text = generateMnemonic()
        wordsLabel.font = R.font.encodeSansRegular(size: 14)
        wordsLabel.textAlignment = .left
        wordsLabel.textColor = Stylesheet.color(.lightBlack)
        wordsLabel.numberOfLines = 0
        
        contentView.addSubview(wordsLabel)
        wordsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-10)
        }
    }
    
    func generateMnemonic() -> String {
        let words = self.mnemonic.components(separatedBy:" ")
        var mnemonic = ""
        
        for (index, word) in words.enumerated() {
            mnemonic += "\(index+1). \(word)\n"
        }
        return mnemonic
    }
}

