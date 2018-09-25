//
//  HomeViewModel.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol HomeViewModelType: Transitionable {

    var cardViewModels: [CardViewModelType] { get }
    var reloadClosure: (() -> ())? { get set }
    var totalNativeFoundsClosure: ((CoinUnit) -> ())? { get set }
    var currencyRateUpdateClosure: ((Double) -> ())? { get set }
    
    func foundAccount()
    func reloadCards()
}

class HomeViewModel : HomeViewModelType {
    
    fileprivate let service: Services
    fileprivate var responsesMock: CardsResponsesMock?
    fileprivate let user: User
    fileprivate let userManager = Services.shared.userManager
    fileprivate let currenciesMonitor = CurrenciesMonitor()
    
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
                print("Failed to get wallets")
            }
        }
    }

    var cardViewModels: [CardViewModelType]
    var reloadClosure: (() -> ())?
    var totalNativeFoundsClosure: ((CoinUnit) -> ())?
    var currencyRateUpdateClosure: ((Double) -> ())? {
        didSet {
            currenciesMonitor.updateClosure = currencyRateUpdateClosure
        }
    }
    
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
    
    func foundAccount() {
        showScan()
    }
    
    func reloadCards() {
        cardViewModels = []
        
        userManager.walletsForCurrentUser { (result) -> (Void) in
            switch result {
            case .success(let wallets):
                for wallet in wallets {
                    let viewModel = WalletCardViewModel(wallet: wallet)
                    viewModel.navigationCoordinator = self.navigationCoordinator
                    self.cardViewModels.insert(viewModel, at: 0)
                    
                    self.reloadClosure?()
                }
            case .failure(_):
                print("Failed to get wallets")
            }
        }
                        
        let chartViewModel = ChartCardViewModel(service: service.chartsService)
        chartViewModel.navigationCoordinator = self.navigationCoordinator
        self.cardViewModels.append(chartViewModel)
        
        let helpViewModel = HelpCardViewModel()
        helpViewModel.navigationCoordinator = self.navigationCoordinator
        self.cardViewModels.append(helpViewModel)
        
        self.reloadClosure?()
    }

}

fileprivate extension HomeViewModel {
    func showHeaderMenu() {
        let items = [
            (R.string.localizable.sell(), R.image.wallets.name),
            (R.string.localizable.send(), R.image.pencil.name),
            (R.string.localizable.receive(), R.image.link.name),
            (R.string.localizable.scan(), R.image.question.name),
            (R.string.localizable.deposit(), R.image.lost_2fa.name),
            (R.string.localizable.withdraw(), R.image.currencies.name)
        ]
        navigationCoordinator?.performTransition(transition: .showHeaderMenu(items))
    }
    
    func showScan() {
        if let wallet = (self.cardViewModels.first as? WalletCardViewModel)?.wallet {
            navigationCoordinator?.performTransition(transition: .showScan(wallet))
        }
    }
}
