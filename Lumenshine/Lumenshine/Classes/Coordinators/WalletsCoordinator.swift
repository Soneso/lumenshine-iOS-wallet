//
//  WalletsCoordinator.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class WalletsCoordinator: HomeCoordinator {
    
    
    override init(mainCoordinator: MainCoordinator) {
        
        let viewModel = HomeViewModel(needsHeaderUpdate: false)
        let walletsView = WalletsViewController(viewModel: viewModel)
        
        super.init(mainCoordinator: mainCoordinator, viewModel:viewModel, viewController:walletsView)
    }
    
    deinit {
        print("Deinit WalletsCoordinator")
        // HELP NEEDED
        // this is a hack - pls see deinit of superclass HomeCoordinator
        // after fixing, pls. remove this.
        if let walletsViewController = self.baseController as? WalletsViewController {
            walletsViewController.cleanup()
        }
    }
}
