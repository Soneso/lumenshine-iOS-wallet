//
//  SubtitleLabel.swift
//  Lumenshine
//
//  Created by Soneso on 21/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SubtitleLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansSemiBold(size: 14)
        textColor = Stylesheet.color(.lightBlack)
    }
}
