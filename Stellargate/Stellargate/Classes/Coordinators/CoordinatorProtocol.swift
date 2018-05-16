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
    case showDashboard(User)
    case showSignUp
    case showHome
    case showSettings
    case showHeaderMenu([String],[UIImage?])
    case showOnWeb(URL)
    case showScan
    case show2FA(String, RegistrationResponse, String?)
    case showGoogle2FA(URL)
    case showMnemonic(String)
}

