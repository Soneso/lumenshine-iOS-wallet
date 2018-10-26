//
//  RoundedBackgroundLabel.swift
//  Lumenshine
//
//  Created by Soneso on 26/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class RoundedBackgroundLabel: UILabel {
    open var insets : UIEdgeInsets = UIEdgeInsets() {
        didSet {
            super.invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
    
    override open func drawText(in rect: CGRect) {
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        font = R.font.encodeSansBold(size: 14)
        insets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        textColor = Stylesheet.color(.white)
        layer.masksToBounds = true
        layer.cornerRadiusPreset = .cornerRadius2
    }
}
