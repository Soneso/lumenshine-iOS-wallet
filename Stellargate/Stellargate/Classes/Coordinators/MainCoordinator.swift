//
//  MainCoordinator.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/15/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MainCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let drawer: AppNavigationDrawerController
    
    init() {
//        let viewModel = MenuViewModel()
        let menuView = MenuViewController(style: .grouped)
        
        drawer = AppNavigationDrawerController(centerViewController: UIViewController(), leftDrawerViewController: menuView, rightDrawerViewController: nil)
        drawer.maximumLeftDrawerWidth = 260
        
        self.baseController = menuView
//        viewModel.navigationCoordinator = self
        showHome()
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHome:
            showHome()
        default: break
        }
    }
}

fileprivate extension MainCoordinator {
    func showHome() {
        let coordinator = HomeCoordinator()
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        drawer.setCenter(navigationController, withCloseAnimation: false, completion: nil)
        (baseController as! MenuViewController).present(coordinator.baseController)
    }
}
