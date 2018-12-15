//
//  HelpCenterCoordinator.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HelpCenterCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    init(mainCoordinator: MainCoordinator) {
        let viewModel = HelpCenterViewModel()
        let helpView = HelpCenterViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = helpView
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHelpForEntry(let title):
            showHelpForEntry(title:title)
        default: break
        }
    }
    
    
}

fileprivate extension HelpCenterCoordinator {
    func showHelpForEntry(title: String?) {
        if let modalTitle = title {
            let helpDetailsVC = HelpDetailsViewController()
            helpDetailsVC.modalTitle = modalTitle
            
            switch modalTitle {
            case R.string.localizable.faq_1():
                helpDetailsVC.infoText = R.string.localizable.faq_1_info()
                helpDetailsVC.linksDict = [R.string.localizable.faq_1_market_link_key() : R.string.localizable.faq_1_market_link().components(separatedBy: ","), R.string.localizable.faq_1_changelly_link_key() : R.string.localizable.faq_1_changelly_link().components(separatedBy: ",")]
                break
            case R.string.localizable.faq_2():
                helpDetailsVC.infoText = R.string.localizable.faq_2_info()
                break
            case R.string.localizable.faq_3():
                helpDetailsVC.infoText = R.string.localizable.faq_3_info()
                break
            case R.string.localizable.faq_4():
                helpDetailsVC.infoText = R.string.localizable.faq_4_info()
                break
            case R.string.localizable.basics():
                helpDetailsVC.infoText = R.string.localizable.basics_info()
                helpDetailsVC.linksDict = [R.string.localizable.basics_info_video_link_key() : R.string.localizable.basics_info_video_link().components(separatedBy: ",")]
                break
            case R.string.localizable.wallets():
                helpDetailsVC.infoText = R.string.localizable.wallets_info()
                helpDetailsVC.linksDict = [R.string.localizable.wallets_info_pool_link_key() : R.string.localizable.wallets_info_pool_link().components(separatedBy: ",")]
                helpDetailsVC.chapters = R.string.localizable.wallets_info_chapters().components(separatedBy: ",")
                helpDetailsVC.bolds = R.string.localizable.wallets_info_bolds().components(separatedBy: ",")
                break
            case R.string.localizable.security():
                helpDetailsVC.infoText = R.string.localizable.security_info()
                helpDetailsVC.chapters = R.string.localizable.security_info_chapters().components(separatedBy: ",")
                break
            case R.string.localizable.stellar():
                helpDetailsVC.infoText = R.string.localizable.stellar_info()
                helpDetailsVC.chapters = R.string.localizable.stellar_info_chapters().components(separatedBy: ",")
                helpDetailsVC.linksDict = [R.string.localizable.stellar_sdf_link_key() : R.string.localizable.stellar_sdf_link().components(separatedBy: ","), R.string.localizable.stellar_videos_link_key() : R.string.localizable.stellar_videos_links().components(separatedBy: ","),
                ]
                
            default:
                break
            }
             
            let composeVC = ComposeNavigationController(rootViewController: helpDetailsVC)
            baseController.present(composeVC, animated: true)
        }
    }
}
