//
//  SettingsCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SettingsCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: AuthService, user: User) {
        let viewModel = SettingsViewModel(service: service, user: user)
        self.baseController = SettingsTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        
    }
}

fileprivate extension SettingsCoordinator {

}
