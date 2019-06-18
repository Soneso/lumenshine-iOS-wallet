//
//  LoginMenuCoordinator.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
        let loginCoordinator = LoginCoordinator(mainCoordinator: mainCoordinator)
        let snackBar = SnackbarController(rootViewController: loginCoordinator.baseController)
        let navigationController = AppNavigationController(rootViewController: snackBar)
        navigationController.navigationBar.isTranslucent = true
        if let drawer = baseController as? AppNavigationDrawerController {
            for vc in drawer.children {
                if type(of: vc) == type(of: navigationController) {
                    vc.removeFromParent()
                }
            }
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(snackBar)
        }
        return loginCoordinator
    }
    
    func showHelpCenter() {
        let coordinator = HelpCenterCoordinator(mainCoordinator: mainCoordinator)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            for vc in drawer.children {
                if type(of: vc) == type(of: navigationController) {
                    vc.removeFromParent()
                }
            }
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(coordinator.baseController)
        }
    }
    func showAbout() {
        
        let helpDetailsVC = HelpDetailsViewController()
        helpDetailsVC.modalTitle = R.string.localizable.about()
        helpDetailsVC.infoText = R.string.localizable.about_info()
        helpDetailsVC.linksDict = [R.string.localizable.about_info_soneso_link_key() : R.string.localizable.about_info_soneso_link().components(separatedBy: ",")]
        
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.closeSide()
        }
        
        let composeVC = ComposeNavigationController(rootViewController: helpDetailsVC)
        baseController.present(composeVC, animated: true)
    }
}
