//
//  HomeViewModel.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol HomeViewModelType: Transitionable {
    
}

class HomeViewModel : HomeViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    init() {
    }
    
}
