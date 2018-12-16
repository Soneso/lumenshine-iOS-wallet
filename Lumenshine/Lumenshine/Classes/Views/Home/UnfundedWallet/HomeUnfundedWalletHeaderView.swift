//
//  HomeUnfundedWalletHeaderView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class HomeUnfundedWalletHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var xlmPriceLabel: UILabel!

    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    var foundAction: ((_ sender: UIButton)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @IBAction func didTapFoundWallet(_ sender: Any) {
        foundAction?(sender as! UIButton)
    }
    
    private func setup() {
        titleLabel.text = R.string.localizable.homeScreenTitle()
        
        guard #available(iOS 11, *) else {
            logoTopConstraint.constant = 0
            return
        }
        
        Services.shared.chartsService.getChartExchangeRates(assetCode: "XLM", issuerPublicKey: nil, destinationCurrency: "USD", timeRange: 1) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(let exchangeRates):
                    if let currentRateResponse = exchangeRates.rates.first?.rate {
                        let rate = Decimal(1.0) / currentRateResponse
                        self.xlmPriceLabel.text = "1 USD ≈ \(Services.shared.walletService.formatAmount(amount: rate.description)) XLM"
                        self.applyTransitionFlip(to:self.xlmPriceLabel)
                    }
                case .failure(let error):
                    print("Failed to get exchange rate: \(error)")
                }
            }
        }
    }
    
    private func applyTransitionFlip(to viewElement: UIView) {
        UIView.transition(with: viewElement, duration: 1, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
}
