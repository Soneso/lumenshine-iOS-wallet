//
//  ReLoginMenuCoordinator.swift
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

class ReLoginMenuCoordinator: MenuCoordinatorType {
    var baseController: UIViewController
    
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let services: Services
    fileprivate let user: User
    fileprivate let menuView: MenuViewController
    
    init(mainCoordinator: MainCoordinator, user: User) {
        self.services = Services()
        self.user = user
        self.mainCoordinator = mainCoordinator
        
        let menuViewModel = ReLoginMenuViewModel(services: services, user: user)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        drawer.setDrawerWidth(180, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        showRelogin()
        mainCoordinator.currentMenuCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .logout(let transition):
            logout(transtion: transition)
        case .showRelogin:
            showRelogin()
        default:
            break
        }
    }
}

fileprivate extension ReLoginMenuCoordinator {
    func logout(transtion: Transition?) {
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator, transition: transtion)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showRelogin() {
        let loginCoordinator = ReLoginCoordinator(mainCoordinator: mainCoordinator, user: user)
        let navigationController = AppNavigationController(rootViewController: loginCoordinator.baseController)
        navigationController.navigationBar.isTranslucent = true
        if let drawer = baseController as? AppNavigationDrawerController {
            for vc in drawer.children {
                if type(of: vc) == type(of: navigationController) {
                    vc.removeFromParent()
                }
            }
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(loginCoordinator.baseController)
        }
    }
}

