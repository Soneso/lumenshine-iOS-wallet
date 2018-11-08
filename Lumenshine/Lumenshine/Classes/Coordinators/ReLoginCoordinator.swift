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
    
    fileprivate let services: Services
    
    init(mainCoordinator: MainCoordinator, services: Services, user: User) {
        let viewModel = ReLoginViewModel(services: services, user: user)
        self.services = services
        self.mainCoordinator = mainCoordinator
        self.baseController = ReLoginViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showDashboard(let user):
            self.showDashboard(user: user)
        case .logout(let transition):
            logout(transtion: transition)
        case .showRelogin:
            showRelogin()
        case .showFingerprint:
            showFingerprint()
        case .showSetup(let user, let mnemonic, let tfaConfirmed, let mailConfirmed, let mnemonicConfirmed, let tfaSecret):
            self.showSetup(user: user, mnemonic: mnemonic, tfaConfirmed: tfaConfirmed, mailConfirmed: mailConfirmed, mnemonicConfirmed: mnemonicConfirmed, tfaSecret: tfaSecret)
        default:
            break
        }
    }
}

fileprivate extension ReLoginCoordinator {    
    func showDashboard(user: User) {
        let coordinator = MenuCoordinator(mainCoordinator: mainCoordinator, user: user)
        present(coordinator: coordinator)
    }
    
    func logout(transtion: Transition?) {
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator, transition: transtion)
        present(coordinator: loginCoordinator)
    }
    
    func showSetup(user: User, mnemonic: String, tfaConfirmed: Bool, mailConfirmed: Bool, mnemonicConfirmed: Bool, tfaSecret: String?) {
        let coordinator = SetupMenuCoordinator(mainCoordinator: mainCoordinator, service: services.auth, user: user, mnemonic: mnemonic, tfaConfirmed: tfaConfirmed, mailConfirmed: mailConfirmed, mnemonicConfirmed: mnemonicConfirmed, tfaSecret:tfaSecret)
        present(coordinator: coordinator)
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
