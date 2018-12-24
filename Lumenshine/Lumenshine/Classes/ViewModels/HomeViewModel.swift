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

    var cardViewModels: [CardViewModelType] { get set }
    var reloadClosure: (() -> ())? { get set }
    var appendClosure: ((CardViewModelType) -> ())? { get set }
    var totalNativeFoundsClosure: ((CoinUnit) -> ())? { get set }
    var currencyRateUpdateClosure: ((Double) -> ())? { get set }
    var scrollToItemClosure: ((Int) -> ())? { get set }
    
    
    func fundAccount()
    func reloadData()
    func updateHeaderData()
    func refreshWallets()
    func showWalletIfNeeded()
    func cleanup()
}

class HomeViewModel : HomeViewModelType {
    
    fileprivate var responsesMock: CardsResponsesMock?
    fileprivate let needsHeaderUpdate: Bool
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(needsHeaderUpdate: Bool) {
        self.needsHeaderUpdate = needsHeaderUpdate
        cardViewModels = []
    }
    
    deinit {
        print("HomeViewModel deinit")
    }
    
    var cardViewModels: [CardViewModelType]
    var reloadClosure: (() -> ())?
    var appendClosure: ((CardViewModelType) -> ())?
    var totalNativeFoundsClosure: ((CoinUnit) -> ())?
    var currencyRateUpdateClosure: ((Double) -> ())?
    var scrollToItemClosure: ((Int) -> ())?
    
    func fundAccount() {
        if let wallet = (self.cardViewModels.first as? WalletCardViewModel)?.wallet {
            navigationCoordinator?.performTransition(transition: .showFundWallet(wallet))
        }
    }
    
    func updateHeaderData() {
        
        if !needsHeaderUpdate {
            return
        }
        
        Services.shared.userManager.totalNativeFounds { [weak self] (result) -> (Void) in
            switch result {
            case .success(let data):
                self?.totalNativeFoundsClosure?(data)
                Services.shared.chartsService.getChartExchangeRates(assetCode: "XLM", issuerPublicKey: nil, destinationCurrency: "USD", timeRange: 1) { (result) -> (Void) in
                    switch result {
                    case .success(let exchangeRates):
                        if let currentRateResponse = exchangeRates.rates.first?.rate {
                            let currentRate = Double(truncating: currentRateResponse as NSNumber)
                            DispatchQueue.main.async {
                                self?.currencyRateUpdateClosure?(currentRate)
                            }
                        }
                    case .failure(let error):
                        print("Failed to get exchange rates: \(error)")
                    }
                }
            default:
                break
            }
        }
    }
    
    func reloadData() {

        Services.shared.userManager.totalNativeFounds { [weak self] (result) -> (Void) in
            switch result {
            case .success(let data):
                self?.totalNativeFoundsClosure?(data)
                Services.shared.chartsService.getChartExchangeRates(assetCode: "XLM", issuerPublicKey: nil, destinationCurrency: "USD", timeRange: 1) { (result) -> (Void) in
                    switch result {
                    case .success(let exchangeRates):
                        if let currentRateResponse = exchangeRates.rates.first?.rate {
                            let currentRate = Double(truncating: currentRateResponse as NSNumber)
                            DispatchQueue.main.async {
                                self?.currencyRateUpdateClosure?(currentRate)
                            }
                        }
                    case .failure(let error):
                        print("Failed to get exchange rates: \(error)")
                    }
                    self?.reloadCards()
                }
            default:
                self?.reloadCards()
                break
            }
        }
    }
    
    func reloadCards() {
        cardViewModels.removeAll()
        
        Services.shared.walletService.getWallets(reload:true) { [weak self] (result) -> (Void) in
            switch result {
            case .success(let wallets):
                var chartAppended = false
                let sortedWallets = wallets.sorted(by: { $0.id < $1.id })
                for wallet in sortedWallets {
                    if wallet.showOnHomeScreen {
                        let viewModel = WalletCardViewModel(walletResponse: wallet)
                        viewModel.navigationCoordinator = self?.navigationCoordinator
                        viewModel.reloadCardsClosure = {
                            self?.reloadData()
                        }
                        
                        self?.cardViewModels.append(viewModel)
                        if !chartAppended {
                            let chartViewModel = ChartCardViewModel()
                            chartViewModel.navigationCoordinator = self?.navigationCoordinator
                            self?.cardViewModels.append(chartViewModel)
                            chartAppended = true
                        }
                    }
                }
                
                WebSocketService.wallets = wallets
            case .failure(_):
                // TODO: handle this
                print("Failed to get wallets")
            }
        
            /*let helpViewModel = HelpCardViewModel()
            helpViewModel.navigationCoordinator = self?.navigationCoordinator
            self?.cardViewModels.append(helpViewModel)*/
            
            self?.reloadClosure?()
            
            self?.showWalletIfNeeded()
        
        }
    }
    
    func refreshWallets() {
        for cardViewModel in cardViewModels {
            if let wallet = cardViewModel as? WalletCardViewModel {
                wallet.refreshContent(userManager: Services.shared.userManager)
            }
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
    
    func cleanup() {
        cardViewModels.removeAll()
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
