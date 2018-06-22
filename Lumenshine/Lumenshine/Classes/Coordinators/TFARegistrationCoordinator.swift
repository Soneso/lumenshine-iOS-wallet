//
//  TFARegistrationCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/29/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class TFARegistrationCoordinator: CoordinatorType {
    var baseController: UIViewController
    fileprivate let service: AuthService
    fileprivate let user: User
    
    init(service: AuthService, user: User, response: RegistrationResponse) {
        self.service = service
        self.user = user
        let viewModel = TFARegistrationViewModel(service: service, user: user, response: response)
        self.baseController = TFARegistrationViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showGoogle2FA(let url):
            showGoogleAuthenticator(url: url)
        case .showMnemonic(let user):
            showMnemonicQuiz(user: user)
        case .showEmailConfirmation(let user):
            showEmailConfirmation(user: user)
        case .showDashboard(let user):
            showDashboard(user: user)
        default: break
        }
    }
}

fileprivate extension TFARegistrationCoordinator {
    func showGoogleAuthenticator(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let urlString = "https://itunes.apple.com/app/google-authenticator/id388497605"
            if let url = URL(string: urlString),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func showMnemonicQuiz(user: User) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service, user: user)
        baseController.navigationController?.pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
    
    func showEmailConfirmation(user: User) {
        let emailCoordinator = EmailConfirmationCoordinator(service: service, user: user)
        baseController.navigationController?.pushViewController(emailCoordinator.baseController, animated: true)
    }
    
    func showDashboard(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window.rootViewController = menuCoordinator.baseController
            }, completion: nil)
        }
    }
}

