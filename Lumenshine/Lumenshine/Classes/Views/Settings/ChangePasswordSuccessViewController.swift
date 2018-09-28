//
//  ChangePasswordSuccessViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ChangePasswordSuccessViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    fileprivate let titleLabel = UILabel()
    fileprivate let submitButton = RaisedButton()
    
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: SettingsViewModelType) {
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

// MARK: - Action for checking username/password
extension ChangePasswordSuccessViewController {
    @objc
    func submitAction(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

fileprivate extension ChangePasswordSuccessViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        navigationItem.titleLabel.text = viewModel.successHeader
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        prepareTitleLabel()
        prepareButton()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = viewModel.successTitle
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.color(.green)
        titleLabel.font = R.font.encodeSansSemiBold(size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareButton() {
        submitButton.title = R.string.localizable.done().uppercased()
        submitButton.titleColor = Stylesheet.color(.white)
        submitButton.backgroundColor = Stylesheet.color(.cyan)
        submitButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        submitButton.cornerRadiusPreset = .cornerRadius6
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(100)
            make.height.equalTo(38)
        }
    }
}

