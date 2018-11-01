//
//  HelpButton.swift
//  Lumenshine
//
//  Created by Soneso on 19/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HelpButton: ImageButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        setImage(R.image.question()?.crop(toWidth: 16, toHeight: 16)?.tint(with: Stylesheet.color(.helpButtonGray)), for: .normal)
    }    
}
