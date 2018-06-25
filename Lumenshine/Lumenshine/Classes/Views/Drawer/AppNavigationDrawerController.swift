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
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        
    }
}

