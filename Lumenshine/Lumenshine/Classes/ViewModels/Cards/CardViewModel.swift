//
//  CardViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol CardViewModelType: Transitionable {
    var type: CardType { get }
    var imageURL: URL? { get }
    var image: UIImage? { get }
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
    
    var image: UIImage? {
        return nil
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
            return [R.string.localizable.read_more()]
        case .chart:
            return [R.string.localizable.refresh()]
        case .help:
            return [R.string.localizable.send_feedback(), R.string.localizable.view_faq()]
        case .account:
            return [R.string.localizable.learn_more()]
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
