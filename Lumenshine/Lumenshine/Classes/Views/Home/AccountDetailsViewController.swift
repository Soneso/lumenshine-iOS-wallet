//
//  AccountDetailsViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 06/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol BaseViewControllerFlowDelegate: class {
    func backButtonPressed(from viewController:UIViewController)
    func closeButtonPressed(from viewController:UIViewController)
}

protocol AccountDetailsViewControllerFlow: BaseViewControllerFlowDelegate {
    
}

class AccountDetailsViewController: UIViewController {
    @IBOutlet weak var walletNameStackView: UIStackView!
    @IBOutlet var walletNameView: UIView!
    @IBOutlet var walletNameEditView: UIView!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletNameTextField: UITextField!
    
    weak var flowDelegate: AccountDetailsViewControllerFlow?
    
    private let walletService = Services.shared.walletService
    private var titleView: TitleView!
    
    var wallet: Wallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupWalletNameView()
    }
    
    // MARK: Actions
    
    @IBAction func didTapBack(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
    }
    
    @IBAction func didTapChangeWalletName(_ sender: Any) {
        walletNameView.removeFromSuperview()
        walletNameStackView.addArrangedSubview(walletNameEditView)
    }
    
    @IBAction func didTapCancelChangeWalletName(_ sender: Any) {
        walletNameEditView.removeFromSuperview()
        walletNameStackView.addArrangedSubview(walletNameView)
    }
    
    @IBAction func didTapSaveChangeWalletName(_ sender: Any) {
        var request = ChangeWalletRequest(id: wallet.id)
        request.walletName = walletNameTextField.text
        
        view.isUserInteractionEnabled = false
        walletService.changeWalletData(request: request) { (result) -> (Void) in
            switch result {
            case .success:
                self.view.isUserInteractionEnabled = true
                self.walletNameEditView.removeFromSuperview()
                self.walletNameStackView.addArrangedSubview(self.walletNameView)
                self.walletNameLabel.text = self.walletNameTextField.text
                self.walletNameTextField.placeholder = self.walletNameTextField.text
                self.titleView.label.text = "\(self.walletNameTextField.text ?? "")\nDetails"
            case .failure(let error):
                self.view.isUserInteractionEnabled = true
                let alertView = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                    alertView.dismiss(animated: true)
                })
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
            }
        }
    }
    
    // MARK: Private methods
    
    private func setupNavigationItem() {
        titleView = Bundle.main.loadNibNamed("TitleView", owner:self, options:nil)![0] as! TitleView
        titleView.frame.size = titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        titleView.label.text = "\(wallet.name)\nDetails"
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "arrow-left"), style:.plain, target: self, action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named: "question"), style:.plain, target: self, action: #selector(didTapHelp(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
    }
    
    private func setupWalletNameView() {
        walletNameEditView.removeFromSuperview()
        walletNameLabel.text = wallet.name
        walletNameTextField.placeholder = wallet.name
    }
    
}
