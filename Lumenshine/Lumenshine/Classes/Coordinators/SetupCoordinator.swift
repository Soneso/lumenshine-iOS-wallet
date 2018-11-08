//
//  SetupCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import KWDrawerController

class SetupCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: AuthService
    fileprivate let viewModel: SetupViewModel
    fileprivate let user: User
    
    init(mainCoordinator: MainCoordinator, service: AuthService, user: User, mnemonic: String, tfaConfirmed: Bool, mailConfirmed: Bool, mnemonicConfirmed: Bool, tfaSecret:String?) {
        self.service = service
        self.user = user
        self.mainCoordinator = mainCoordinator
        self.viewModel = SetupViewModel(service: service, user: user, mnemonic: mnemonic, tfaConfirmed: tfaConfirmed, mailConfirmed: mailConfirmed, mnemonicConfirmed: mnemonicConfirmed, tfaSecret:tfaSecret)
        if let setup = SetupViewController.initialize(viewModel: viewModel) {
            self.baseController = SnackbarController(rootViewController: setup)
            viewModel.navigationCoordinator = self
        } else {
            self.baseController = SetupViewController(viewModel: viewModel)
            showDashboard()
        }
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .nextSetupStep:
            nextSetupStep()
        case .showMnemonicVerification:
            showMnemonicVerification()
        case .showRelogin:
            showRelogin()
        default: break
        }
    }
}

fileprivate extension SetupCoordinator {
    func nextSetupStep() {
        if let setup = SetupViewController.initialize(viewModel: viewModel) {
            let baseVC = SnackbarController(rootViewController: setup)
            present(viewController: baseVC)
        } else {
            showDashboard()
        }
    }
    
    func showMnemonicVerification() {
        let setup = VerificationSetupViewController(viewModel: viewModel)
        let baseVC = SnackbarController(rootViewController: setup)
        present(viewController: baseVC)
    }
    
    func showDashboard() {
        let coordinator = MenuCoordinator(mainCoordinator: mainCoordinator, user: user)
        present(coordinator: coordinator)
    }
    
    func showRelogin() {
        let coordinator = ReLoginMenuCoordinator(mainCoordinator: mainCoordinator, user: user)
        present(coordinator: coordinator)
    }
    
    func present(viewController: UIViewController) {
        if let menu = baseController.drawerController?.getViewController(for: .left) as? MenuViewController {
            menu.present(viewController)
        }
        baseController.navigationController?.setViewControllers([viewController], animated: true)
        baseController = viewController
    }
    
    func present(coordinator: CoordinatorType) {
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = coordinator.baseController
            }, completion: nil)
        }
    }
}

