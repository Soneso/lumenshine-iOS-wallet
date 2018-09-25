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
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
