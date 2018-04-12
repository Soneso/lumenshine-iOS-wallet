//
//  MnemonicViewController.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
//import stellarsdk
import Material

class MnemonicViewController: UIViewController {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let mnemonicHolderView = UIView()
    fileprivate let nextButton = FlatButton()
    
    fileprivate var mnemonic = ""
    
    @objc
    func confirmPhrase() {
        let verificationViewController = VerificationViewController(type: .questions, mnemonic: mnemonic)
        
        navigationController?.pushViewController(verificationViewController, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        generateMnemonic()
    }
    
    func setupView() {
        navigationItem.titleLabel.text = "Secret Phrase"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
//        let image = Icon.close
//        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
//        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        view.backgroundColor = Stylesheet.color(.white)
        
        titleLabel.text = R.string.localizable.lbl_mnemonic_title()
        titleLabel.font = Stylesheet.font(.headline)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(5)
            make.right.equalTo(-10)
        }
        
        view.addSubview(mnemonicHolderView)
        mnemonicHolderView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-50)
        }
        
        nextButton.title = R.string.localizable.lbl_mnemonic_button_title()
        nextButton.titleColor = Stylesheet.color(.white)
        nextButton.addTarget(self, action: #selector(confirmPhrase), for: .touchUpInside)
        nextButton.backgroundColor = Stylesheet.color(.cyan)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    @objc
    func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func generateMnemonic() {
        
        // TODO: use this when sdk is fixed
//        mnemonic = Wallet.generate24WordMnemonic()
        mnemonic = "Kids Prefer Cheese Over Fried Green Spinach My Very Excited Mother Just Served Us Nine Pies Bad Beer Rots Our Young Guts But Vodka Goes Well"
        let words = mnemonic.components(separatedBy: " ")
        
        var originX: CGFloat = 0.0
        var originY: CGFloat = 0.0
        
        for (index, word) in words.enumerated() {
            let pillView = PillView(index: String(index + 1), title: word, origin: .zero)
            
            if index == 0 {
                mnemonicHolderView.addSubview(pillView)
                
                originX += pillView.frame.size.width
            } else {
                if originX + pillView.frame.width > view.frame.width - 32 - pillView.horizontalSpacing {
                    originY += pillView.verticalSpacing
                    originX = 0.0
                } else {
                    originX += pillView.horizontalSpacing
                }
                
                pillView.frame.origin = CGPoint(x: originX, y: originY)
                
                mnemonicHolderView.addSubview(pillView)
                
                originX += pillView.frame.size.width
            }
        }
    }
}

