//
//  CardView.swift
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
            walletCard.setup(viewModel: viewModel as! WalletCardViewModel)
            
            card = walletCard
            
        }
        card.viewModel = viewModel
        return card
    }
    
    @objc
    func barButtonClick(_ sender: FlatButton) {
        viewModel?.barButtonSelected(at: sender.tag)
    }
    
    class private func setupConstraints(forLabel label: UILabel, forButton button: CurrencyInfoButton? = nil) {
        label.snp.makeConstraints { (make) in
            make.top.equalTo(1)
            make.bottom.equalTo(1)
            make.left.equalToSuperview()
        }
        
        if let button = button {
            button.snp.makeConstraints { (make) in
                make.top.equalTo(1)
                make.bottom.equalTo(1)
            }
            
            label.rightAnchor.constraint(equalTo: button.leftAnchor, constant: -4).isActive = true
        }
    }
    
    class private func setupCurrencyInfoButton(forCurrency currency: AccountBalanceResponse, wallet: FundedWallet) -> CurrencyInfoButton {
        let currencyInfoButton = CurrencyInfoButton()
        currencyInfoButton.currency = currency
        currencyInfoButton.wallet = wallet
        
        return currencyInfoButton
    }
    
    class private func setupLabel(font: UIFont, color: UIColor, text: String) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.text = text
        
        return label
    }
    
    class private func setupLabelView(font: UIFont, color: UIColor, text: String) -> UIView {
        let view = UIView()
        let label = setupLabel(font: font, color: color, text: text)

        view.addSubview(label)
        setupConstraints(forLabel: label)
        
        return view
    }
    
    class private func getLabelAndInfoButtonView(font: UIFont, color: UIColor, text: String, currency: AccountBalanceResponse, wallet: FundedWallet) -> UIView {
        let view = UIView()
        let label = setupLabel(font: font, color: color, text: text)
        let infoButton = setupCurrencyInfoButton(forCurrency: currency, wallet: wallet)
        
        view.addSubview(label)
        view.addSubview(infoButton)
        
        setupConstraints(forLabel: label, forButton: infoButton)
        
        return view
    }
    
    class private func getLabelText(forWallet wallet: FundedWallet,
                                    forCurrency currency: AccountBalanceResponse,
                                    forAvailable: Bool?,
                                    balance: CoinUnit,
                                    availableBalance: CoinUnit,
                                    assetCode: String) -> String {
        if wallet.isCurrencyDuplicate(withAssetCode: assetCode), let issuer = currency.assetIssuer {
            return "\(forAvailable == true ? availableBalance.stringWithUnit : balance.stringWithUnit) \(assetCode) (\(issuer.prefix(4))...)"
        } else {
            return "\(forAvailable == true ? availableBalance.stringWithUnit : balance.stringWithUnit) \(assetCode)"
        }
    }
    
    class func labelsForCustomAssets(wallet: Wallet, font: UIFont, color: UIColor, forAvailable: Bool? = false) -> [UIView] {
        var views = [UIView]()
        if let wallet = wallet as? FundedWallet {
            for currency in wallet.balances {
                if currency.assetType != AssetTypeAsString.NATIVE {
                    if let balance = CoinUnit(currency.balance), let assetCode = currency.assetCode {
                        let availableBalance = balance.availableAmount(forWallet: wallet, forCurrency: currency)
                        let labelText = getLabelText(forWallet: wallet,
                                                     forCurrency: currency,
                                                     forAvailable: forAvailable,
                                                     balance: balance,
                                                     availableBalance: availableBalance,
                                                     assetCode: assetCode)
                        if forAvailable == true && balance != availableBalance {
                            views.append(getLabelAndInfoButtonView(font: font, color: color, text: labelText, currency: currency, wallet: wallet))
                        } else {
                            views.append(setupLabelView(font: font, color: color, text: labelText))
                        }
                    }
                }
            }
        }
        
        return views
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
