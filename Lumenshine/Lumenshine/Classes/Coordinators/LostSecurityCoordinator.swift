//
//  LostSecurityCoordinator.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LostSecurityCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let service: AuthService
    fileprivate let viewModel: LostSecurityViewModel
    
    init(mainCoordinator: MainCoordinator, service: AuthService, lostPassword: Bool) {
        self.service = service
        self.mainCoordinator = mainCoordinator
        self.viewModel = LostSecurityViewModel(service: service, lostPassword: lostPassword)
        
        self.baseController = LostSecurityViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showLostPasswordSuccess:
            showSuccess()
        case .showEmailConfirmation:
            showEmailConfirmation()
        case .showHeaderMenu(let items):
            showHeaderMenu(items: items)
        case .showLogin:
            self.showLogin()
        case .showSignUp:
            self.showSignUp()
        default: break
        }
    }
}

fileprivate extension LostSecurityCoordinator {
    func showSuccess() {
        (baseController as! LostSecurityViewController).showSuccess()
    }
    
    func showEmailConfirmation() {
        (baseController as! LostSecurityViewController).showEmailConfirmation()
    }
    
    func showHeaderMenu(items: [(String, String)]) {
        let headerVC = HeaderMenuViewController(items: items)
        headerVC.delegate = self.baseController as? LostSecurityViewController
        
        headerVC.modalPresentationStyle = .overCurrentContext
        
        self.baseController.present(headerVC, animated: true)
    }
    
    func showLogin() {
        mainCoordinator.currentMenuCoordinator?.performTransition(transition: .showLogin)
    }
    
    func showSignUp() {
        mainCoordinator.currentMenuCoordinator?.performTransition(transition: .showSignUp)
    }
}
