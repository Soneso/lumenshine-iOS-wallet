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
//        navigationBar.backgroundColor = Stylesheet.color(.blue)
        navigationBar.backIndicatorImage = Icon.arrowBack?.tint(with: Stylesheet.color(.blue))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
