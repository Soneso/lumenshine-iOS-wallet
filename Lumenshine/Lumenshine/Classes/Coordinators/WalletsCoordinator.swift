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
    override init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        
        let viewModel = HomeViewModel(service: service, user: user, needsHeaderUpdate: false)
        let walletsView = WalletsViewController(viewModel: viewModel)
        
        super.init(mainCoordinator: mainCoordinator, viewModel:viewModel, viewController:walletsView)
    }
}
