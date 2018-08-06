//
//  CardViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol CardViewModelType: Transitionable {
    var type: CardType { get }
    var imageURL: URL? { get }
    var linkURL: URL? { get }
    var title: String? { get }
    var detail: String? { get }
    var bottomTitles: [String]? { get }
    
    func barButtonSelected(at index: Int)
}

class CardViewModel : CardViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate let card: Card
    
    init(card: Card) {
        self.card = card
    }
    
    var type: CardType {
        return card.type!
    }
    
    var imageURL: URL? {
        guard let urlString = card.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var linkURL: URL? {
        guard let urlString = card.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        return card.title
    }
    
    var detail: String? {
        return card.detail
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
        case .wallet:
            return [R.string.localizable.fund_wallet()]
        }
    }
    
    func barButtonSelected(at index: Int) {
        switch type {
        case .web:
            guard let url = linkURL else { return }
            navigationCoordinator?.performTransition(transition: .showOnWeb(url))
        default:
            break
        }
    }
}
