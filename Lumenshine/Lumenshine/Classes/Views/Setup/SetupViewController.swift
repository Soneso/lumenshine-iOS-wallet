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
        
        contentView.cornerRadiusPreset = .cornerRadius2
        contentView.depthPreset = .depth2
        contentView.backgroundColor = Stylesheet.color(.white)
        
        let topOffset = UIScreen.main.scale > 2 ? 25 : 10
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(topOffset)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-50)
            make.width.equalTo(view).offset(-20)
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
        
        let label = UILabel()
        label.text = R.string.localizable.powered_by().uppercased()
        label.textColor = Stylesheet.color(.gray)
        label.font = R.font.encodeSansRegular(size: 8.5)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top).offset(-5)
        }
    }
}
