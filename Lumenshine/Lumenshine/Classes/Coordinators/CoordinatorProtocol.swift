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

public indirect enum Transition {
    case showDashboard(User)
    case openDashboard(Transition?)
    case showLogin
    case showRelogin
    case showFingerprint
    case showSignUp
    case showForgotPassword
    case showLost2fa
    case showHome
    case showSettings
    case showHeaderMenu([(String, String)])
    case showOnWeb(URL)
    case showScan
    case showWalletCardInfo
    case logout(Transition?)
    case showPasswordHint(String)
    case showSetup(User, LoginStep2Response)
    case nextSetupStep
    case showMnemonicVerification
    case showChangePassword
}

