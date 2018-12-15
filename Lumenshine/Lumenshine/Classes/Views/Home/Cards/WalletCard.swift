//
//  WalletCard.swift
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
import SnapKit

enum WalletAction {
    case receive
    case send
    case transactionResult
    case deposit
}

protocol WalletCardProtocol {
    
}

protocol WalletActionsProtocol: class {
    var walletsList: [Wallet]! { get set }
    var closeAction: (() -> ())? { get set }
}

class WalletCard: CardView {
    
    var fundedView: WalletCardContentView?
    var unfundedView: UnfundedWalletCardContentView?
    weak var viewController: UIViewController?
    
    var reloadCellAction: ((Bool) -> ())?
    var expanded = false
    
    fileprivate let textLabel = UILabel()
    
    fileprivate var paymentOperationsVCManager: PaymentOperationsVCManager!
    override var viewModel: CardViewModelType? {
        didSet {
            if let viewModel = viewModel as? WalletCardViewModel {
                viewModel.receivePaymentAction = { [weak self] in
                    if let wallet = self?.wallet {
                        self?.setupPaymentOperationsVCManager()
                        self?.paymentOperationsVCManager.addViewController(forAction: WalletAction.receive, wallets: [wallet])
                    }
                }
                
                viewModel.sendAction = { [weak self] in
                    if let wallet = self?.wallet {
                        self?.setupPaymentOperationsVCManager()
                        self?.paymentOperationsVCManager.addViewController(forAction: WalletAction.send, wallets: [wallet])
                    }
                }
                
                viewModel.depositAction = { [weak self] in
                    if let wallet = self?.wallet {
                        self?.setupPaymentOperationsVCManager()
                        self?.paymentOperationsVCManager.addViewController(forAction: WalletAction.deposit, wallets: [wallet])
                    }
                }
                
                viewModel.reloadClosure = { reload in
                    DispatchQueue.main.async {
                        self.reloadData(reload)
                    }
                }
            }
        }
    }

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addEmptyWallet()
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPaymentOperationsVCManager() {
        if self.paymentOperationsVCManager == nil {
            if let viewController = self.viewController {
                self.paymentOperationsVCManager = PaymentOperationsVCManager(parentViewController: viewController)
            }
        }
    }
    
    func setWalletCardStatus(status: WalletStatus, viewModel: WalletCardViewModel) {
        switch status {
        case .none:
            addEmptyWallet()
        case .funded:
            addFundedView(viewModel:viewModel)
        case .unfunded:
            addUnfundedView(viewModel:viewModel)
        }
    }
    func reloadData(_ reload: Bool) {
        if let viewModel = self.viewModel as? WalletCardViewModel {           
            unfundedView?.removeFromSuperview()
            fundedView?.removeFromSuperview()
            let nstatus = (viewModel.wallet.isFunded) ? WalletStatus.funded : WalletStatus.unfunded
            setWalletCardStatus(status: nstatus, viewModel: viewModel)
            self.setup(viewModel: viewModel)
            self.reloadCellAction?(reload)
        }
    }
    
