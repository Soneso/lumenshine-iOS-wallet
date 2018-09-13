//
//  SetupViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SetupViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: SetupViewModelType
    
    // MARK: - UI properties
    fileprivate let headerBar = TitleHeader()
    fileprivate let scrollView = UIScrollView()
    let contentView = UIView()
    
    class func initialize(viewModel: SetupViewModelType) -> SetupViewController? {
        
        switch viewModel.setupStep() {
        case .TFA:
            return TFASetupViewController(viewModel: viewModel)
        case .email:
            return EmailSetupViewController(viewModel: viewModel)
        case .mnemonic:
            return MnemonicSetupViewController(viewModel: viewModel)
        default:
            return nil
        }
    }
    
    init(viewModel: SetupViewModelType) {
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
    
}

extension SetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return resignFirstResponder()
    }
}

fileprivate extension SetupViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareHeader()
        prepareCopyright()
        prepareContentView()
    }
    
    func prepareHeader() {
        headerBar.setTitle(viewModel.headerTitle)
        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setHeader(viewModel.headerText)
        
        view.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func prepareContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
        contentView.cornerRadiusPreset = .cornerRadius4
        contentView.depthPreset = .depth3
        contentView.backgroundColor = Stylesheet.color(.white)
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-60)
            make.width.equalTo(view).offset(-30)
        }
    }
    
    func prepareCopyright() {
        let imageView = UIImageView(image: R.image.soneso())
        imageView.backgroundColor = Stylesheet.color(.clear)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
        }
        
        let background = UIImageView(image: R.image.soneso_background())
        background.contentMode = .scaleAspectFit
        
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(headerBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top)
        }
    }
}
