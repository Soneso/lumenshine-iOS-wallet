//
//  ForgotPasswordCoordinator.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class ForgotPasswordCoordinator: CoordinatorType {
    var baseController: UIViewController
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
        let viewModel = ForgotPasswordViewModel(service: service)
        
        let viewController = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: Bundle.main)
        viewController.viewModel = viewModel
        self.baseController = viewController
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        default: break
        }
    }
}
