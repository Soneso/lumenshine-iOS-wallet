//
//  AlertFactory.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit.UIAlertController

struct AlertFactory {
    static func createAlert(error: ServiceError) -> UIAlertController {
        let alertView = UIAlertController(title: R.string.localizable.error(),
                                          message: error.errorDescription,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default)
        alertView.addAction(okAction)
        return alertView
    }
    
    static func createAlert(title: String, message: String) -> UIAlertController {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default)
        alertView.addAction(okAction)
        return alertView
    }
}
