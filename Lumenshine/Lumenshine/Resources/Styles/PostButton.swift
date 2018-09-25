//
//  PostButton.swift
//  Lumenshine
//
//  Created by Soneso on 21/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class PostButton: UIButton {
    fileprivate let horizontalInset = CGFloat(20)
    fileprivate let verticalInset = CGFloat(10)
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        backgroundColor = Stylesheet.color(.blue)
        setTitleColor(Stylesheet.color(.white), for: .normal)
        setTitleColor(Stylesheet.color(.helpButtonGray), for: .disabled)
        cornerRadiusPreset = .cornerRadius6
        titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        contentEdgeInsets.left = horizontalInset
        contentEdgeInsets.right = horizontalInset
        contentEdgeInsets.top = verticalInset
        contentEdgeInsets.bottom = verticalInset
    }
}
