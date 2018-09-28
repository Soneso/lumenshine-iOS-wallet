//
//  BaseButton.swift
//  Lumenshine
//
//  Created by Soneso on 27/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class BaseButton: UIButton {
    private let horizontalInset = CGFloat(20)
    private let verticalInset = CGFloat(10)

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        setTitleColor(Stylesheet.color(.white), for: .normal)
        setTitleColor(Stylesheet.color(.helpButtonGray), for: .disabled)
        titleLabel?.font = R.font.encodeSansSemiBold(size: 13)
        contentEdgeInsets.left = horizontalInset
        contentEdgeInsets.right = horizontalInset
        contentEdgeInsets.top = verticalInset
        contentEdgeInsets.bottom = verticalInset
    }
}
