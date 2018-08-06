//
//  Lost2faCoordinator.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 29/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class Lost2faCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: AuthService
    
    init(mainCoordinator: MainCoordinator, service: AuthService) {
        self.service = service
        self.mainCoordinator = mainCoordinator
        let viewModel = Lost2faViewModel(service: service)
        
        let viewController = Lost2faViewController(nibName: "Lost2faViewController", bundle: Bundle.main)
        viewController.viewModel = viewModel
        self.baseController = viewController
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        default: break
        }
    }
}
