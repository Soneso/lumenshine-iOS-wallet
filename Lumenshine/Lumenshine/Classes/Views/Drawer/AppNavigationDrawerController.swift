//
//  AppNavigationDrawerController.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/1/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import KWDrawerController

class AppNavigationDrawerController: DrawerController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        minimumAnimationDuration = 0.4
//        openDrawerGestureModeMask = [.panningCenterView, .panningNavigationBar]
//        closeDrawerGestureModeMask = [.panningCenterView, .panningNavigationBar]
        
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
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

