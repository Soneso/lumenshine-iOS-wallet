//
//  AmountSegmentedControl.swift
//  Lumenshine
//
//  Created by Soneso on 24/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class AmountSegmentedControl: UISegmentedControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        backgroundColor = Stylesheet.color(.clear)
        tintColor = Stylesheet.color(.clear)

        setTitleTextAttributes([
            NSAttributedString.Key.font : R.font.encodeSansSemiBold(size: 12)!,
            NSAttributedString.Key.foregroundColor: Stylesheet.color(.helpButtonGray)
            ], for: .normal)
        
        setTitleTextAttributes([
            NSAttributedString.Key.font : R.font.encodeSansSemiBold(size: 12)!,
            NSAttributedString.Key.foregroundColor: Stylesheet.color(.blue)
            ], for: .selected)
                
        if subviews.count == 2 {
            if #available(iOS 11, *) {
                setBorder(forSegment: subviews[0], isFirst: true)
                setBorder(forSegment: subviews[1])
            }
        }
        
        setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: UIBarMetrics.default)
    }
    
    private func setBorder(forSegment segment: UIView, isFirst: Bool = false) {
        segment.layer.borderColor = Stylesheet.color(.borderGray).cgColor
        segment.layer.borderWidth = 0.33
        segment.clipsToBounds = true
        segment.roundCorners(isFirst ? [.layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner], radius: CornerRadiusPresetToValue(preset: .cornerRadius4))
    }
}
