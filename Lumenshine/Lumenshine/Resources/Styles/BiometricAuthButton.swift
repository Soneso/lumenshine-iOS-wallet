//
//  BiometricAuthButton.swift
//  Lumenshine
//
//  Created by Soneso on 05/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class BiometricAuthButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        tintColor = Stylesheet.color(.clear)
        let image = UIImage(named: BiometricHelper.touchIcon.name)
        setBackgroundImage(image, for: .normal)
    }
}