    func setup(viewModel: WalletCardViewModel) {
        
        if let fundedView = self.fundedView {
            
            let balanceLabelFont = R.font.encodeSansSemiBold(size: 15)
            let balanceLabelColor = Stylesheet.color(.white)

            let availableLabelFont = R.font.encodeSansRegular(size: 15)
            let availableLabelColor = Stylesheet.color(.black)
            
            fundedView.nameLabel.text = viewModel.title?.uppercased()
            if !viewModel.wallet.federationAddress.isEmpty {
                fundedView.stellarAddressLabel.text = viewModel.wallet.federationAddress
                fundedView.stellarAddressLabel.backgroundColor = Stylesheet.color(.orange)
            }
            
            fundedView.balanceDescriptionLabel.text = (viewModel.wallet as! FundedWallet).balances.count > 1 ? R.string.localizable.balances().uppercased() : R.string.localizable.balance().uppercased()
            fundedView.balanceLabel.text = "\(viewModel.nativeBalance?.stringWithUnit ?? "0.00") XLM"
            fundedView.availableLabel.text = "\(viewModel.nativeBalance?.availableAmount(forWallet: viewModel.wallet, forCurrency: (viewModel.wallet as? FundedWallet)?.nativeAsset).stringWithUnit ?? "0.00") XLM"
            fundedView.currencyInfoButton.currency = (viewModel.wallet as? FundedWallet)?.nativeAsset
            fundedView.currencyInfoButton.wallet = (viewModel.wallet as? FundedWallet)
            fundedView.currencyInfoButton.isHidden = viewModel.nativeBalance == viewModel.nativeBalance?.availableAmount(forWallet: viewModel.wallet, forCurrency: (viewModel.wallet as? FundedWallet)?.nativeAsset)
            
            CardView.labelsForCustomAssets(wallet: viewModel.wallet, font: balanceLabelFont!, color: balanceLabelColor).forEach({ view in fundedView.balanceStackView.addArrangedSubview(view) })
            CardView.labelsForCustomAssets(wallet: viewModel.wallet, font: availableLabelFont!, color: availableLabelColor, forAvailable: true).forEach({ view in fundedView.availableStackView.addArrangedSubview(view) })
        }
        
        if let unfundedView = self.unfundedView {
            unfundedView.nameLabel.text = viewModel.title?.uppercased()
        }
    }
}

