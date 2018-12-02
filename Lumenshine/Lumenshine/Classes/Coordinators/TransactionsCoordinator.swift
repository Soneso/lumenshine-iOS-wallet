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
    
    fileprivate let viewModel: TransactionsViewModel
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        self.viewModel = TransactionsViewModel(service: service, user: user)
        let viewController = TransactionsViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = viewController
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showTransactionFilter:
            showTransactionFilter()
        case .showTransactionSorter:
            showTransactionSorter()
        case .showPaymentsFilter:
            showPaymentsFilter()
        case .showOffersFilter:
            showOffersFilter()
        case .showOtherFilter:
            showOtherFilter()
        default:
            break
        }
    }
}

fileprivate extension TransactionsCoordinator {
    func showTransactionFilter() {
        let filterVC = TransactionsFilterViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    func showPaymentsFilter() {
        let filterVC = PaymentFilterViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    func showOffersFilter() {
        let filterVC = OfferFilterViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    func showOtherFilter() {
        let filterVC = OtherFilterViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(filterVC, animated: true)
    }
    
    func showTransactionSorter() {
        let sorterVC = TransactionsSortViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(sorterVC, animated: true)
    }
}
