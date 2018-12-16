//
//  SloganLabel.swift
//  Lumenshine
//
//  Created by Soneso on 14/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SloganLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansRegular(size: 13)
        textColor = Stylesheet.color(.white)
    }
}
