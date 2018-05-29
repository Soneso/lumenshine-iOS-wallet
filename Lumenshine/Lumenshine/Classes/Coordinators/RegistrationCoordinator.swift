//
//  RegistrationCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/23/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class RegistrationCoordinator: CoordinatorType {
    var baseController: UIViewController
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
        let viewModel = RegistrationViewModel(service: service)
        self.baseController = RegistrationFormTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .show2FA(let user, let registrationResponse):
            show2FA(user: user, response: registrationResponse)
        default: break
        }
    }
}

fileprivate extension RegistrationCoordinator {
    func show2FA(user: User, response: RegistrationResponse) {
        let tfaCoordinator = TFARegistrationCoordinator(service: service, user: user, response: response)
        baseController.navigationController?.pushViewController(tfaCoordinator.baseController, animated: true)
    }
    
    func showGoogleAuthenticator(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


