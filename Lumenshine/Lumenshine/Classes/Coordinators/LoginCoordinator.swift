//
//  LoginCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let service: Services
    fileprivate let menuView: MenuViewController
    
    init() {
        self.service = Services()
//        let viewModel = LoginViewModel(service: service.auth)
//        let navigation = AppNavigationController(rootViewController: LoginViewController(viewModel: viewModel))
        
        let menuViewModel = LoginMenuViewModel(service: service.auth)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.drawerWidth = 260
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        showLogin(updateMenu: false)
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showDashboard(let user):
            showDashboard(user: user)
        case .showSignUp:
            showSignUp()
        case .showForgotPassword:
            showForgotPassword()
        case .showLost2fa:
            showLost2fa()
        case .show2FA(let user, let registrationResponse):
            show2FA(user: user, response: registrationResponse)
        case .showMnemonic(let user):
            showMnemonicQuiz(user: user)
        case .showEmailConfirmation(let user):
            showEmailConfirmation(user: user)
        default:
            break
        }
    }
}

fileprivate extension LoginCoordinator {
    func showLogin(updateMenu: Bool = true) {
        let viewModel = LoginViewModel(service: service.auth)
        let loginView = LoginViewController(viewModel: viewModel)
        let navigationController = AppNavigationController(rootViewController: loginView)
        (baseController as! AppNavigationDrawerController).setViewController(navigationController, for: .none)
        menuView.present(loginView, updateMenu: updateMenu)
    }
    
    func showDashboard(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window.rootViewController = menuCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showSignUp() {
        let registrationCoordinator = RegistrationCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(registrationCoordinator.baseController, animated: true)
    }
    
    func showForgotPassword() {
        let forgotPasswordCoordinator = ForgotPasswordCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(forgotPasswordCoordinator.baseController, animated: true)
    }
    
    func showLost2fa() {
        let forgotPasswordCoordinator = Lost2faCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(forgotPasswordCoordinator.baseController, animated: true)
    }
    
    func show2FA(user: User, response: RegistrationResponse) {
        let tfaCoordinator = TFARegistrationCoordinator(service: service.auth, user: user, response: response)
        (baseController as! AppNavigationController).pushViewController(tfaCoordinator.baseController, animated: true)
    }
    
    func showMnemonicQuiz(user: User) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service.auth, user: user)
        (baseController as! AppNavigationController).pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
    
    func showEmailConfirmation(user: User) {
        let emailCoordinator = EmailConfirmationCoordinator(service: service.auth, user: user)
        (baseController as! AppNavigationController).pushViewController(emailCoordinator.baseController, animated: true)
    }
}

