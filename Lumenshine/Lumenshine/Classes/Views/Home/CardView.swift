//
//  CardView.swift
//  Lumenshine
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

class CardView: UIView {
    internal let contentView = UIView()
    internal let bottomBar = Bar()
    
    internal var viewModel: CardViewModelType? {
        didSet {
            let buttons = viewModel?.bottomTitles?.map { title -> FlatButton in
                let button = FlatButton(title: title)
                button.addTarget(self, action: #selector(barButtonClick(_:)), for: .touchUpInside)
                return button
            }
            setBottomBar(buttons: buttons)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func create(viewModel:CardViewModelType) -> CardView {
        var card: CardView
        switch viewModel.type {
        case .web:
             card = WebCard()
        case .chart:
            card = ChartCard()
        case .intern:
            card = InternalCard()
        case .account:
            card = InternalCard()
        case .wallet:
            card = WalletCard()
        }
        card.viewModel = viewModel
        return card
    }
    
    @objc
    func barButtonClick(_ sender: FlatButton) {
        viewModel?.barButtonSelected(at: sender.tag)
    }
}

extension CardView: CardProtocol {
    func setBottomBar(buttons: [Button]?) {
        bottomBar.rightViews = buttons ?? []
    }
}

fileprivate extension CardView {
    func prepare() {
        
        contentView.cornerRadiusPreset = .cornerRadius3
        contentView.clipsToBounds = true
        contentView.backgroundColor = Stylesheet.color(.white)
        
        depthPreset = .depth3
        backgroundColor = Stylesheet.color(.clear)
        
        addSubview(contentView)
        contentView.snp.makeConstraints {make in
            make.edges.equalToSuperview()
        }
        
        prepareBottomBar()
    }
    
    func prepareBottomBar() {
        contentView.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let separator = UIView()
        separator.backgroundColor = Stylesheet.color(.lightGray)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomBar.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}



