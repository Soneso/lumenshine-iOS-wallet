//
//  AppNavigationDrawerController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import KWDrawerController

class AppNavigationDrawerController: DrawerController {
    var hideStatusBar = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        options.isTapToClose = true
        options.isGesture = true
        options.isAnimation = true
        options.isOverflowAnimation = true
        options.isShadow = false
        options.isFadeScreen = false
        options.isBlur = false
        options.isEnable = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
}
