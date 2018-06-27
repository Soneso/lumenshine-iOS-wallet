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
    case openDashboard
    case showLogin
    case showRelogin
    case showSignUp
    case showForgotPassword
    case showLost2fa
    case showHome
    case showSettings
    case showHeaderMenu([(String, String)])
    case showOnWeb(URL)
    case showScan
    case show2FA(User, RegistrationResponse)
    case showGoogle2FA(URL)
    case showMnemonic(User)
    case showEmailConfirmation(User)
    case logout
}

