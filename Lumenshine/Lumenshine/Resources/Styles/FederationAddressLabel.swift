//
//  FederationAddressLabel.swift
//  Lumenshine
//
//  Created by Soneso on 26/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class FederationAddressLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansRegular(size: 12)
        textColor = Stylesheet.color(.orange)
    }
}
