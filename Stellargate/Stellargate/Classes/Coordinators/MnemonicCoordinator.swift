//
//  MnemonicCoordinator.swift
//  Stellargate
//
//  Created by Istvan Elekes on 5/7/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class MnemonicCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: AuthService, mnemonic: String) {
        let viewModel = MnemonicViewModel(service: service, mnemonic: mnemonic)
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
        
        if let mainNavigation = menuCoordinator.baseController.evo_drawerController,
            let navigation = baseController as? AppNavigationController {
            navigation.popToRootViewController(animated: false)
            navigation.pushViewController(mainNavigation, animated: true)
        }
    }
}
