//
//  HomeUnfundedWalletHeaderView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 13/06/2018.
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
    }
}
