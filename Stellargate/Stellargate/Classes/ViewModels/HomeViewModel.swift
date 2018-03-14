//
//  HomeViewModel.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol HomeViewModelType: Transitionable {
    
    var cardViewModels: [CardViewModelType] { get }
    
}

class HomeViewModel : HomeViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    var cardViewModels: [CardViewModelType]
    
    init() {
        cardViewModels = [
            CardViewModel(type: .web),
            CardViewModel(type: .chart),
            CardViewModel(type: .web),
            CardViewModel(type: .chart)
        ]
    }
    
}
