//
//  AccountDetailsViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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

private enum ActionButtonTitles: String {
    case setAddress = "SET"
    case removeAddress = "REMOVE"
    case changeAddress = "CHANGE"
    case cancel = "CANCEL"
}

class AccountDetailsViewController: UpdatableViewController {
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
    @IBOutlet weak var stellarAddressNoneLabel: UILabel!
    
    @IBOutlet weak var saveWalletNameButton: UIButton!
    @IBOutlet weak var cancelWalletNameButton: UIButton!
    
    @IBOutlet weak var submitInflationChangeButton: UIButton!
    weak var flowDelegate: AccountDetailsViewControllerFlow?
    
    private let walletService = Services.shared.walletService
    private var titleView: TitleView!
    private var accountCurrenciesViewController: AccountCurrenciesViewController!
    private let walletManager = WalletManager()
    
    private var userManager: UserManager {
        get {
            return Services.shared.userManager
        }
    }
    
    @IBOutlet weak var stellarAddressActionbutton: UIButton!
    @IBOutlet weak var showOnHomescreenSwitch: UISwitch!
    
    @IBAction func showOnHomescreenSwitchValueChanged(_ sender: UISwitch) {
        if let walletID = wallet?.id {
            walletService.setWalletHomescreen(walletID: walletID, isVisible: sender.isOn) { (response) -> (Void) in
                switch response {
                case .success:
                    (self.wallet as? FundedWallet)?.showOnHomescreen = sender.isOn
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func didTapStellarAddressActionButton(_ sender: UIButton) {
        if let buttonTitle = stellarAddressActionbutton.title(for: .normal) {
            if buttonTitle == ActionButtonTitles.removeAddress.rawValue {
                removeStellarAddress()
                return
            }

            if  buttonTitle == ActionButtonTitles.cancel.rawValue {
                setStellarAddressView()
                return
            }
            
            stellarAddressNotSetupView.removeFromSuperview()
            stellarAddressEditTextField.text = nil
            stellarAddressEditErrorLabel.text = nil
            stellarAddressStackView.addArrangedSubview(stellarAddressEditView)
            
            if buttonTitle == ActionButtonTitles.changeAddress.rawValue {
                setupStellarAddressActionButton(withTitle: .removeAddress)
            } else {
                setupStellarAddressActionButton(withTitle: .cancel)
            }
        }
    }
    
    var wallet: Wallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupWalletNameView()
        setupPublicKeyView()
        setupStellarAddress()
        setupAccountCurrency()
        setupWalletDetails()
        setupTransactionsHistory()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        setupButtons()
        setupShowOnHomescreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                if let name = self.walletNameTextField.text {
                    self.wallet.name = name
                    Services.shared.walletService.addWalletToRefresh(accountId: self.wallet.publicKey)
                }
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
            let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
            self.present(alert, animated: true)
            let when = DispatchTime.now() + 0.75
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func didTapSubmitEditStellarAddress(_ sender: Any) {
        stellarAddressEditErrorLabel.text = nil
        if stellarAddressEditTextField.text?.isMandatoryValid() == false {
            stellarAddressEditErrorLabel.text = "Stellar address can not be empty"
            return
        }
        
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
                self.wallet.federationAddress = stellarAddress
                self.setupStellarAddressActionButton(withTitle: .changeAddress)
                Services.shared.walletService.addWalletToRefresh(accountId: self.wallet.publicKey)
            case .failure(let error):
                self.stellarAddressEditErrorLabel.text = error.localizedDescription
            }
        }
    }
    
    private func removeStellarAddress() {
        view.isUserInteractionEnabled = false
        walletService.removeFederationAddress(walletId: wallet.id) { (result) -> (Void) in
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success:
                self.stellarAddressRemoveView.removeFromSuperview()
                self.stellarAddressStackView.addArrangedSubview(self.stellarAddressNotSetupView)
                self.wallet.federationAddress = ""
                self.setStellarAddressView()
                Services.shared.walletService.addWalletToRefresh(accountId: self.wallet.publicKey)
            case .failure(let error):
                self.stellarAddressEditErrorLabel.text = error.localizedDescription
            }
        }
    }
    
    
    // MARK: Private methods
    
    private func setupShowOnHomescreen() {
        if let fundedWallet = wallet as? FundedWallet {
            showOnHomescreenSwitch.isOn = fundedWallet.showOnHomescreen
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        let walletName = NSMutableAttributedString(string: wallet.name, attributes: [ NSAttributedStringKey.font: R.font.encodeSansSemiBold(size: 15) ?? Font.systemFont(ofSize: 15) ])
        let subTitle = NSMutableAttributedString(string: "\nDetails", attributes: [ NSAttributedStringKey.font: R.font.encodeSansSemiBold(size: 13) ?? Font.systemFont(ofSize: 13) ])
        walletName.append(subTitle)
        navigationItem.titleLabel.numberOfLines = 2
        navigationItem.titleLabel.attributedText = walletName
        
        /*let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 25, toHeight: 25)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]*/
    }
    
    private func setupWalletNameView() {
        
        walletNameEditView.removeFromSuperview()
        walletNameLabel.text = wallet.name
        walletNameTextField.placeholder = wallet.name
    
    }
    
    private func setupPublicKeyView() {
        publicKeyLabel.text = wallet.publicKey
        publicKeyLabel.font = R.font.encodeSansSemiBold(size: 15)
        publicKeyLabel.numberOfLines = 1
        publicKeyLabel.lineBreakMode = .byTruncatingMiddle
    }
    
    private func setupStellarAddress() {
        federationDomainLabel.backgroundColor = Stylesheet.color(.helpButtonGray)
        removeViewAddressLabel.backgroundColor = Stylesheet.color(.orange)
        federationDomainLabel.text = "*" + Services.shared.federationDomain
        
        if wallet.federationAddress.isEmpty {
            stellarAddressEditView.removeFromSuperview()
            stellarAddressRemoveView.removeFromSuperview()
            setupStellarAddressActionButton(withTitle: .setAddress)
        } else {
            removeViewAddressLabel.text = wallet.federationAddress
            stellarAddressNotSetupView.removeFromSuperview()
            stellarAddressEditView.removeFromSuperview()
            setupStellarAddressActionButton(withTitle: .changeAddress)
        }
        
        stellarAddressNoneLabel.backgroundColor = Stylesheet.color(.helpButtonGray)
    }
    
    private func setupStellarAddressActionButton(withTitle title: ActionButtonTitles) {
        switch title {
        case .setAddress, .changeAddress:
            stellarAddressActionbutton.tintColor = Stylesheet.color(.blue)
        case .removeAddress:
            stellarAddressActionbutton.tintColor = Stylesheet.color(.red)
        case .cancel:
            stellarAddressActionbutton.tintColor = Stylesheet.color(.orange)
        }
        
        stellarAddressActionbutton.setTitle(title.rawValue, for: .normal)
    }
    
    private func setStellarAddressView() {
        stellarAddressEditView.removeFromSuperview()
        if wallet.federationAddress.isEmpty {
            stellarAddressStackView.addArrangedSubview(stellarAddressNotSetupView)
            setupStellarAddressActionButton(withTitle: .setAddress)
        } else {
            stellarAddressStackView.addArrangedSubview(stellarAddressRemoveView)
            setupStellarAddressActionButton(withTitle: .changeAddress)
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
        walletDetailsContainer.subviews.forEach({ $0.removeFromSuperview() })
        
        setupWalletDetails()
        setupAccountCurrency()
        setupWalletDetails()
        setupTransactionsHistory()
    }
    
    private func setupButtons() {
        saveWalletNameButton.backgroundColor = Stylesheet.color(.blue)
        submitInflationChangeButton.backgroundColor = Stylesheet.color(.blue)
        
        cancelWalletNameButton.backgroundColor = Stylesheet.color(.red)
    }
    
    override func updateUIAfterWalletRefresh(notification: NSNotification) {
        if let updatedWallet = notification.object as? Wallet, updatedWallet.publicKey == wallet.publicKey {
            wallet = updatedWallet
        }
        DispatchQueue.main.async {
            self.reloadWalletDetails()
        }
    }
}
