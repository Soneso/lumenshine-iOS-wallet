//
//  HomeCoordinator.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

class HomeCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        let viewModel = HomeViewModel(service: service, user: user)
        let homeView = HomeViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = homeView
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHeaderMenu(let items):
            showHeaderMenu(items: items)
        case .showOnWeb(let url):
            showOnWeb(url: url)
        case .showScan(let wallet):
            showScan(forWallet: wallet)
        case .showCardDetails(let wallet):
            showCardDetails(wallet: wallet)
        case .showWalletCardInfo:
            showWalletCardInfo()
        default: break
        }
    }
}

fileprivate extension HomeCoordinator {
    func showHeaderMenu(items: [(String, String)]) {
        let headerVC = HeaderMenuViewController(items: items)
        headerVC.delegate = self.baseController as! HomeViewController
        self.baseController.present(headerVC, animated: true)
    }
    
    func showOnWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showScan(forWallet wallet: Wallet) {
        var fundWalletViewController: UIViewController
        
        if Services.shared.isTestURL {
            fundWalletViewController = FundTestNetWalletViewController(nibName: "FundTestNetWalletViewController", bundle: Bundle.main, forWallet: wallet)
        } else {
            fundWalletViewController = FundWalletViewController(nibName: "FundWalletViewController", bundle: Bundle.main, forWallet: wallet)
        }
    
        self.baseController.present(fundWalletViewController, animated: true)
    }
    
    func showCardDetails(wallet: Wallet) {
        let foundViewController = AccountDetailsViewController(nibName: "AccountDetailsViewController", bundle: Bundle.main)
        foundViewController.flowDelegate = self
        foundViewController.wallet = wallet
        let navigationController = BaseNavigationViewController(rootViewController: foundViewController)
        self.baseController.present(navigationController, animated: true)
    }
    
    func showWalletCardInfo() {
        let infoViewController = WalletCardInfoViewController(nibName: "WalletCardInfoViewController", bundle: Bundle.main)
        self.baseController.present(infoViewController, animated: true)
    }
}

extension HomeCoordinator: AccountDetailsViewControllerFlow {

    func backButtonPressed(from viewController:UIViewController) {
        viewController.navigationController?.dismiss(animated: true)
    }
    
    func closeButtonPressed(from viewController:UIViewController) {
        
    }
    
}

