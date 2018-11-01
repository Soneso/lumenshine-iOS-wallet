//
//  ImageButton.swift
//  Lumenshine
//
//  Created by Soneso on 31/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class ImageButton: UIButton {
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(-10, -10, -10, -10))
        return hitFrame.contains(point)
    }
}
