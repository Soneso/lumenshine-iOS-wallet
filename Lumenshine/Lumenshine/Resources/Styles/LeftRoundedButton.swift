//
//  LeftRoundedButton.swift
//  Lumenshine
//
//  Created by Soneso on 27/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LeftRoundedButton: BaseButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner ], radius: CornerRadiusPresetToValue(preset: .cornerRadius6))
    }
}
