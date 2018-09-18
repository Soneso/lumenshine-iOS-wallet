//
//  AppTitleLabel.swift
//  Lumenshine
//
//  Created by Soneso on 14/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class AppTitleLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansSemiBold(size: 19)
        textColor = Stylesheet.color(.cyan)
    }
}
