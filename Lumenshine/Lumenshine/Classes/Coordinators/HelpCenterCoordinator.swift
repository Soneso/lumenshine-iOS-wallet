//
//  HelpCenterCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/26/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HelpCenterCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        let viewModel = HelpCenterViewModel(service: service.auth, user: user)
        let helpView = HelpCenterViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = helpView
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {

    }
}

fileprivate extension HelpCenterCoordinator {
    
}
