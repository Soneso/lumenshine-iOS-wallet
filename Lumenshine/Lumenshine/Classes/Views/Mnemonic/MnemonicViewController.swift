//
//  MnemonicViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class MnemonicViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: MnemonicViewModelType
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let mnemonicHolderView = UIView()
    fileprivate let nextButton = FlatButton()
    
    init(viewModel: MnemonicViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        generateMnemonic()
    }
    
    func setupView() {
        navigationItem.titleLabel.text = "Secret Phrase"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
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
    func confirmPhrase() {
        let verificationViewController = VerificationViewController(type: .questions, mnemonic: viewModel.mnemonic24Word)
        verificationViewController.delegate = self
        
        present(AppNavigationController(rootViewController:verificationViewController), animated: true, completion: nil)
    }
    
    @objc
    func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func generateMnemonic() {
        
        let mnemonic = viewModel.mnemonic24Word
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

extension MnemonicViewController: VerificationViewControllerDelegate {
    func verification(_ viewController: VerificationViewController, didFinishWithSuccess success: Bool) {
        if success {
            viewModel.confirmMnemonic { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let tfaResponse):
                        if tfaResponse.mailConfirmed == true,
                            tfaResponse.mnemonicConfirmed == true,
                            tfaResponse.tfaConfirmed == true {
                                self.viewModel.showDashboard()
                        }
                    case .failure(let error):
                        let alert = AlertFactory.createAlert(error: error)
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

