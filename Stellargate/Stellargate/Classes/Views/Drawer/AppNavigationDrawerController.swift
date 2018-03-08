//
//  AppNavigationDrawerController.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/1/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import DrawerController

class AppNavigationDrawerController: DrawerController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        minimumAnimationDuration = 0.4
        
        openDrawerGestureModeMask = [.panningCenterView, .panningNavigationBar]
        closeDrawerGestureModeMask = [.panningCenterView, .panningNavigationBar]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}

