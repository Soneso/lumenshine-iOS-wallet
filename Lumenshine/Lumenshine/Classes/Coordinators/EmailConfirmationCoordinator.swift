//
//  EmailConfirmationCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class EmailConfirmationCoordinator: CoordinatorType {
    var baseController: UIViewController
    fileprivate let service: AuthService
    
    init(service: AuthService, user: User) {
        self.service = service
        let viewModel = EmailConfirmationViewModel(service: service, user: user)
        self.baseController = EmailConfirmationViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showMnemonic(let user):
            showMnemonicQuiz(user: user)
        case .showDashboard(let user):
            showDashboard(user: user)
        default: break
        }
    }
}

fileprivate extension EmailConfirmationCoordinator {
    func showMnemonicQuiz(user: User) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service, user: user)
        baseController.navigationController?.pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
    
    func showDashboard(user: User) {
        let menuCoordinator = MenuCoordinator(user: user)
        
        if let mainNavigation = menuCoordinator.baseController.evo_drawerController {
            let window = UIApplication.shared.delegate?.window ?? baseController.view.window
            
            UIView.transition(with: window!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                window!.rootViewController = mainNavigation
            }, completion: nil)
        }
    }
}
