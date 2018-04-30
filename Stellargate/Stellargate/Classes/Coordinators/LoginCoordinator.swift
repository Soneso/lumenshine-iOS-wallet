//
//  LoginCoordinator.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let service: Services
    
    init() {
        self.service = Services()
        let viewModel = LoginViewModel()
        let navigation = AppNavigationController(rootViewController: LoginViewController(viewModel: viewModel))
        self.baseController = navigation
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showMain(let user):
            showMain(user: user)
        case .showSignUp:
            showSignUp()
        default: break
        }
    }
}

fileprivate extension LoginCoordinator {
    func showMain(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let mainNavigation = menuCoordinator.baseController.evo_drawerController {
            (baseController as! AppNavigationController).pushViewController(mainNavigation, animated: true)
        }
//        if let window = self.baseController.view.window {
//            window.rootViewController = mainNavigation
//        } else {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = mainNavigation
//        }
//
//        self.baseController.dismiss(animated: true)
    }
    
    func showSignUp() {
        let registrationCoordinator = RegistrationCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(registrationCoordinator.baseController, animated: true)
    }
}

