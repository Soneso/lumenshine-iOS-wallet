//
//  CurrencyView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 09/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

class CurrencyView: UIView {
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var issuerLabel: UILabel!
    @IBOutlet weak var authorizationLabel: UILabel!
    
    var currency: AccountBalanceResponse! {
        didSet {
            currencyLabel.text = currency.assetCode
            if let issuer = currency.assetIssuer {
                issuerLabel.text = "\(R.string.localizable.issuer_pk()) \(issuer)"
            }
            
            if let isAuthorized = currency.authorized, isAuthorized {
                authorizationLabel.removeFromSuperview()
            }
        }
    }
    
    var removeAction: ((AccountBalanceResponse) -> ())?
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        removeAction?(currency)
    }
}
