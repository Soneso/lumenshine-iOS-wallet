//
//  UIApplication+ViewControllerTree.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 20/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func topMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}

