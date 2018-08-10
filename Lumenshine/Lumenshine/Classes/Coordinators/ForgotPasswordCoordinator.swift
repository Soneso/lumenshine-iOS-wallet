//
//  ForgotPasswordCoordinator.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ForgotPasswordCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: AuthService
    fileprivate let viewModel: ForgotPasswordViewModel
    
    init(mainCoordinator: MainCoordinator, service: AuthService) {
        self.service = service
        self.mainCoordinator = mainCoordinator
        self.viewModel = ForgotPasswordViewModel(service: service)
        
        let viewController = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: Bundle.main)
        viewController.viewModel = viewModel
        self.baseController = viewController
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showLostPasswordSuccess:
            showSuccess()
        case .showEmailConfirmation:
            showEmailConfirmation()
        default: break
        }
    }
}

fileprivate extension ForgotPasswordCoordinator {
    func showSuccess() {
        let successVC = LostPasswordSuccessViewController(viewModel: viewModel)
        let snackBarVC = SnackbarController(rootViewController: successVC)
        baseController.navigationController?.popToRootViewController(animated: false)
        baseController.navigationController?.pushViewController(snackBarVC, animated: true)
    }
    
    func showEmailConfirmation() {
        let emailVC = EmailConfirmationViewController(viewModel: viewModel)
        let snackBarVC = SnackbarController(rootViewController: emailVC)
        baseController.navigationController?.pushViewController(snackBarVC, animated: true)
    }
}
