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
    
    fileprivate let service: Services
    
    init() {
        self.service = Services()
        let viewModel = LoginViewModel(service: service.auth)
        let navigation = AppNavigationController(rootViewController: LoginViewController(viewModel: viewModel))
        self.baseController = navigation
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showDashboard(let user):
            showDashboard(user: user)
        case .showSignUp:
            showSignUp()
        case .show2FA(let email, let registrationResponse, let mnemonic):
            show2FA(email: email, response: registrationResponse, mnemonic: mnemonic)
        case .showMnemonic(let mnemonic):
            showMnemonicQuiz(mnemonic)
        case .showEmailConfirmation(let email, let mnemonic):
            showEmailConfirmation(email, mnemonic: mnemonic)
        default:
            break
        }
    }
}

fileprivate extension LoginCoordinator {
    func showDashboard(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let mainNavigation = menuCoordinator.baseController.evo_drawerController,
            let navigation = baseController as? AppNavigationController {
            navigation.popToRootViewController(animated: false)
            navigation.setNavigationBarHidden(true, animated: false)
            navigation.pushViewController(mainNavigation, animated: true)
        }
//        if let window = self.baseController.view.window {
//            window.rootViewController = mainNavigation
//        } else {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = mainNavigation
//        }
//
//        self.baseController.dismiss(animated: true)
    }
    
    func showSignUp() {
        let registrationCoordinator = RegistrationCoordinator(service: service.auth)
        (baseController as! AppNavigationController).pushViewController(registrationCoordinator.baseController, animated: true)
    }
    
    func show2FA(email: String, response: RegistrationResponse, mnemonic: String?) {
        let tfaCoordinator = TFARegistrationCoordinator(service: service.auth, email: email, response: response, mnemonic: mnemonic)
        (baseController as! AppNavigationController).pushViewController(tfaCoordinator.baseController, animated: true)
    }
    
    func showMnemonicQuiz(_ mnemonic: String) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service.auth, mnemonic: mnemonic)
        (baseController as! AppNavigationController).pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
    
    func showEmailConfirmation(_ email: String, mnemonic: String?) {
        let emailCoordinator = EmailConfirmationCoordinator(service: service.auth, email: email, mnemonic: mnemonic)
        (baseController as! AppNavigationController).pushViewController(emailCoordinator.baseController, animated: true)
    }
}

