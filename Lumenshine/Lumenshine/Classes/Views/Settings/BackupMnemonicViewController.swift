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
        titleLabel.font = Stylesheet.font(.headline)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.black)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
    
    
    
    func prepareWordsLabel() {
        wordsLabel.text = generateMnemonic()
        wordsLabel.font = Stylesheet.font(.subhead)
        wordsLabel.textAlignment = .left
        wordsLabel.textColor = Stylesheet.color(.darkGray)
        wordsLabel.numberOfLines = 0
        
        contentView.addSubview(wordsLabel)
        wordsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
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

