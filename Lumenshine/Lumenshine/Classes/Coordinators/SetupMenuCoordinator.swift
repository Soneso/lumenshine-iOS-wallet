//
//  SetupMenuCoordinator.swift
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

class SetupMenuCoordinator: MenuCoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let user: User
    fileprivate let menuView: MenuViewController
    
    init(mainCoordinator: MainCoordinator, user: User, mnemonic: String, tfaConfirmed: Bool, mailConfirmed: Bool, mnemonicConfirmed: Bool, tfaSecret: String?) {
        self.user = user
        self.mainCoordinator = mainCoordinator
        
        let menuViewModel = SetupMenuViewModel(user: user)
        menuView = MenuViewController(viewModel: menuViewModel)
        
        let drawer = AppNavigationDrawerController()
        drawer.setViewController(menuView, for: .left)
        
        self.baseController = drawer
        menuViewModel.navigationCoordinator = self
        showSetup(user: user, mnemonic: mnemonic, tfaConfirmed: tfaConfirmed, mailConfirmed: mailConfirmed, mnemonicConfirmed: mnemonicConfirmed, tfaSecret: tfaSecret)
        mainCoordinator.currentMenuCoordinator = self
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
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator, transition: transtion)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showSetup(user: User, mnemonic: String, tfaConfirmed: Bool, mailConfirmed: Bool, mnemonicConfirmed: Bool, tfaSecret: String?) {
        let coordinator = SetupCoordinator(mainCoordinator: mainCoordinator, user: user, mnemonic: mnemonic, tfaConfirmed: tfaConfirmed, mailConfirmed: mailConfirmed, mnemonicConfirmed: mnemonicConfirmed, tfaSecret:tfaSecret)
        
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        navigationController.navigationBar.isTranslucent = true
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
}
