//
//  HomeCoordinator.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk
import MessageUI

class HomeCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        let viewModel = HomeViewModel(service: service, user: user, needsHeaderUpdate: true)
        let homeView = HomeViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = homeView
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    init(mainCoordinator: MainCoordinator, viewModel:HomeViewModel, viewController:UIViewController) {
        
        self.mainCoordinator = mainCoordinator
        self.baseController = viewController
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHeaderMenu(let items):
            showHeaderMenu(items: items)
        case .showOnWeb(let url):
            showOnWeb(url: url)
        case .showFundWallet(let wallet):
            showFundWallet(forWallet: wallet)
        case .showCardDetails(let wallet):
            showCardDetails(wallet: wallet)
        case .showHelp:
            showHelpCenter()
        case .showFeedback:
            showFeedback()
        default: break
        }
    }
}

fileprivate extension HomeCoordinator {
    func showHeaderMenu(items: [(String, String?)]) {
        let headerVC = HeaderMenuViewController(items: items)
        headerVC.delegate = self.baseController as! HomeViewController
        self.baseController.present(headerVC, animated: true)
    }
    
    func showOnWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showFundWallet(forWallet wallet: Wallet) {
        if Services.shared.usePublicStellarNetwork {
            let paymentOperationsVCManager = PaymentOperationsVCManager(parentViewController: self.baseController)
                paymentOperationsVCManager.addViewController(forAction: .deposit, wallets: [wallet])
        } else {
            let fundWalletViewController = FundTestNetWalletViewController(nibName: "FundTestNetWalletViewController", bundle: Bundle.main, forWallet: wallet)
            let composeVC = ComposeNavigationController(rootViewController: fundWalletViewController)
            self.baseController.present(composeVC, animated: true)
        }
    }
    
    func showCardDetails(wallet: Wallet) {
        let accountDetailsViewController = AccountDetailsViewController(nibName: "AccountDetailsViewController", bundle: Bundle.main)
        accountDetailsViewController.flowDelegate = self
        accountDetailsViewController.wallet = wallet
        self.baseController.navigationController?.pushViewController(accountDetailsViewController, animated: true)
    }
    
    func showHelpCenter() {
        let coordinator = HelpCenterCoordinator(mainCoordinator: mainCoordinator, service: Services())
        self.baseController.navigationController?.pushViewController(coordinator.baseController, animated: true)
    }
    
    func showFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self.baseController as! HomeViewController;
            mail.setSubject("Lumenshine Feedback")
            mail.setToRecipients([Services.shared.supportEmailAddress])
            baseController.present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Email not set up!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            baseController.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeCoordinator: AccountDetailsViewControllerFlow {

    func backButtonPressed(from viewController:UIViewController) {
        viewController.navigationController?.dismiss(animated: true)
    }
    
    func closeButtonPressed(from viewController:UIViewController) {
        
    }
    
}

