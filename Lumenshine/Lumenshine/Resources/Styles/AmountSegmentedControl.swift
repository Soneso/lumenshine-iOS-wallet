//
//  AmountSegmentedControl.swift
//  Lumenshine
//
//  Created by Soneso on 24/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class AmountSegmentedControl: UISegmentedControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        backgroundColor = Stylesheet.color(.clear)
        tintColor = Stylesheet.color(.clear)

        setTitleTextAttributes([
            NSAttributedStringKey.font : R.font.encodeSansSemiBold(size: 12)!,
            NSAttributedStringKey.foregroundColor: Stylesheet.color(.helpButtonGray)
            ], for: .normal)
        
        setTitleTextAttributes([
            NSAttributedStringKey.font : R.font.encodeSansSemiBold(size: 12)!,
            NSAttributedStringKey.foregroundColor: Stylesheet.color(.blue)
            ], for: .selected)
                
        if subviews.count == 2 {
            setBorder(forSegment: subviews[0], isFirst: true)
            setBorder(forSegment: subviews[1])
        }
        
        setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: UIBarMetrics.default)
    }
    
    private func setBorder(forSegment segment: UIView, isFirst: Bool = false) {
        segment.layer.borderColor = Stylesheet.color(.borderGray).cgColor
        segment.layer.borderWidth = 0.33
        segment.clipsToBounds = true
        segment.layer.cornerRadiusPreset = .cornerRadius4
        segment.layer.maskedCorners = isFirst ? [.layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
}
