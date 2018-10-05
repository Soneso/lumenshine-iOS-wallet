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

class CardView: UIView {
    internal let contentView = UIView()
    internal let bottomBar = Bar()
    
    internal var viewModel: CardViewModelType? {
        didSet {
            let buttons = viewModel?.bottomTitles?.enumerated().map { (index, title) -> FlatButton in
                let button = FlatButton(title: title)
                button.tag = index
                button.titleColor = Stylesheet.color(.darkBlue)
                button.titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
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
        case .help:
            card = HelpCard()
        case .account:
            card = HelpCard()
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
        
        let buttonFont = R.font.encodeSansSemiBold(size: 15)
        let buttonColor = Stylesheet.color(.darkBlue)
        
        if let fundedView = card.fundedView {
            
            fundedView.nameLabel.font = R.font.encodeSansBold(size: 16)
            fundedView.nameLabel.textColor = Stylesheet.color(.lightBlack)
            fundedView.nameLabel.text = viewModel.title?.uppercased()
            
            fundedView.walletLabel.font = R.font.encodeSansRegular(size: 16)
            fundedView.walletLabel.textColor = Stylesheet.color(.lightBlack)
            
            fundedView.stellarAddressLabel.font = R.font.encodeSansRegular(size: 15)
            fundedView.stellarAddressLabel.textColor = Stylesheet.color(.orange)
            //fundedView.stellarAddressLabel.text = "chris.rogobete@lumenshine.com"
            
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
        
        if let unfundedView = card.unfundedView {
            
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
    
    class func labelsForCustomAssets(wallet: Wallet, font: UIFont, color: UIColor ) -> [UILabel] {
        var labels = [UILabel]()
        
        if let wallet = wallet as? FundedWallet {
            for balance in wallet.balances {
                if balance.assetType != AssetTypeAsString.NATIVE {
                    let text = String(format: "%.2f \(balance.assetCode ?? balance.assetType)", CoinUnit(balance.balance)!)
                    let label = UILabel()
                    label.font = font
                    label.textColor = color
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
        
        depthPreset = .depth2
        backgroundColor = Stylesheet.color(.clear)
        
        addSubview(contentView)
        contentView.snp.makeConstraints {make in
            make.edges.equalToSuperview()
        }
        
        prepareBottomBar()
    }
    
    func prepareBottomBar() {
        bottomBar.contentEdgeInsetsPreset = .square2
        
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



