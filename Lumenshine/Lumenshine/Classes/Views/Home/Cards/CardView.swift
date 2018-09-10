//
//  CardView.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit
import stellarsdk

protocol CardProtocol {
    func setBottomBar(buttons: [Button]?)
}

public enum BalanceLabelDescription: String {
    case onlyNative = "Balance"
    case extended = "Balances"
}

class CardView: UIView {
    internal let contentView = UIView()
    internal let bottomBar = Bar()
    
    internal var viewModel: CardViewModelType? {
        didSet {
            let buttons = viewModel?.bottomTitles?.map { title -> FlatButton in
                let button = FlatButton(title: title)
                button.addTarget(self, action: #selector(barButtonClick(_:)), for: .touchUpInside)
                return button
            }
            setBottomBar(buttons: buttons)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func create(viewModel:CardViewModelType, viewController: UIViewController) -> CardView {
        var card: CardView
        switch viewModel.type {
        case .web:
             card = WebCard()
        case .chart:
            card = ChartCard()
            card.viewModel = viewModel
        case .intern:
            card = InternalCard()
        case .account:
            card = InternalCard()
        case .wallet(let status):
            let walletCard = WalletCard()
            walletCard.status = status
            walletCard.viewController = viewController
            CardView.setupWalletCard(card: walletCard, viewModel: viewModel as! WalletCardViewModel)
            
            card = walletCard
            
        }
        card.viewModel = viewModel
        return card
    }
    
    @objc
    func barButtonClick(_ sender: FlatButton) {
        viewModel?.barButtonSelected(at: sender.tag)
    }
    
    class func setupWalletCard(card: WalletCard, viewModel: WalletCardViewModel) {
        if let fundedView = card.fundedView {
            fundedView.sendButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapSendButton), for: .touchUpInside)
            fundedView.receiveButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapReceiveButton), for: .touchUpInside)
            fundedView.detailsButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapDetailsButton), for: .touchUpInside)
            fundedView.helpButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapHelpButton), for: .touchUpInside)
            fundedView.nameLabel.text = viewModel.title
            fundedView.balanceLabel.text = viewModel.nativeBalance?.stringWithUnit
            fundedView.balanceDescriptionLabel.text = (viewModel.wallet as! FoundedWallet).balances.count > 1 ? BalanceLabelDescription.extended.rawValue : BalanceLabelDescription.onlyNative.rawValue
            CardView.labelsForCustomAssets(wallet: viewModel.wallet!).forEach({ label in fundedView.balanceStackView.addArrangedSubview(label) })
            fundedView.availableLabel.text = viewModel.nativeBalance?.availableAmount.stringWithUnit
            CardView.labelsForCustomAssets(wallet: viewModel.wallet!).forEach({ label in fundedView.availableStackView.addArrangedSubview(label) })
        }
        
        if let unfundedView = card.unfundedView {
            unfundedView.fundButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapFundButton), for: .touchUpInside)
            unfundedView.helpButton.addTarget(viewModel, action: #selector(WalletCardViewModel.didTapHelpButton), for: .touchUpInside)
            unfundedView.nameLabel.text = viewModel.title
        }
    }
    
    class func labelsForCustomAssets(wallet: Wallet) -> [UILabel] {
        var labels = [UILabel]()
        
        if let wallet = wallet as? FoundedWallet {
            for balance in wallet.balances {
                if balance.assetType != AssetTypeAsString.NATIVE {
                    let text = String(format: "%.2f \(balance.assetCode ?? balance.assetType)", CoinUnit(balance.balance)!)
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 15.0)
                    label.text = text
                    labels.append(label)
                }
            }
        }
        
        return labels
    }
}

extension CardView: CardProtocol {
    func setBottomBar(buttons: [Button]?) {
        bottomBar.rightViews = buttons ?? []
    }
}

fileprivate extension CardView {
    func prepare() {
        
        contentView.cornerRadiusPreset = .cornerRadius3
        contentView.clipsToBounds = true
        contentView.backgroundColor = Stylesheet.color(.white)
        
        depthPreset = .depth3
        backgroundColor = Stylesheet.color(.clear)
        
        addSubview(contentView)
        contentView.snp.makeConstraints {make in
            make.edges.equalToSuperview()
        }
        
        prepareBottomBar()
    }
    
    func prepareBottomBar() {
        contentView.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(45)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomBar.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}



