//
//  RightRoundedButton.swift
//  Lumenshine
//
//  Created by Soneso on 27/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class RightRoundedButton: BaseButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        cornerRadiusPreset = .cornerRadius6
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner ]
    }
}
