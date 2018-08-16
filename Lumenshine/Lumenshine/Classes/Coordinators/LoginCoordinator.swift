//
//  LoginCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LoginCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: AuthService
    
    init(mainCoordinator: MainCoordinator, service: AuthService, transition: Transition? = .showLogin) {
        self.service = service
        self.mainCoordinator = mainCoordinator
        let viewModel = LoginViewModel(service: service)
        self.baseController = LoginViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
//        performTransition(transition: transition ?? .showLogin)
    }
    
    func performTransition(transition: Transition) {
        DispatchQueue.main.async {
            switch transition {
            case .showDashboard(let user):
                self.showDashboard(user: user)
            case .showLogin:
                self.showLogin()
            case .showSignUp:
                self.showSignUp()
            case .showHeaderMenu(let items):
                self.showHeaderMenu(items: items)
            case .showPasswordHint(let hint):
                self.showPasswordHint(hint)
            case .showSetup(let user, let mnemonic, let loginResponse):
                self.showSetup(user: user, mnemonic: mnemonic, loginResponse: loginResponse)
            default:
                break
            }
        }
    }
}

fileprivate extension LoginCoordinator {
    func showHeaderMenu(items: [(String, String)]) {
        let headerVC = HeaderMenuViewController(items: items)
        headerVC.delegate = self.baseController as? LoginViewController
        
        headerVC.modalPresentationStyle = .overCurrentContext
        
        self.baseController.present(headerVC, animated: true)
    }
    
    func showDashboard(user: User) {
        let coordinator = MenuCoordinator(mainCoordinator: mainCoordinator, user: user)
        present(coordinator: coordinator)
    }
    
    func showLogin() {
        (baseController as! LoginViewController).showLogin()
    }
    
    func showSignUp() {
        (baseController as! LoginViewController).showSignUp()
    }
    
    func showPasswordHint(_ hint: String) {
        let title = R.string.localizable.password_hint_title()
        let textVC = InfoViewController(info: hint, title: title)
        baseController.present(AppNavigationController(rootViewController: textVC), animated: true)
    }
    
    func showSetup(user: User, mnemonic: String, loginResponse: LoginStep2Response) {
        let coordinator = SetupMenuCoordinator(mainCoordinator: mainCoordinator, service: service, user: user, mnemonic: mnemonic, loginResponse: loginResponse)
        present(coordinator: coordinator)
    }
    
    func present(coordinator: CoordinatorType) {
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window.rootViewController = coordinator.baseController
            }, completion: nil)
        }
    }
}

