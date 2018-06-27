//
//  SettingsCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SettingsCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: AuthService, user: User) {
        let viewModel = SettingsViewModel(service: service, user: user)
        self.baseController = SettingsTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .logout:
            logout()
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
}