fileprivate extension WalletCard {
    func prepare() {
        
    }
    
    func addEmptyWallet() {
        
        guard let emptyView = Bundle.main.loadNibNamed("UnfundedWalletCardContentView", owner: nil, options: nil)![0] as? UnfundedWalletCardContentView else { return }
        
        emptyView.frame = contentView.bounds
        emptyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(emptyView)
        
        emptyView.nameLabel.font = R.font.encodeSansBold(size: 16)
        emptyView.nameLabel.textColor = Stylesheet.color(.lightBlack)
        
        emptyView.notFundedLabel.font = R.font.encodeSansRegular(size: 15)
        emptyView.notFundedLabel.textColor = Stylesheet.color(.orange)
        emptyView.notFundedLabel.text = R.string.localizable.no_stellar_address()
        
        emptyView.balanceBackgroundView.backgroundColor = Stylesheet.color(.white)
        emptyView.balanceBackgroundView.layer.cornerRadius = 10
        
        emptyView.balanceDescriptionLabel.font = R.font.encodeSansRegular(size: 16)
        emptyView.balanceDescriptionLabel.text =  R.string.localizable.loading()
        emptyView.balanceDescriptionLabel.textColor = Stylesheet.color(.lightBlack)
        
        emptyView.balanceLabel.font = R.font.encodeSansSemiBold(size: 15)
        emptyView.balanceLabel.textColor = Stylesheet.color(.white)
        emptyView.balanceLabel.text = ""
        
        emptyView.fundButton.isHidden = true
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingIndicator.startAnimating()
        
        emptyView.balanceBackgroundView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.right.equalTo(150)
        }
        
        self.unfundedView = emptyView
    }
    
    func addFundedView(viewModel: WalletCardViewModel) {
        guard let fundedView = Bundle.main.loadNibNamed("WalletCardContentView", owner: nil, options: nil)![0] as? WalletCardContentView else { return }
        
        fundedView.frame = contentView.bounds
        fundedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(fundedView)
        
        fundedView.nameLabel.font = R.font.encodeSansBold(size: 16)
        fundedView.nameLabel.textColor = Stylesheet.color(.lightBlack)
        
        fundedView.walletLabel.font = R.font.encodeSansRegular(size: 16)
        fundedView.walletLabel.textColor = Stylesheet.color(.lightBlack)
        
        fundedView.stellarAddressLabel.backgroundColor = Stylesheet.color(.helpButtonGray)
        
        fundedView.balanceBackgroundView.backgroundColor = Stylesheet.color(.green)
        fundedView.balanceBackgroundView.layer.cornerRadius = 10
        
        fundedView.balanceDescriptionLabel.font = R.font.encodeSansSemiBold(size: 16)
        fundedView.balanceDescriptionLabel.textColor = Stylesheet.color(.white)
        
        let balanceLabelFont = R.font.encodeSansSemiBold(size: 15)
        let balanceLabelColor = Stylesheet.color(.white)
        fundedView.balanceLabel.font = balanceLabelFont
        fundedView.balanceLabel.textColor = balanceLabelColor
        
        fundedView.availableDescriptionLabel.font = R.font.encodeSansSemiBold(size: 16)
        fundedView.availableDescriptionLabel.text = R.string.localizable.available().uppercased()
        fundedView.availableDescriptionLabel.textColor = Stylesheet.color(.blue)
        
        let availableLabelFont = R.font.encodeSansRegular(size: 15)
        let availableLabelColor = Stylesheet.color(.black)
        
        let buttonFont = R.font.encodeSansSemiBold(size: 15)
        let buttonColor = Stylesheet.color(.darkBlue)
        
        fundedView.availableLabel.font = availableLabelFont
        fundedView.availableLabel.textColor = availableLabelColor
        
        fundedView.depositButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapDepositButton), for: .touchUpInside)
        fundedView.depositButton.titleLabel?.font = buttonFont
        fundedView.depositButton.setTitleColor(buttonColor, for: UIControlState.normal)
        
        fundedView.sendButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapSendButton), for: .touchUpInside)
        fundedView.sendButton.titleLabel?.font = buttonFont
        fundedView.sendButton.setTitleColor(buttonColor, for: UIControlState.normal)
        
        fundedView.receiveButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapReceiveButton), for: .touchUpInside)
        fundedView.receiveButton.titleLabel?.font = buttonFont
        fundedView.receiveButton.setTitleColor(buttonColor, for: UIControlState.normal)
        
        fundedView.detailsButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapDetailsButton), for: .touchUpInside)
        fundedView.detailsButton.titleLabel?.font = buttonFont
        fundedView.detailsButton.setTitleColor(buttonColor, for: UIControlState.normal)
        
        self.fundedView = fundedView
    }
    
    func addUnfundedView(viewModel: WalletCardViewModel) {
        guard let unfundedView = Bundle.main.loadNibNamed("UnfundedWalletCardContentView", owner: nil, options: nil)![0] as? UnfundedWalletCardContentView else { return }
        
        unfundedView.frame = contentView.bounds
        unfundedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(unfundedView)
        
        unfundedView.nameLabel.font = R.font.encodeSansBold(size: 16)
        unfundedView.nameLabel.textColor = Stylesheet.color(.lightBlack)
        
        unfundedView.walletLabel.font = R.font.encodeSansRegular(size: 16)
        unfundedView.walletLabel.textColor = Stylesheet.color(.lightBlack)
        
        unfundedView.notFundedLabel.backgroundColor = Stylesheet.color(.helpButtonGray)
        
        unfundedView.balanceBackgroundView.backgroundColor = Stylesheet.color(.red)
        unfundedView.balanceBackgroundView.layer.cornerRadius = 10
        
        unfundedView.balanceDescriptionLabel.font = R.font.encodeSansSemiBold(size: 16)
        unfundedView.balanceDescriptionLabel.text = R.string.localizable.balance().uppercased()
        unfundedView.balanceDescriptionLabel.textColor = Stylesheet.color(.white)
        
        let buttonFont = R.font.encodeSansSemiBold(size: 15)
        let buttonColor = Stylesheet.color(.darkBlue)
        
        unfundedView.balanceLabel.font = R.font.encodeSansSemiBold(size: 15)
        unfundedView.balanceLabel.textColor = Stylesheet.color(.white)
        
        unfundedView.fundButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapFundButton), for: .touchUpInside)
        unfundedView.fundButton.titleLabel?.font = buttonFont
        unfundedView.fundButton.setTitleColor(buttonColor, for: UIControlState.normal)
        
        self.unfundedView = unfundedView
    }
    
    private var wallet: FundedWallet {
        get {
            return ((viewModel as! WalletCardViewModel).wallet as! FundedWallet)
        }
    }
}
