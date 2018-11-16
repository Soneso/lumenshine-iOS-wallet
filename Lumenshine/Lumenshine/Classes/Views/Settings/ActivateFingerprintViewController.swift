//
//  ActivateFingerprintViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/24/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ActivateFingerprintViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ReLoginViewModel
    
    // MARK: - UI properties
    
    fileprivate var contentView: ReLoginViewProtocol?
    
    init(viewModel: ReLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {R.string.localizable.loading()
        super.viewDidLoad()
        
        prepareView()
        prepareNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc
    func closeAction(sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ActivateFingerprintViewController: ReLoginFingerViewDelegate {
    func didTapActivateButton(password: String, tfaCode: String?) {
        showActivity(message: R.string.localizable.loading())
        viewModel.loginStep1(email: "", password: password, tfaCode: tfaCode, checkSetup: false) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success:
                        self?.dismiss(animated: true, completion: nil)
                    case .failure(let error):
                        _ = self?.contentView?.present(error: error)
                    }
                })
            }
        }
    }
}

fileprivate extension ActivateFingerprintViewController {
    func prepareView() {
        let content = ReLoginFingerView(viewModel: viewModel)
        content.delegate = self
        
        view.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        self.contentView = content
    }
    
    func prepareNavigationItem() {
        
        navigationItem.titleLabel.text = R.string.localizable.activate()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
