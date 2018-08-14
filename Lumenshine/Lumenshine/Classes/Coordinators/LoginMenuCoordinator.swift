//
//  LoginMenuCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/26/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginMenuCoordinator: MenuCoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: Services
    fileprivate let menuView: MenuViewController
    
    init(mainCoordinator: MainCoordinator, transition: Transition? = .showLogin) {
        self.service = Services()
        self.mainCoordinator = mainCoordinator
        
        let menuViewModel = LoginMenuViewModel(service: service.auth)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        performTransition(transition: transition ?? .showLogin)
        mainCoordinator.currentMenuCoordinator = self
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
        let loginCoordinator = LoginCoordinator(mainCoordinator: mainCoordinator, service: service.auth)
        let navigationController = AppNavigationController(rootViewController: loginCoordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(loginCoordinator.baseController)
        }
    }
    
    func showSignUp() {
        let loginCoordinator = LoginCoordinator(mainCoordinator: mainCoordinator, service: service.auth, transition: .showSignUp)
        let navigationController = AppNavigationController(rootViewController: loginCoordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(loginCoordinator.baseController)
        }
    }
    
    func showForgotPassword() {
        showLostSecurity(lostPassword: true)
    }
    
    func showLost2fa() {
        showLostSecurity(lostPassword: false)
    }
    
    func showLostSecurity(lostPassword: Bool) {
        let lostSecurityCoordinator = LostSecurityCoordinator(mainCoordinator: mainCoordinator, service: service.auth, lostPassword: lostPassword)
        let snackBar = SnackbarController(rootViewController: lostSecurityCoordinator.baseController)
        let navigationController = AppNavigationController(rootViewController: snackBar)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(snackBar)
        }
    }
}


