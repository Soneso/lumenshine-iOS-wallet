//
//  ReLoginMenuCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ReLoginMenuCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let menuView: MenuViewController
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        let menuViewModel = ReLoginMenuViewModel(service: service, user: user)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        showRelogin()
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
        let loginCoordinator = LoginMenuCoordinator(transition: transtion)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showRelogin() {
        let loginCoordinator = ReLoginCoordinator(service: service, user: user)
        let navigationController = AppNavigationController(rootViewController: loginCoordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(loginCoordinator.baseController)
        }
    }
}

