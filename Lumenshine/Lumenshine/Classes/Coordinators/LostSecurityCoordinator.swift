//
//  LostSecurityCoordinator.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LostSecurityCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: AuthService
    fileprivate let viewModel: LostSecurityViewModel
    
    init(mainCoordinator: MainCoordinator, service: AuthService, lostPassword: Bool) {
        self.service = service
        self.mainCoordinator = mainCoordinator
        self.viewModel = LostSecurityViewModel(service: service, lostPassword: lostPassword)
        
        let viewController = LostSecurityViewController(nibName: "LostSecurityViewController", bundle: Bundle.main)
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

fileprivate extension LostSecurityCoordinator {
    func showSuccess() {
        let successVC = LostSecuritySuccessViewController(viewModel: viewModel)
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
