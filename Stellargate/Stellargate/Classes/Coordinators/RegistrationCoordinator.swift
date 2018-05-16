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
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
        let viewModel = RegistrationViewModel(service: service)
        self.baseController = RegistrationFormTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .show2FA(let email, let registrationResponse, let mnemonic):
            show2FA(email: email, response: registrationResponse, mnemonic: mnemonic)
        default: break
        }
    }
}

fileprivate extension RegistrationCoordinator {
    func show2FA(email: String, response: RegistrationResponse, mnemonic: String?) {
        let tfaCoordinator = TFARegistrationCoordinator(service: service, email: email, response: response, mnemonic: mnemonic)
        baseController.navigationController?.pushViewController(tfaCoordinator.baseController, animated: true)
    }
    
    func showGoogleAuthenticator(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


