//
//  NormalLabel.swift
//  Lumenshine
//
//  Created by Soneso on 20/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class NormalLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansSemiBold(size: 10)
        textColor = Stylesheet.color(.lightBlack)
    }
}
