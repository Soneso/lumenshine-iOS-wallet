//
//  TransactionsCoordinator.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 13/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class TransactionsCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        let viewModel = TransactionsViewModel(service: service.transactions, user: user)
        let viewController = TransactionsViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = viewController
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {

    }
}

fileprivate extension TransactionsCoordinator {
    
}
