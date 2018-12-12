//
//  HomeViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

protocol HomeViewModelType: Transitionable {

    var cardViewModels: [CardViewModelType] { get }
    var reloadClosure: (() -> ())? { get set }
    var appendClosure: ((CardViewModelType) -> ())? { get set }
    var totalNativeFoundsClosure: ((CoinUnit) -> ())? { get set }
    var currencyRateUpdateClosure: ((Double) -> ())? { get set }
    var scrollToItemClosure: ((Int) -> ())? { get set }
    
    
    func fundAccount()
    func reloadCards()
    func refreshWallets()
    func updateCurrencies()
    func showWalletIfNeeded()
}

class HomeViewModel : HomeViewModelType {
    
    fileprivate let service: Services
    fileprivate var responsesMock: CardsResponsesMock?
    fileprivate let user: User
    fileprivate let userManager = Services.shared.userManager
    fileprivate let currenciesMonitor = CurrenciesMonitor()
    
    fileprivate var currencyPairs = Array<ChartsCurrencyPairsResponse>()
    fileprivate var balances = Array<AccountBalanceResponse>()
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: Services, user: User) {
        self.service = service
        self.user = user
        cardViewModels = []
        
        currenciesMonitor.startMonitoring()
        
        userManager.totalNativeFounds { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.totalNativeFoundsClosure?(data)
                self.currencyRateUpdateClosure?(self.currenciesMonitor.currentRate)
            case .failure(_):
                // TODO: handle this
                print("Failed to get wallets")
            }
        }
        
        service.chartsService.getChartsCurrencyPairs { result in
            switch result {
            case .success(let response):
                self.currencyPairs.append(contentsOf: response)
            case .failure(let error):
                print("Failed to get chart currency pairs: \(error)")
            }
        }
    }

    var cardViewModels: [CardViewModelType]
    var reloadClosure: (() -> ())?
    var appendClosure: ((CardViewModelType) -> ())?
    var totalNativeFoundsClosure: ((CoinUnit) -> ())?
    var currencyRateUpdateClosure: ((Double) -> ())? {
        didSet {
            currenciesMonitor.updateClosure = currencyRateUpdateClosure
        }
    }
    var scrollToItemClosure: ((Int) -> ())?
    
    var barTitles: [String] {
        return [
            R.string.localizable.send(),
            R.string.localizable.sell(),
            R.string.localizable.scan(),
            R.string.localizable.receive(),
            R.string.localizable.more()
        ]
        
    }
    
    var barIcons: [UIImage?] {
        return [
            MaterialIcon.send.size24pt,
            MaterialIcon.money.size24pt,
            MaterialIcon.qrCode.size24pt,
            MaterialIcon.received.size24pt,
            MaterialIcon.moreHorizontal.size24pt
        ]
    }
    
    func fundAccount() {
        if let wallet = (self.cardViewModels.first as? WalletCardViewModel)?.wallet {
            navigationCoordinator?.performTransition(transition: .showFundWallet(wallet))
        }
    }
    
    func reloadCards() {
        cardViewModels.removeAll()
        balances.removeAll()
        
        service.walletService.getWallets { [weak self] (result) -> (Void) in
            switch result {
            case .success(let wallets):
                let sortedWallets = wallets.sorted(by: { $0.id < $1.id })
                for wallet in sortedWallets {
                    if wallet.showOnHomeScreen {
                        let viewModel = WalletCardViewModel(userManager: (self?.service.userManager)!, walletResponse: wallet)
                        viewModel.navigationCoordinator = self?.navigationCoordinator
                        viewModel.reloadCardsClosure = {
                            self?.reloadCards()
                        }
                        
                        self?.cardViewModels.append(viewModel)
                    }
                }
                
                WebSocketService.wallets = wallets
            case .failure(_):
                // TODO: handle this
                print("Failed to get wallets")
            }
            
            let helpViewModel = HelpCardViewModel()
            helpViewModel.navigationCoordinator = self?.navigationCoordinator
            self?.cardViewModels.append(helpViewModel)
            
            self?.reloadClosure?()
            
            self?.showWalletIfNeeded()
        }
    }
    
    func refreshWallets() {
        for cardViewModel in cardViewModels {
            if let wallet = cardViewModel as? WalletCardViewModel {
                wallet.refreshContent(userManager: service.userManager)
            }
        }
    }
    
    func updateCurrencies() {
        
        var hasChartCard = false
        
        for cardViewModel in cardViewModels {
            if let _ = cardViewModel as? ChartCardViewModel {
                hasChartCard = true
            }
            
            if let viewModel = cardViewModel as? WalletCardViewModel,
                let wallet = viewModel.wallet as? FundedWallet {
                
                for balance in wallet.balances {
                    if balance.assetType != AssetTypeAsString.NATIVE, !currencyPairs.contains(where: { $0.sourceCurrency.assetCode == balance.assetCode && $0.sourceCurrency.issuerPublicKey == balance.assetIssuer }) {
                        continue
                    }
                    if !balances.contains(where: { $0.assetCode == balance.assetCode }) {
                        balances.append(balance)
                    }
                }
            }
        }
        
        // TODO: move this to its correct place
        if !hasChartCard {
            let chartViewModel = ChartCardViewModel(service: service.chartsService)
            chartViewModel.navigationCoordinator = self.navigationCoordinator
            cardViewModels.insert(chartViewModel, at: cardViewModels.count-1)
            self.appendClosure?(chartViewModel)
        }
    }
    
    func showWalletIfNeeded() {
        if let walletPublicKey = UserDefaults.standard.value(forKey: Keys.UserDefs.ShowWallet) as? String {
            let index = cardViewModels.firstIndex(where: {
                if let wallet = $0 as? WalletCardViewModel {
                    return wallet.wallet.publicKey == walletPublicKey
                }
                return false
            })
            UserDefaults.standard.setValue(nil, forKey: Keys.UserDefs.ShowWallet)
            if let index = index {
                self.scrollToItemClosure?(index)
            }
        }
    }
}

fileprivate extension HomeViewModel {
    func showHeaderMenu() {
        var items:[(String, String?)]? = nil
        items = [
            (R.string.localizable.deposit(), nil),
            (R.string.localizable.withdraw(), nil)
        ]
        navigationCoordinator?.performTransition(transition: .showHeaderMenu(items!))
    }
}
