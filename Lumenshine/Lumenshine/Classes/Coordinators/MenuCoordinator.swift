//
//  MainCoordinator.swift
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

class MenuCoordinator: MenuCoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let menuView: MenuViewController
    fileprivate let user: User
    
    init(mainCoordinator: MainCoordinator, user: User) {
        self.user = user
        self.mainCoordinator = mainCoordinator
        
        let viewModel = MenuViewModel(user: user)
        menuView = MenuViewController(viewModel: viewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        drawer.setDrawerWidth(180, for: .left)
        
        self.baseController = drawer
        viewModel.navigationCoordinator = self
        showHome()
        mainCoordinator.currentMenuCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHome:
            showHome()
        case .showSettings:
            showSettings()
        case .showExtras:
            showExtras()
        case .showHelp:
            showHelpCenter()
        case .showContacts:
            showContacts()
        case .showRelogin:
            showRelogin()
        case .logout:
            logout()
        case .showWallets:
            showWallets()
        case .showTransactions:
            showTransactions()
        default: break
        }
    }
    deinit {
        if let drawer = baseController as? AppNavigationDrawerController {
            for vc in drawer.children {
                if let nvc = vc as? NavigationController {
                    nvc.removeFromParent()
                }
            }
        }
    }
}

fileprivate extension MenuCoordinator {
    func showHome() {
        let coordinator = HomeCoordinator(mainCoordinator: mainCoordinator)
        let navigationController = ImageBackgroundNavigationController(rootViewController: coordinator.baseController)
        present(navigationController: navigationController)
    }
    
    func showWallets() {
        let coordinator = WalletsCoordinator(mainCoordinator: mainCoordinator)
        let navigationController = ImageBackgroundNavigationController(rootViewController: coordinator.baseController, alwaysShowBackgroundImage: true)
        present(navigationController: navigationController)
    }
    
    func showSettings() {
        let coordinator = SettingsCoordinator(mainCoordinator: mainCoordinator, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        present(navigationController: navigationController)
    }
    
    func showExtras() {
        let coordinator = ExtrasCoordinator(mainCoordinator: mainCoordinator, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        present(navigationController: navigationController)
    }
    
    func showHelpCenter() {
        let coordinator = HelpCenterCoordinator(mainCoordinator: mainCoordinator)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        present(navigationController: navigationController)
    }
    
    func showContacts() {
        let coordinator = ContactsCoordinator(mainCoordinator: mainCoordinator, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        present(navigationController: navigationController)
    }
    
    func showTransactions() {
        let coordinator = TransactionsCoordinator(mainCoordinator: mainCoordinator)
        let snackBar = SnackbarController(rootViewController: coordinator.baseController)
        let navigationController = AppNavigationController(rootViewController: snackBar)
        present(navigationController: navigationController)
    }
    
    func showRelogin() {
        let coordinator = ReLoginMenuCoordinator(mainCoordinator: mainCoordinator, user: user)
        present(coordinator: coordinator)
    }
    
    func logout() {
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator)
        present(coordinator: loginCoordinator)
    }
    
    func present(coordinator: CoordinatorType) {
        if let window = UIApplication.shared.delegate?.window {
            UIView.transition(with: window!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window!.rootViewController = coordinator.baseController
            }, completion: nil)
        } else {
            let window = baseController.view.window
            UIView.transition(with: window!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window!.rootViewController = coordinator.baseController
            }, completion: nil)
        }
    }
    
    func present(navigationController: NavigationController) {
        if let drawer = baseController as? AppNavigationDrawerController {
            for vc in drawer.children {
                if type(of: vc) == type(of: navigationController) {
                    vc.removeFromParent()
                }
            }
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(navigationController.viewControllers[0])
        }
    }
}
