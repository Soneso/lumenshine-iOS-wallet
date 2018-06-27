//
//  MainCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/15/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class MenuCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let menuView: MenuViewController
    fileprivate let service: Services
    fileprivate let user: User
    
    init(user: User) {
        self.user = user
        self.service = Services()
        
        let viewModel = MenuViewModel(service: service.auth, user: user)
        menuView = MenuViewController(viewModel: viewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        viewModel.navigationCoordinator = self
        showHome()
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHome:
            showHome()
        case .showSettings:
            showSettings()
        case .showRelogin:
            showRelogin()
        default: break
        }
    }
}

fileprivate extension MenuCoordinator {
    func showHome() {
        let coordinator = HomeCoordinator(service: service.home, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        (baseController as! AppNavigationDrawerController).setViewController(navigationController, for: .none)
        menuView.present(coordinator.baseController)
    }
    
    func showSettings() {
        let coordinator = SettingsCoordinator(service: service.auth, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        (baseController as! AppNavigationDrawerController).setViewController(navigationController, for: .none)
        menuView.present(coordinator.baseController)
    }
    
    func showRelogin() {
        let coordinator = ReLoginCoordinator(service: service.auth)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        (baseController as! AppNavigationDrawerController).present(navigationController, animated: true, completion: nil)
    }
}
