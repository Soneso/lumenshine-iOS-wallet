//
//  WalletCard.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol WalletCardProtocol {
    
}

class WalletCard: CardView {
    
    fileprivate let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var viewModel: CardViewModelType? {
        didSet {

        }
    }
}

fileprivate extension WalletCard {
    func prepare() {
        prepareLabel()
    }
    
    func prepareLabel() {
        textLabel.textColor = Stylesheet.color(.black)
        textLabel.font = Stylesheet.font(.body)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.bottom.right.equalTo(-10)
        }
    }
}
