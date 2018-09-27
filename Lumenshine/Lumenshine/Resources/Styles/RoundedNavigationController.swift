//
//  RoundedNavigationController.swift
//  Lumenshine
//
//  Created by Soneso on 25/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class RoundedNavigationController: ComposeNavigationController {
    override func layoutSubviews() {
        super.layoutSubviews()
        if let cgImage = R.image.header_background()?.cgImage {
            let backgroundImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .down).crop(toWidth: navigationBar.frame.width, toHeight: navigationBar.frame.width)
            navigationBar.setBackgroundImage(backgroundImage, for: UIBarMetrics.default)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
