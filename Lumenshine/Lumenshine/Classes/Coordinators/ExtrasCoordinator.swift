//
//  ExtrasCoordinator.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 23/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ExtrasCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let viewModel: ExtrasViewModel
    fileprivate let user: User
    
    init(mainCoordinator: MainCoordinator, user: User) {
        self.user = user
        self.mainCoordinator = mainCoordinator
        self.viewModel = ExtrasViewModel(user: user)
        self.baseController = ExtrasTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showMergeExternalAccount:
            showMergeExternalAccount()
        case .showMergeWallet:
            showMergeWallet()
        case .showExtras:
            showExtras()
        default: break
        }
    }
}

fileprivate extension ExtrasCoordinator {

    
    func showExtras() {
        baseController.navigationController?.popToRootViewController(animated: true)
    }
    
    func showMergeExternalAccount() {
        let mergeVC = MergeExternalAccountViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(mergeVC, animated: true)
    }
    
    func showMergeWallet() {
        let mergeVC = MergeWalletViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(mergeVC, animated: true)
    }
    
}
