//
//  HelpCardViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/25/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UIImage

class HelpCardViewModel: CardViewModelType {
    
    var navigationCoordinator: CoordinatorType?
    
    fileprivate var card: Card?
    
    init() {
        
    }
    
    var type: CardType {
        return .help
    }
    
    var imageURL: URL? {
        guard let urlString = card?.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var image: UIImage? {
        return R.image.help_card()
    }
    
    var linkURL: URL? {
        guard let urlString = card?.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        return R.string.localizable.help_feedback()
    }
    
    var detail: String? {
        return R.string.localizable.help_hint()
    }
    
    var bottomTitles: [String]? {
        return [R.string.localizable.send_feedback(),
                R.string.localizable.view_faq()]
    }
    
    func barButtonSelected(at index: Int) {
        switch index {
        case 0:
            navigationCoordinator?.performTransition(transition: .showFeedback)
        case 1:
            navigationCoordinator?.performTransition(transition: .showHelp)
        default:
            break
        }
    }
}

fileprivate extension HelpCardViewModel {
    
    
}
