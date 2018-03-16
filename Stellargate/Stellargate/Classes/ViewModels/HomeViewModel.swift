//
//  HomeViewModel.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol HomeViewModelType: Transitionable {
    
    var barTitles: [String] { get }
    var barIcons: [UIImage?] { get }
    
    var cardViewModels: [CardViewModelType] { get }
    
    func barItemSelected(at index:Int)
    
}

class HomeViewModel : HomeViewModelType {
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
    
    var navigationCoordinator: CoordinatorType?
    
    var cardViewModels: [CardViewModelType]
    
    init() {
        cardViewModels = [
            CardViewModel(type: .web),
            CardViewModel(type: .chart),
            CardViewModel(type: .web),
            CardViewModel(type: .chart)
        ]
    }
    
    func barItemSelected(at index:Int) {
        if index == 4 {
            let titles = [
                R.string.localizable.sell(),
                R.string.localizable.send(),
                R.string.localizable.receive(),
                R.string.localizable.scan(),
                R.string.localizable.deposit(),
                R.string.localizable.withdraw()
            ]
            let icons = [
                MaterialIcon.money.size24pt,
                MaterialIcon.send.size24pt,
                MaterialIcon.received.size24pt,
                MaterialIcon.qrCode.size24pt,
                MaterialIcon.wallets.size24pt,
                MaterialIcon.accountBalance.size24pt
            ]
            navigationCoordinator?.performTransition(transition: .showHeaderMenu(titles, icons))
        }
    }
    
}
