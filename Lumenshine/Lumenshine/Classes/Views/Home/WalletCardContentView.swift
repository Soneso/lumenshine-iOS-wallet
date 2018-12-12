//
//  WalletCardContentView.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class WalletCardContentView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var stellarAddressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var balanceDescriptionLabel: UILabel!
    @IBOutlet weak var availableDescriptionLabel: UILabel!
    @IBOutlet weak var balanceBackgroundView: UIView!
    @IBOutlet weak var balanceStackView: UIStackView!
    @IBOutlet weak var availableStackView: UIStackView!
    @IBOutlet weak var currencyInfoButton: CurrencyInfoButton!
}
