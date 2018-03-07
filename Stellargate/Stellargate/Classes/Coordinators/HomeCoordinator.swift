//
//  HomeCoordinator.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HomeCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init() {
        let viewModel = HomeViewModel()
        
        let menuView = MenuViewController(style: .grouped)
        let homeView = HomeViewController(viewModel: viewModel)
        
        let navigationController = AppNavigationController(rootViewController: homeView)
        let drawer = AppNavigationDrawerController(centerViewController: navigationController, leftDrawerViewController: menuView, rightDrawerViewController: nil)
        
        menuView.present(homeView)
        
        self.baseController = drawer
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        
    }
}

fileprivate extension HomeCoordinator {
    
}

