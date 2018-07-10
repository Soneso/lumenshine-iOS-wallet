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
    
    func foundAccount()
}

class HomeViewModel : HomeViewModelType {
    
    fileprivate let service: HomeService
    fileprivate var responsesMock: CardsResponsesMock?
    fileprivate let user: User
    fileprivate let userManager = UserManager()
    
    var navigationCoordinator: CoordinatorType?
    
    init(service: HomeService, user: User) {
        self.service = service
        self.user = user
        cardViewModels = []
        
        // TODO: remove mock when service is ready
//        mockService()
        
        self.service.getCards() { response in
            self.cardViewModels = response.map {
                let viewModel = CardViewModel(card: $0)
                viewModel.navigationCoordinator = self.navigationCoordinator
                return viewModel
            }
            
            let viewModel = WalletCardViewModel(user: user)
            viewModel.navigationCoordinator = self.navigationCoordinator
            self.cardViewModels.append(viewModel)
            
            if let reload = self.reloadClosure {
                reload()
            }
        }
        
        userManager.totalNativeFounds { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.totalNativeFoundsClosure?(data)
            case .failure(_):
                print("Failed to get wallets")
            }
        }
    }

    var cardViewModels: [CardViewModelType]
    var reloadClosure: (() -> ())?
    var totalNativeFoundsClosure: ((CoinUnit) -> ())?
    
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
}

fileprivate extension HomeViewModel {
    func showHeaderMenu() {
        let items = [
            (R.string.localizable.sell(), R.image.money1.name),
            (R.string.localizable.send(), R.image.pencil.name),
            (R.string.localizable.receive(), R.image.compose.name),
            (R.string.localizable.scan(), R.image.question.name),
            (R.string.localizable.deposit(), R.image.combination_lock.name),
            (R.string.localizable.withdraw(), R.image.money2.name)
        ]
        navigationCoordinator?.performTransition(transition: .showHeaderMenu(items))
    }
    
    func showScan() {
        navigationCoordinator?.performTransition(transition: .showScan)
    }
}

fileprivate extension HomeViewModel {
    func mockService() {
        URLProtocol.registerClass(ServerMock.self)
        
        responsesMock = CardsResponsesMock()
        responsesMock?.addCardsResponse(mockJSON())

    }
    
    func mockJSON() -> String {
        let JSON = """
                {
                 "cards": [
                    {
                      "type": 0,
                      "title": "Web card",
                      "description": "Stellar | Move Money Across Borders Quickly, Reliably, And For Fractions Of A Penny.",
                      "detail": "Stellar is a platform that connects banks, payments systems, and people. Integrate to move money quickly, reliably, and at almost no cost.",
                      "link": "https://www.stellar.org/how-it-works/stellar-basics/",
                      "imgUrl": "https://cryptocrimson.com/wp-content/uploads/2018/02/Stellar-Lumens-Price-Update-18-February-2018.jpg"
                    },
                    {
                      "type": 1,
                      "title": "Internal card",
                      "description": "Stellar | Move Money Across Borders Quickly, Reliably, And For Fractions Of A Penny.",
                      "detail": "Stellar is a platform that connects banks, payments systems, and people. Integrate to move money quickly, reliably, and at almost no cost.",
                      "imgUrl": "https://smartereum.com/wp-content/uploads/2018/02/Stellar-price-predictions-2018-Moderate-returns-but-good-development-potential-USD-XLM-price-analysis-XLM-Stellar-News-Today.jpg"
                    },
                    {
                      "type": 2,
                      "title": "Chart card",
                      "description": "Stellar | Move Money Across Borders Quickly, Reliably, And For Fractions Of A Penny.",
                      "chartData": "0001010"
                    },
                    {
                      "type": 3,
                      "title": "Account card",
                      "description": "Stellar | Move Money Across Borders Quickly, Reliably, And For Fractions Of A Penny.",
                      "detail": "Stellar is a platform that connects banks, payments systems, and people. Integrate to move money quickly, reliably, and at almost no cost."
                    },
                    {
                      "type": 4,
                      "title": "Wallet card",
                      "description": "Stellar | Move Money Across Borders Quickly, Reliably, And For Fractions Of A Penny.",
                      "detail": "Stellar is a platform that connects banks, payments systems, and people. Integrate to move money quickly, reliably, and at almost no cost."
                    }
                  ]
                }
            """
        return JSON
    }
}

