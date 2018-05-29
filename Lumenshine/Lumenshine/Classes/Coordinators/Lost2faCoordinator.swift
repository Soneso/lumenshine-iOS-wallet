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
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
        let viewModel = Lost2faViewModel(service: service)
        
        let viewController = Lost2faViewController(nibName: "Lost2faViewController", bundle: Bundle.main)
        viewController.viewModel = viewModel
        self.baseController = viewController
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        default: break
        }
    }
}
