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
    
    init(service: AuthService, email: String, mnemonic: String?) {
        self.service = service
        let viewModel = EmailConfirmationViewModel(service: service, email: email, mnemonic: mnemonic)
        self.baseController = EmailConfirmationViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showMnemonic(let mnemonic):
            showMnemonicQuiz(mnemonic)
        default: break
        }
    }
}

fileprivate extension EmailConfirmationCoordinator {
    func showMnemonicQuiz(_ mnemonic: String) {
        let mnemonicCoordinator = MnemonicCoordinator(service: service, mnemonic: mnemonic)
        baseController.navigationController?.pushViewController(mnemonicCoordinator.baseController, animated: true)
    }
}
