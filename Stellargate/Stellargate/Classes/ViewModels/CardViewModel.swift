//
//  CardViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

enum CardType {
    case web
    case chart
    case intern
    case account
}

protocol CardViewModelType: Transitionable {
    var type: CardType { get }
    
    var image: UIImage? { get }
    var title: String? { get }
    var detail: String? { get }
    var bottomTitles: [String]? { get }
}

class CardViewModel : CardViewModelType {
    var type: CardType
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(type: CardType) {
        self.type = type
    }
    
    var image: UIImage? {
        if type == .web || type == .intern {
            return UIImage.image(with: Stylesheet.color(.green), size: CGSize(width: 200, height: 100))
        }
        return nil
    }
    
    var title: String? {
        return "Test title"
    }
    
    var detail: String? {
        switch type {
        case .web:
            return "Material is an animation and graphics framework that is used to create beautiful applications. Material is an animation and graphics framework that is used to create beautiful applications"
        case .chart:
            return "7 days - Updated just now"
        case .intern:
            return "Need help or have a suggestion?"
        case .account:
            return "Test"
        }

    }
    
    var bottomTitles: [String]? {
        switch type {
        case .web:
            return ["Read more"]
        case .chart:
            return ["Sell Lumen"]
        case .intern:
            return ["Send feedback", "View FAQ"]
        case .account:
            return ["Learn more"]
        }
    }
    
}
