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
        super.init(mainCoordinator: mainCoordinator, service: service, user: user)
        let viewModel = HomeViewModel(service: service, user: user)
        let walletsView = WalletsViewController(viewModel: viewModel)
        
        super.mainCoordinator = mainCoordinator
        super.baseController = walletsView
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
}
