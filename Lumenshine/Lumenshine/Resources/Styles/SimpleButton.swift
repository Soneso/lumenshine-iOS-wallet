//
//  SimpleButton.swift
//  Lumenshine
//
//  Created by Soneso on 08/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SimpleButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        tintColor = Stylesheet.color(.blue)
        titleLabel?.font = R.font.encodeSansRegular(size: 14)
        titleLabel?.textColor = Stylesheet.color(.blue)
    }
}
