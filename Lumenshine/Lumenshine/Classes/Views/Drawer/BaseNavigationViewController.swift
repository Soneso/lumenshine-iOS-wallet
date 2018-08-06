//
//  BaseNavigationViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 06/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = Stylesheet.color(.cyan)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}
