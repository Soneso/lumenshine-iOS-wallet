//
//  SetupMenuCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SetupMenuCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let menuView: MenuViewController
    
    init(service: AuthService, user: User, loginResponse: LoginStep2Response?) {
        self.service = service
        self.user = user
        
        let menuViewModel = SetupMenuViewModel(service: service, user: user)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        showSetup(loginResponse: loginResponse)
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .logout(let transition):
            logout(transtion: transition)
        default:
            break
        }
    }
}

fileprivate extension SetupMenuCoordinator {
    func logout(transtion: Transition?) {
        let loginCoordinator = LoginMenuCoordinator(transition: transtion)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showSetup(loginResponse: LoginStep2Response?) {
        let coordinator = SetupCoordinator(service: service, user: user, loginResponse: loginResponse)
        
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController as? AppNavigationDrawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            menuView.present(coordinator.baseController)
        }
    }
}
