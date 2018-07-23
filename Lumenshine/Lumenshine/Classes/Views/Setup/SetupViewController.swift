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

fileprivate extension SetupViewController {
    func prepareView() {
        prepareHeader()
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
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(view)
        }
    }
}
