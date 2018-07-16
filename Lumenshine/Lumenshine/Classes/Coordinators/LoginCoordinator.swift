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
    
    fileprivate let service: AuthService
    
    init(service: AuthService, transition: Transition? = .showLogin) {
        self.service = service
        let viewModel = LoginViewModel(service: service)
        self.baseController = LoginViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        performTransition(transition: transition ?? .showLogin)
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showDashboard(let user):
            showDashboard(user: user)
        case .showLogin:
            showLogin()
        case .showSignUp:
            showSignUp()
        case .show2FA(let user, let registrationResponse):
            show2FA(user: user, response: registrationResponse)
        case .showMnemonic(let user):
            showMnemonicQuiz(user: user)
        case .showEmailConfirmation(let user):
            showEmailConfirmation(user: user)
        case .showHeaderMenu(let items):
            showHeaderMenu(items: items)
        case .showPasswordHint(let hint):
            showPasswordHint(hint)
        default:
            break
        }
    }
}

fileprivate extension LoginCoordinator {
    func showHeaderMenu(items: [(String, String)]) {
        let headerVC = HeaderMenuViewController(items: items)
        headerVC.delegate = self.baseController as! LoginViewController
        
        headerVC.modalPresentationStyle = .overCurrentContext
        
        self.baseController.present(headerVC, animated: true)
    }
    
    func showDashboard(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window.rootViewController = menuCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showLogin() {
        (baseController as! LoginViewController).showLogin()
    }
    
    func showSignUp() {
        (baseController as! LoginViewController).showSignUp()
    }
    
    func show2FA(user: User, response: RegistrationResponse) {
        let tfaCoordinator = TFARegistrationCoordinator(service: service, user: user, response: response)
        baseController.navigationController?.pushViewController(tfaCoordinator.baseController, animated: true)
    }
    
    func showMnemonicQuiz(user: User) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service, user: user)
        baseController.navigationController?.pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
    
    func showEmailConfirmation(user: User) {
        let emailCoordinator = EmailConfirmationCoordinator(service: service, user: user)
        baseController.navigationController?.pushViewController(emailCoordinator.baseController, animated: true)
    }
    
    func showPasswordHint(_ hint: String) {
        let textVC = TextViewController(text: hint)
        baseController.present(AppNavigationController(rootViewController: textVC), animated: true)
    }
}

