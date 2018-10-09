//
//  WalletCard.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit

enum WalletStatus {
    case funded
    case unfunded
}

enum WalletAction {
    case receive
    case send
    case transactionResult
}

protocol WalletCardProtocol {
    
}

protocol WalletActionsProtocol: class {
    var wallet: Wallet! { get set }
    var closeAction: (() -> ())? { get set }
}

class WalletCard: CardView {
    
    var fundedView: WalletCardContentView?
    var unfundedView: UnfundedWalletCardContentView?
    var viewController: UIViewController?
    
    var reloadCellAction: (() -> ())?
    var expanded = false
    
    fileprivate let textLabel = UILabel()
    //fileprivate let contentStackView = UIStackView()
    fileprivate let collapsedContainer = UIView()
    fileprivate let expandedContainer = UIView()
    fileprivate var paymentOperationsVCManager: PaymentOperationsVCManager!
    override var viewModel: CardViewModelType? {
        didSet {
            if let viewModel = viewModel as? WalletCardViewModel {
                viewModel.receivePaymentAction = {
                    self.setupPaymentOperationsVCManager()
                    self.paymentOperationsVCManager.addViewController(forAction: WalletAction.receive, wallet: self.wallet)
                }
                
                viewModel.sendAction = {
                    self.setupPaymentOperationsVCManager()
                    self.paymentOperationsVCManager.addViewController(forAction: WalletAction.send, wallet: self.wallet)
                }
            }
        }
    }
    
