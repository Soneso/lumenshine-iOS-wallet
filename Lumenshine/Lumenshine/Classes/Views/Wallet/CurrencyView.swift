//
//  CurrencyView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
                issuerLabel.text = issuer
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
    
    @IBAction func copyIssuerLabelAction(_ sender: UIButton) {
        if let value = issuerLabel.text {
            UIPasteboard.general.string = value
            let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .actionSheet)
            parentContainerViewController()?.present(alert, animated: true)
            let when = DispatchTime.now() + 0.75
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true)
            }
        }
    }
}
