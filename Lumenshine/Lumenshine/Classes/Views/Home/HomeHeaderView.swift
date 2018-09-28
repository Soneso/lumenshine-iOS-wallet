//
//  HomeHeaderView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 13/06/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

enum HomeHeaderViewType {
    case funded
    case unfunded
}

class HomeHeaderView: UIView {
    var type: HomeHeaderViewType! {
        didSet {
            switch type! {
            case .funded:
                showFundedView()
            case .unfunded:
                showUnfundedView()
            }
        }
    }
    
    var funds: String! {
        didSet {
            if let fundedView = fundedView {
                fundedView.foundAccountButton.text = funds
                applyTransitionFlip(to: fundedView.foundAccountButton)
            }
            
            if let unfundedView = unfundedView {
                unfundedView.xlmPriceLabel.text = funds
                applyTransitionFlip(to: unfundedView.xlmPriceLabel)
            }
        }
    }
    
    var fundedView: HomeFundedWalletHeaderView!
    var unfundedView: HomeUnfundedWalletHeaderView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func showFundedView() {
        unfundedView.removeFromSuperview()
        
        addSubview(fundedView)
        fundedView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    private func showUnfundedView() {
        fundedView.removeFromSuperview()
        
        addSubview(unfundedView)
        unfundedView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    private func setup() {
        fundedView = Bundle.main.loadNibNamed("HomeFundedWalletHeaderView", owner: nil, options: nil)![0] as! HomeFundedWalletHeaderView
        unfundedView = Bundle.main.loadNibNamed("HomeUnfundedWalletHeaderView", owner: nil, options: nil)![0] as! HomeUnfundedWalletHeaderView
    }

    private func applyTransitionFlip(to viewElement: UIView) {
        UIView.transition(with: viewElement, duration: 1, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
}
