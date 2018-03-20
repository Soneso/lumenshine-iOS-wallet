//
//  CoordinatorProtocol.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol Transitionable: class {
    var navigationCoordinator: CoordinatorType? { get }
}

protocol CoordinatorType: class {
    
    var baseController: UIViewController { get }
    
    func performTransition(transition: Transition)
}

public enum Transition {
    case showHome
    case showHeaderMenu([String],[UIImage?])
    case showOnWeb(URL)
}

