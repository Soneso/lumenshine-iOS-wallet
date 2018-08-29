//
//  LostSecurityViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol LostSecurityContentViewProtocol {
    func present(error: ServiceError)
}

class LostSecurityViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: LostSecurityViewModelType
    
    // MARK: - UI properties
    fileprivate let headerBar = ToolbarHeader()
    
    fileprivate var contentView: LostSecurityContentViewProtocol?
    
    init(viewModel: LostSecurityViewModelType) {
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
        showLostSecurity()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setupContentView(_ contentView: LostSecurityContentViewProtocol) {
        if let content = contentView as? UIView {
            let animation = CATransition()
            animation.duration = 0.3
            animation.type = kCATransitionMoveIn
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            content.layer.add(animation, forKey: kCATransitionMoveIn)
            
            if let oldContent = self.contentView as? UIView {
                oldContent.removeFromSuperview()
            }
            view.addSubview(content)
            content.snp.makeConstraints { make in
                make.top.equalTo(headerBar.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.lessThanOrEqualTo(-50)
            }
            
            self.contentView = contentView
        }
    }
    
    func showLostSecurity() {
        let contentView = LostSecurityView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
    }
    
    func showEmailConfirmation() {
        let contentView = EmailConfirmationView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        snackbarController?.snackbar.text = R.string.localizable.confirmation_mail_resent()
    }
    
    func showSuccess() {
        let contentView = LostSecuritySuccessView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
        snackbarController?.snackbar.text = R.string.localizable.email_resent()
    }
}

extension LostSecurityViewController: LostSecurityViewDelegate {
    func didTapNextButton(email: String?) {
        self.lostSecurity(email: email)
    }
}

extension LostSecurityViewController: HeaderMenuDelegate {
    func menuSelected(at index: Int) {
        
    }
}

extension LostSecurityViewController: EmailConfirmationViewDelegate {
    func didTapResendButton() {
        viewModel.resendMailConfirmation { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.snackbarController?.animate(snackbar: .visible, delay: 0)
                    self?.snackbarController?.animate(snackbar: .hidden, delay: 3)
                case .failure(let error):
                    self?.contentView?.present(error: error)
                }
            }
        }
    }
    
    func didTapDoneButton(email: String?) {
        self.lostSecurity(email: email)
    }
}

extension LostSecurityViewController: LostSecuritySuccessViewDelegate {
    func didTapResendButton(email: String?) {
        showActivity()
        viewModel.lostSecurity(email: email) { [weak self] result in
            self?.hideActivity(completion: {
                switch result {
                case .success:
                    self?.snackbarController?.animate(snackbar: .visible, delay: 0)
                    self?.snackbarController?.animate(snackbar: .hidden, delay: 3)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self?.present(alert, animated: true)
                }
            })
        }
    }
}

extension LostSecurityViewController: ToolbarHeaderDelegate {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int) {
        viewModel.barItemSelected(at: index)
    }
}

fileprivate extension LostSecurityViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareHeader()
    }
    
    func prepareHeader() {
        headerBar.delegate = self
        headerBar.setTitle(viewModel.headerTitle)
        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setItems(viewModel.barItems, selectedAt: nil)
        
        view.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func lostSecurity(email: String?) {
        showActivity()
        viewModel.lostSecurity(email: email) { [weak self] result in
            self?.hideActivity(completion: {
                switch result {
                case .success:
                    self?.viewModel.showSuccess()
                case .failure(let error):
                    self?.contentView?.present(error: error)
                }
            })
        }
    }
}


