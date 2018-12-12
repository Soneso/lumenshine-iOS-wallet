//
//  CurrencyFeeInfoViewController.swift
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
import Material

class CurrencyFeeInfoViewController: UIViewController {
    var currency: AccountBalanceResponse!
    
    @IBOutlet weak var liabilitiesValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        setupLabel()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func closeAction() {
        dismiss(animated: true)
    }
    
    private func setupLabel() {
        liabilitiesValueLabel.text = "\(CoinUnit(currency.sellingLiabilities) ?? 0) \(currency.assetCode ?? "")"
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Available \(currency.assetCode ?? "")"
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.gray))
        backButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
    }
}
