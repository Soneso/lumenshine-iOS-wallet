//
//  CardViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum CardType {
    case web
    case chart
    case intern
    case account
}

protocol CardViewModelType: Transitionable {
    var type: CardType { get }
}

class CardViewModel : CardViewModelType {
    var type: CardType
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(type: CardType) {
        self.type = type
    }
    
}