    var status: WalletStatus! {
        didSet {
            switch status {
            case .funded?:
                addFundedView()
            case .unfunded?:
                addUnfundedView()
            default:
                print("error")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    
    // TODO: viewModel data is not updated, refresh after update in details
    func reloadData() {
        if let viewModel = self.viewModel as? WalletCardViewModel {
            if let fundedView = self.fundedView {
                fundedView.nameLabel.text = viewModel.title?.uppercased()
                fundedView.stellarAddressLabel.text = viewModel.wallet?.federationAddress
                fundedView.balanceDescriptionLabel.text = (viewModel.wallet as! FundedWallet).balances.count > 1 ? R.string.localizable.balances().uppercased() : R.string.localizable.balance().uppercased()
                fundedView.balanceLabel.text = viewModel.nativeBalance?.stringWithUnit
                fundedView.availableLabel.text = viewModel.nativeBalance?.availableAmount(forWallet: viewModel.wallet).stringWithUnit
            } else if let unfundedView = self.unfundedView {
                unfundedView.nameLabel.text = viewModel.title?.uppercased()
            }
        }
    }
    
    func setup(viewModel: WalletCardViewModel) {
        
        let buttonFont = R.font.encodeSansSemiBold(size: 15)
        let buttonColor = Stylesheet.color(.darkBlue)
        
        if let fundedView = self.fundedView {
            
            fundedView.nameLabel.font = R.font.encodeSansBold(size: 16)
            fundedView.nameLabel.textColor = Stylesheet.color(.lightBlack)
            fundedView.nameLabel.text = viewModel.title?.uppercased()
            
            fundedView.walletLabel.font = R.font.encodeSansRegular(size: 16)
            fundedView.walletLabel.textColor = Stylesheet.color(.lightBlack)
            
            fundedView.stellarAddressLabel.font = R.font.encodeSansRegular(size: 15)
            fundedView.stellarAddressLabel.textColor = Stylesheet.color(.orange)
            fundedView.stellarAddressLabel.text = viewModel.wallet?.federationAddress
            
            fundedView.balanceBackgroundView.backgroundColor = Stylesheet.color(.green)
            fundedView.balanceBackgroundView.layer.cornerRadius = 10
            
            fundedView.balanceDescriptionLabel.text = (viewModel.wallet as! FundedWallet).balances.count > 1 ? R.string.localizable.balances().uppercased() : R.string.localizable.balance().uppercased()
            fundedView.balanceDescriptionLabel.font = R.font.encodeSansSemiBold(size: 16)
            fundedView.balanceDescriptionLabel.textColor = Stylesheet.color(.white)
            
            let balanceLabelFont = R.font.encodeSansSemiBold(size: 15)
            let balanceLabelColor = Stylesheet.color(.white)
            fundedView.balanceLabel.text = viewModel.nativeBalance?.stringWithUnit
            fundedView.balanceLabel.font = balanceLabelFont
            fundedView.balanceLabel.textColor = balanceLabelColor
            
            CardView.labelsForCustomAssets(wallet: viewModel.wallet!, font: balanceLabelFont!, color: balanceLabelColor).forEach({ label in fundedView.balanceStackView.addArrangedSubview(label) })
            
            fundedView.availableDescriptionLabel.font = R.font.encodeSansSemiBold(size: 16)
            fundedView.availableDescriptionLabel.text = R.string.localizable.available().uppercased()
            fundedView.availableDescriptionLabel.textColor = Stylesheet.color(.blue)
            
            let availableLabelFont = R.font.encodeSansRegular(size: 15)
            let availableLabelColor = Stylesheet.color(.black)
            
            fundedView.availableLabel.text = viewModel.nativeBalance?.availableAmount(forWallet: viewModel.wallet).stringWithUnit
            fundedView.availableLabel.font = availableLabelFont
            fundedView.availableLabel.textColor = availableLabelColor
            
            CardView.labelsForCustomAssets(wallet: viewModel.wallet!, font: availableLabelFont!, color: availableLabelColor).forEach({ label in fundedView.availableStackView.addArrangedSubview(label) })
            
            fundedView.helpButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapHelpButton), for: .touchUpInside)
            fundedView.helpButton.tintColor = Stylesheet.color(.gray)
            
            fundedView.sendButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapSendButton), for: .touchUpInside)
            fundedView.sendButton.titleLabel?.font = buttonFont
            fundedView.sendButton.setTitleColor(buttonColor, for: UIControlState.normal)
            
            fundedView.receiveButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapReceiveButton), for: .touchUpInside)
            fundedView.receiveButton.titleLabel?.font = buttonFont
            fundedView.receiveButton.setTitleColor(buttonColor, for: UIControlState.normal)
            
            fundedView.detailsButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapDetailsButton), for: .touchUpInside)
            fundedView.detailsButton.titleLabel?.font = buttonFont
            fundedView.detailsButton.setTitleColor(buttonColor, for: UIControlState.normal)
            
        }
        
        if let unfundedView = self.unfundedView {
            
            unfundedView.nameLabel.font = R.font.encodeSansBold(size: 16)
            unfundedView.nameLabel.textColor = Stylesheet.color(.lightBlack)
            unfundedView.nameLabel.text = viewModel.title?.uppercased()
            
            unfundedView.walletLabel.font = R.font.encodeSansRegular(size: 16)
            unfundedView.walletLabel.textColor = Stylesheet.color(.lightBlack)
            
            unfundedView.notFundedLabel.font = R.font.encodeSansRegular(size: 15)
            unfundedView.notFundedLabel.textColor = Stylesheet.color(.red)
            
            unfundedView.balanceBackgroundView.backgroundColor = Stylesheet.color(.red)
            unfundedView.balanceBackgroundView.layer.cornerRadius = 10
            
            unfundedView.balanceDescriptionLabel.font = R.font.encodeSansSemiBold(size: 16)
            unfundedView.balanceDescriptionLabel.text = R.string.localizable.balance().uppercased()
            unfundedView.balanceDescriptionLabel.textColor = Stylesheet.color(.white)
            
            unfundedView.balanceLabel.font = R.font.encodeSansSemiBold(size: 15)
            unfundedView.balanceLabel.textColor = Stylesheet.color(.white)
            
            unfundedView.helpButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapHelpButton), for: .touchUpInside)
            unfundedView.helpButton.tintColor = buttonColor
            
            unfundedView.fundButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapFundButton), for: .touchUpInside)
            unfundedView.fundButton.titleLabel?.font = buttonFont
            unfundedView.fundButton.setTitleColor(buttonColor, for: UIControlState.normal)
            
        }
    }
}

fileprivate extension WalletCard {
    func prepare() {
        addContainers()
    }
    
    func addContainers() {
        collapsedContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collapsedContainer)
        expandedContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expandedContainer)
        
        collapsedContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collapsedContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        collapsedContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        expandedContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        expandedContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        let topAnchor = expandedContainer.topAnchor.constraint(equalTo: collapsedContainer.bottomAnchor)
        topAnchor.priority = .defaultHigh
        topAnchor.isActive = true
        expandedContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        let heightConstraint = expandedContainer.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
    }
    
    func addFundedView() {
        fundedView = Bundle.main.loadNibNamed("WalletCardContentView", owner: nil, options: nil)![0] as? WalletCardContentView
        fundedView!.frame = contentView.bounds
        fundedView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collapsedContainer.addSubview(fundedView!)
    }
    
    func addUnfundedView() {
        unfundedView = Bundle.main.loadNibNamed("UnfundedWalletCardContentView", owner: nil, options: nil)![0] as? UnfundedWalletCardContentView
        unfundedView!.frame = contentView.bounds
        unfundedView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collapsedContainer.addSubview(unfundedView!)
    }
    
    private var wallet: FundedWallet {
        get {
            return ((viewModel as! WalletCardViewModel).wallet as! FundedWallet)
        }
    }
}
