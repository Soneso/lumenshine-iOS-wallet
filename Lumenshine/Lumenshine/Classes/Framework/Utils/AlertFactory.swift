//
//  AlertFactory.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/10/18.
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
}
