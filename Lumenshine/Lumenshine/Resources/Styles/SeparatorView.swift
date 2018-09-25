//
//  SeparatorView.swift
//  Lumenshine
//
//  Created by Soneso on 20/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SeparatorView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        backgroundColor = Stylesheet.color(.helpButtonGray)
    }
}

