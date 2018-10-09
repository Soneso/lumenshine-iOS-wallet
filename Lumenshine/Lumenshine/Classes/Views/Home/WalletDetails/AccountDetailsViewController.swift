//
//  AccountDetailsViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 06/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

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
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    
    @IBOutlet weak var stellarAddressStackView: UIStackView!
    @IBOutlet var stellarAddressNotSetupView: UIView!
    @IBOutlet var stellarAddressEditView: UIView!
    @IBOutlet var stellarAddressRemoveView: UIView!
    
    @IBOutlet weak var stellarAddressEditErrorLabel: UILabel!
    @IBOutlet weak var stellarAddressEditTextField: UITextField!
    @IBOutlet weak var removeViewAddressLabel: UILabel!
    
    @IBOutlet weak var accountCurrencyContainer: UIView!
    @IBOutlet weak var transactionsHistoryContainer: UIView!
    @IBOutlet weak var walletDetailsContainer: UIView!
    
    @IBOutlet weak var federationDomainLabel: UILabel!
    
    weak var flowDelegate: AccountDetailsViewControllerFlow?
    
    private let walletService = Services.shared.walletService
    private var titleView: TitleView!
    private var accountCurrenciesViewController: AccountCurrenciesViewController!
    
    var wallet: Wallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupWalletNameView()
        publicKeyLabel.text = wallet.publicKey
        setupStellarAddress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadWalletDetails()
    }
    
    // MARK: Actions
    
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
//                self.titleView.label.text = (self.walletNameTextField.text ?? "") + "\nDetails"
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
    
    @IBAction func didTapCopyPublicKey(_ sender: Any) {
        if let key = publicKeyLabel.text {
            UIPasteboard.general.string = key
        }
    }
    
    @IBAction func didTapSetAddress(_ sender: Any) {
        stellarAddressNotSetupView.removeFromSuperview()
        stellarAddressStackView.addArrangedSubview(stellarAddressEditView)
    }
    
    @IBAction func didTapCancelEditStellarAddress(_ sender: Any) {
        setStellarAddressView()
    }
    
    @IBAction func didTapSubmitEditStellarAddress(_ sender: Any) {
        var request = ChangeWalletRequest(id: wallet.id)
        let stellarAddress = (stellarAddressEditTextField.text ?? "") + federationDomainLabel.text!
        request.federationAddress = stellarAddress
        
        view.isUserInteractionEnabled = false
        walletService.changeWalletData(request: request) { (result) -> (Void) in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success:
                self.removeViewAddressLabel.text = stellarAddress
                self.stellarAddressEditView.removeFromSuperview()
                self.stellarAddressStackView.addArrangedSubview(self.stellarAddressRemoveView)
            case .failure(let error):
                self.stellarAddressEditErrorLabel.text = error.localizedDescription
            }
        }
    }
    
    @IBAction func didTapRemoveStellarAddress(_ sender: Any) {
        view.isUserInteractionEnabled = false
        walletService.removeFederationAddress(walletId: wallet.id) { (result) -> (Void) in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success:
                self.stellarAddressRemoveView.removeFromSuperview()
                self.stellarAddressStackView.addArrangedSubview(self.stellarAddressNotSetupView)
            case .failure(let error):
                self.stellarAddressEditErrorLabel.text = error.localizedDescription
            }
        }
    }
    
    
    // MARK: Private methods
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "\(wallet.name)\nDetails"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]
    }
    
    private func setupWalletNameView() {
        walletNameEditView.removeFromSuperview()
        walletNameLabel.text = wallet.name
        walletNameTextField.placeholder = wallet.name
    }
    
    private func setupStellarAddress() {
        
        federationDomainLabel.text = "*lumenshine.com"
        
        /** live net **/
        //federationDomainLabel.text = "*alpha.lumenshine.com"
        
        if wallet.federationAddress.isEmpty {
            stellarAddressEditView.removeFromSuperview()
            stellarAddressRemoveView.removeFromSuperview()
        } else {
            removeViewAddressLabel.text = wallet.federationAddress
            stellarAddressNotSetupView.removeFromSuperview()
            stellarAddressEditView.removeFromSuperview()
        }
    }
    
    private func setStellarAddressView() {
        stellarAddressEditView.removeFromSuperview()
        if wallet.federationAddress.isEmpty {
            stellarAddressStackView.addArrangedSubview(stellarAddressNotSetupView)
        } else {
            stellarAddressStackView.addArrangedSubview(stellarAddressRemoveView)
        }
    }
    
    private func setupAccountCurrency() {
        let viewController = AccountCurrenciesViewController(nibName: "AccountCurrenciesViewController", bundle: Bundle.main)
        if let wallet = wallet as? FundedWallet {
            viewController.wallet = wallet
        }
        
        addChildViewController(viewController)
        accountCurrencyContainer.addSubview(viewController.view)
        viewController.view.snp.makeConstraints {make in
            make.edges.equalToSuperview()
        }
        viewController.didMove(toParentViewController: self)
    }
    
    private func setupTransactionsHistory() {
        let viewController = TransactionHistoryTableViewController(nibName: "TransactionHistoryTableViewController", bundle: Bundle.main)
        if let wallet = wallet as? FundedWallet {
            viewController.wallet = wallet
        }
        
        addChildViewController(viewController)
        transactionsHistoryContainer.addSubview(viewController.view)
        viewController.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func setupWalletDetails() {
        let viewController = WalletDetailsViewController(nibName: "WalletDetailsViewController", bundle: Bundle.main)
        if let wallet = wallet as? FundedWallet {
            viewController.wallet = wallet
        }
        
        addChildViewController(viewController)
        walletDetailsContainer.addSubview(viewController.view)
        viewController.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func reloadWalletDetails() {
        accountCurrencyContainer.subviews.forEach({ $0.removeFromSuperview() })
        walletDetailsContainer.subviews.forEach({ $0.removeFromSuperview() })
        transactionsHistoryContainer.subviews.forEach({ $0.removeFromSuperview() })
        
        setupAccountCurrency()
        setupWalletDetails()
        setupTransactionsHistory()
    }
}
