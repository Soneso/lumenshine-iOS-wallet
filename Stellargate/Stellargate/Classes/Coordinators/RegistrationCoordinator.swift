//
//  RegistrationCoordinator.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/23/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class RegistrationCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: AuthService) {
        let viewModel = RegistrationViewModel(service: service)
        self.baseController = RegistrationFormTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        
    }
}

fileprivate extension RegistrationCoordinator {
    
}


