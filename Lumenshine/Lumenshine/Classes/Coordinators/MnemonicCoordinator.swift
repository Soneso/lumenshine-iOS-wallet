//
//  MnemonicCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/7/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MnemonicCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: AuthService, user: User) {
        let viewModel = MnemonicViewModel(service: service, user: user)
        self.baseController = MnemonicViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showDashboard(let user):
            showDashboard(user: user)
        default: break
        }
    }
}

fileprivate extension MnemonicCoordinator {    
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
