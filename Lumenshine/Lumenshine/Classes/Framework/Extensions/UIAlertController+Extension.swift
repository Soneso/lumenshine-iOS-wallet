//
//  UIAlertController+Extension.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

fileprivate class AlertContainerViewController: UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIAlertController {
    
    private struct AssociatedKeys {
        static var activityIndicator = "xxx_window"
    }
    
    var xxx_window: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIWindow
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.activityIndicator,
                    newValue as UIWindow?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    func showOnANewWindow() {
        xxx_window = UIWindow(frame: UIScreen.main.bounds)
        xxx_window?.rootViewController = AlertContainerViewController()
        
        if let topWindow = UIApplication.shared.windows.last {
            xxx_window?.windowLevel = topWindow.windowLevel + 1
            
            xxx_window?.makeKeyAndVisible()
            xxx_window?.rootViewController?.present(self, animated: true, completion: nil)
        }
    }
}
