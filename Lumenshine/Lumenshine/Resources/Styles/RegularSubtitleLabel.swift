//
//  RegularSubtitleLabel.swift
//  Lumenshine
//
//  Created by Soneso on 01/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class RegularSubtitleLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansRegular(size: 16)
        textColor = Stylesheet.color(.lightBlack)
    }
}
