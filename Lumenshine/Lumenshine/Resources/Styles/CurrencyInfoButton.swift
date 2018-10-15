//
//  CurrencyInfoButton.swift
//  Lumenshine
//
//  Created by Soneso on 11/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

class CurrencyInfoButton: UIButton {
    var currency: AccountBalanceResponse!
    var wallet: FundedWallet!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        addTarget(self, action: #selector(buttonTapped), for:.touchUpInside)
        setImage(R.image.question()?.crop(toWidth: 20, toHeight: 20)?.tint(with: Stylesheet.color(.gray)), for: .normal)
    }
    
    @objc func buttonTapped() {
        if currency.assetCode == nil {
            let nativeCurrencyFeeInfoViewController = NativeCurrencyFeeInfoViewController()
            nativeCurrencyFeeInfoViewController.currency = currency
            nativeCurrencyFeeInfoViewController.wallet = wallet
            let composeVC = ComposeNavigationController(rootViewController: nativeCurrencyFeeInfoViewController)
            viewContainingController()?.present(composeVC, animated: true)
        } else {
            let currencyFeeInfoViewController = CurrencyFeeInfoViewController()
            currencyFeeInfoViewController.currency = currency
            let composeVC = ComposeNavigationController(rootViewController: currencyFeeInfoViewController)
            viewContainingController()?.present(composeVC, animated: true)
        }
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(-10, -10, -10, -10))
        return hitFrame.contains(point)
    }
}
