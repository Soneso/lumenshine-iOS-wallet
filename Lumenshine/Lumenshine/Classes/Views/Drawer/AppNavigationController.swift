//
//  AppNavigationController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class AppNavigationController: NavigationController {
    override func prepare() {
        super.prepare()
        navigationBar.backIndicatorImage = Icon.arrowBack?.tint(with: Stylesheet.color(.blue))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
