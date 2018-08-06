//
//  MainCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/15/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class MenuCoordinator: MenuCoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let menuView: MenuViewController
    fileprivate let service: Services
    fileprivate let user: User
    
    init(mainCoordinator: MainCoordinator, user: User) {
        self.user = user
        self.service = Services()
        self.mainCoordinator = mainCoordinator
        
        let viewModel = MenuViewModel(service: service.auth, user: user)
        menuView = MenuViewController(viewModel: viewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
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
        case .showRelogin:
            showRelogin()
        case .logout:
            logout()
        default: break
        }
    }
}

fileprivate extension MenuCoordinator {
    func showHome() {
        let coordinator = HomeCoordinator(mainCoordinator: mainCoordinator, service: service.home, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(coordinator.baseController)
        }
    }
    
    func showSettings() {
        let coordinator = SettingsCoordinator(mainCoordinator: mainCoordinator, service: service, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(coordinator.baseController)
        }
    }
    
    func showRelogin() {
        let coordinator = ReLoginMenuCoordinator(mainCoordinator: mainCoordinator, service: service.auth, user: user)
        baseController.present(coordinator.baseController, animated: true)
    }
    
    func logout() {
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
}
