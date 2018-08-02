//
//  SettingsCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SettingsCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    fileprivate let viewModel: SettingsViewModel
    fileprivate let service: Services
    fileprivate let user: User
    
    init(service: Services, user: User) {
        self.service = service
        self.user = user
        self.viewModel = SettingsViewModel(service: service.auth, user: user)
        self.baseController = SettingsTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .logout:
            logout()
        case .showChangePassword:
            showChangePassword()
        case .showPasswordHint(let hint):
            showPasswordHint(hint)
        case .showHome:
            showHome()
        case .showSettings:
            showSettings()
        case .showChange2faSecret:
            showChange2faSecret()
        case .showNew2faSecret:
            showNew2faSecret()
        default: break
        }
    }
}

fileprivate extension SettingsCoordinator {
    func logout() {
        let loginCoordinator = LoginMenuCoordinator()
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {        
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showChangePassword() {
        let changeVC = ChangePasswordViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(changeVC, animated: true)
    }
    
    func showChange2faSecret() {
        let changeVC = Change2faSecretViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(changeVC, animated: true)
    }
    
    func showNew2faSecret() {
        let tfaSecretVC = Confirm2faCodeViewController(viewModel: viewModel)
        let snackBarVC = SnackbarController(rootViewController: tfaSecretVC)
        baseController.navigationController?.pushViewController(snackBarVC, animated: true)
    }
    
    func showPasswordHint(_ hint: String) {
        let title = R.string.localizable.password_hint_title()
        let textVC = TextViewController(title: title, text: hint)
        baseController.present(AppNavigationController(rootViewController: textVC), animated: true)
    }
    
    func showHome() {
        let coordinator = HomeCoordinator(service: service.home, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController.drawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            if let menu = drawer.getViewController(for: .left) as? MenuViewController {
                menu.present(coordinator.baseController)
            }
        }
    }
    
    func showSettings() {
        baseController.navigationController?.popToRootViewController(animated: true)
    }
}
