//
//  RoundedButton.swift
//  Lumenshine
//
//  Created by Soneso on 21/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class RoundedButton: BaseButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        cornerRadiusPreset = .cornerRadius6
       
        guard #available(iOS 11, *) else {
            contentEdgeInsets.left = horizontalInset
            contentEdgeInsets.right = horizontalInset
            contentEdgeInsets.top = verticalInset
            contentEdgeInsets.bottom = verticalInset
            return
        }
    }
}
