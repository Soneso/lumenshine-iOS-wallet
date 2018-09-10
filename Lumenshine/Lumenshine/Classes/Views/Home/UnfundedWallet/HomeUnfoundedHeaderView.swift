//
//  HomeUnfoundedHeaderView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 13/06/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class HomeUnfoundedHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var xlmPriceLabel: UILabel!
    @IBOutlet weak var foundAccountButton: IconButton!

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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40.0)
        titleLabel.textColor = Stylesheet.color(.white)
        
        foundAccountButton.iconLabel.text = R.string.localizable.homeScreenFoundWallet()
        foundAccountButton.iconImageView.image = UIImage(named: "found_account")?.tint(with: Stylesheet.color(.white))
        foundAccountButton.iconLabel.textColor = Stylesheet.color(.white)
    }
    
}
