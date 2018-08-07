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
    unowned var mainCoordinator: MainCoordinator
    
    init(mainCoordinator: MainCoordinator, service: AuthService, user: User) {
        let viewModel = ReLoginViewModel(service: service, user: user)
        self.mainCoordinator = mainCoordinator
        self.baseController = ReLoginViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .openDashboard:
            openDashboard()
        case .showDashboard(let user):
            self.showDashboard(user: user)
        case .logout(let transition):
            logout(transtion: transition)
        case .showRelogin:
            showRelogin()
        case .showFingerprint:
            showFingerprint()
        default:
            break
        }
    }
}

fileprivate extension ReLoginCoordinator {
    func openDashboard() {
        baseController.drawerController?.dismiss(animated: true, completion: nil)
    }
    
    func showDashboard(user: User) {
        let coordinator = MenuCoordinator(mainCoordinator: mainCoordinator, user: user)
        present(coordinator: coordinator)
    }
    
    func logout(transtion: Transition?) {
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator, transition: transtion)
        present(coordinator: loginCoordinator)
    }
    
    func showRelogin() {
        (baseController as! ReLoginViewController).showHome()
    }
    
    func showFingerprint() {
        (baseController as! ReLoginViewController).showFingerprint()
    }
    
    func present(coordinator: CoordinatorType) {
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window.rootViewController = coordinator.baseController
            }, completion: nil)
        }
    }
}
