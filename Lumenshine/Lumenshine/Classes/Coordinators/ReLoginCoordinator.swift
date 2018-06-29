//
//  ReLoginCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/31/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class ReLoginCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: AuthService, user: User) {
        let viewModel = ReLoginViewModel(service: service, user: user)
        self.baseController = ReLoginViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .openDashboard:
            openDashboard()
        case .logout(let transition):
            logout(transtion: transition)
        case .showRelogin:
            showRelogin()
        default:
            break
        }
    }
}

fileprivate extension ReLoginCoordinator {
    func openDashboard() {
        baseController.dismiss(animated: true, completion: nil)
    }
    
    func logout(transtion: Transition?) {
        let loginCoordinator = LoginMenuCoordinator(transition: transtion)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showRelogin() {

    }
}
