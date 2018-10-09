//
//  HintLabel.swift
//  Lumenshine
//
//  Created by Soneso on 05/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HintLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        if let hintFont = R.font.encodeSansRegular(size: 14) {
            var fontSymbolTraits = hintFont.fontDescriptor.symbolicTraits
            fontSymbolTraits.insert([.traitItalic])
            if let fontDescriptorWithSymbolicTraits = font.fontDescriptor.withSymbolicTraits(fontSymbolTraits) {
                font = UIFont(descriptor: fontDescriptorWithSymbolicTraits, size: hintFont.pointSize)
            }
        }
        
        textColor = Stylesheet.color(.gray)
    }
}
