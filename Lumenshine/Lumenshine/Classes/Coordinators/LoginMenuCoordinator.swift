//
//  LoginMenuCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/26/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginMenuCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let service: Services
    fileprivate let menuView: MenuViewController
    
    init(transition: Transition? = .showLogin) {
        self.service = Services()
        
        let menuViewModel = LoginMenuViewModel(service: service.auth)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        performTransition(transition: transition ?? .showLogin)
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showLogin:
            showLogin()
        case .showSignUp:
            showSignUp()
        case .showForgotPassword:
            showForgotPassword()
        case .showLost2fa:
            showLost2fa()
        default:
            break
        }
    }
}

fileprivate extension LoginMenuCoordinator {
    func showLogin() {
        let loginCoordinator = LoginCoordinator(service: service.auth)
        let navigationController = AppNavigationController(rootViewController: loginCoordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(loginCoordinator.baseController)
        }
    }
    
    func showSignUp() {
        let registrationCoordinator = RegistrationCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(registrationCoordinator.baseController, animated: true)
    }
    
    func showForgotPassword() {
        let forgotPasswordCoordinator = ForgotPasswordCoordinator(service: service.auth)
        let navigationController = AppNavigationController(rootViewController: forgotPasswordCoordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(forgotPasswordCoordinator.baseController)
        }
    }
    
    func showLost2fa() {
        let forgotPasswordCoordinator = Lost2faCoordinator(service: service.auth)
        let navigationController = AppNavigationController(rootViewController: forgotPasswordCoordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(forgotPasswordCoordinator.baseController)
        }
    }
}


