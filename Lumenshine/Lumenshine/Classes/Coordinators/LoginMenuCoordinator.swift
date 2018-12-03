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
        drawer.setDrawerWidth(180, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        performTransition(transition: transition ?? .showLogin)
        mainCoordinator.currentMenuCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showLogin, .showSignUp, .showForgotPassword, .showLost2fa:
            performLoginTransition(transition)
        case .showHelp:
            showHelpCenter()
        case .showAbout:
            showAbout()
        default:
            break
        }
    }
}

fileprivate extension LoginMenuCoordinator {
    func performLoginTransition(_ transition: Transition) {
        if let coordinator = mainCoordinator.currentCoordinator as? LoginCoordinator {
            coordinator.performTransition(transition: transition)
        } else {
            createLoginCoordinator().performTransition(transition: transition)
        }
        (baseController as! AppNavigationDrawerController).closeSide()
    }
    
    func createLoginCoordinator() -> LoginCoordinator {
        let loginCoordinator = LoginCoordinator(mainCoordinator: mainCoordinator, service: service.auth)
        let snackBar = SnackbarController(rootViewController: loginCoordinator.baseController)
        let navigationController = AppNavigationController(rootViewController: snackBar)
        navigationController.navigationBar.isTranslucent = true
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(snackBar)
        }
        return loginCoordinator
    }
    
    func showHelpCenter() {
        let coordinator = HelpCenterCoordinator(mainCoordinator: mainCoordinator, service: service)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(coordinator.baseController)
        }
    }
    func showAbout() {
        let aboutVC = WebViewController(title: R.string.localizable.about(), url: Services.shared.aboutUrl)
        let composeVC = ComposeNavigationController(rootViewController: aboutVC)
        baseController.present(composeVC, animated: true)
    }
}


