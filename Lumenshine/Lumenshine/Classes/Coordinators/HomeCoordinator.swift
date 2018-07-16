//
//  HomeCoordinator.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HomeCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: HomeService, user: User) {
        let viewModel = HomeViewModel(service: service, user: user)
        let homeView = HomeViewController(viewModel: viewModel)
        
        self.baseController = homeView
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHeaderMenu(let items):
            showHeaderMenu(items: items)
        case .showOnWeb(let url):
            showOnWeb(url: url)
        case .showScan:
            showScan()
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
        
        headerVC.modalPresentationStyle = .overCurrentContext
        
        self.baseController.present(headerVC, animated: true)
    }
    
    func showOnWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showScan() {
        let foundViewController = FoundAccountViewController(nibName: "FoundAccountViewController", bundle: Bundle.main)
        self.baseController.present(foundViewController, animated: true)
    }
    
    func showWalletCardInfo() {
        let infoViewController = WalletCardInfoViewController(nibName: "WalletCardInfoViewController", bundle: Bundle.main)
        self.baseController.present(infoViewController, animated: true)
    }
}

