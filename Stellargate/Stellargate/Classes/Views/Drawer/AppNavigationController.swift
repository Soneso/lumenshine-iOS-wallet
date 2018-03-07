//
//  AppNavigationController.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/1/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class AppNavigationController: NavigationController {
    override func prepare() {
        super.prepare()
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = Stylesheet.color(.cyan)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
}
