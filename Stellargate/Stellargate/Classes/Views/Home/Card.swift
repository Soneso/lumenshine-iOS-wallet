//
//  Card.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol CardProtocol {
    func setBottomBar(buttons: [Button]?)
}

class Card: UIView {
    
    internal let bottomBar = Bar()
    internal var viewModel: CardViewModelType? {
        didSet {
            let buttons = viewModel?.bottomTitles?.map {
                return FlatButton(title: $0)
            }
            setBottomBar(buttons: buttons)
        }
    }
    
//    init(viewModel:CardViewModelType) {
//        super.init(frame: .zero)
//        self.viewModel = viewModel
//        prepare()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func create(viewModel:CardViewModelType) -> Card {
        var card: Card
        switch viewModel.type {
        case .web:
             card = WebCard()
        case .chart:
            card = ChartCard()
        case .intern:
            card = InternalCard()
        case .account:
            card = Card()
        }
        card.viewModel = viewModel
        return card
    }
}

extension Card: CardProtocol {
    func setBottomBar(buttons: [Button]?) {
        bottomBar.rightViews = buttons ?? []
    }
}

fileprivate extension Card {
    func prepare() {
        
        cornerRadiusPreset = .cornerRadius3
        depthPreset = .depth3
        
        backgroundColor = Stylesheet.color(.white)
        
        prepareBottomBar()
    }
    
    func prepareBottomBar() {
        addSubview(bottomBar)
        bottomBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomBar.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}



