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
    
    var mainCoordinator: MainCoordinator { get }
    
    func performTransition(transition: Transition)
}

protocol MenuCoordinatorType: CoordinatorType {
}

public indirect enum Transition {
    case showDashboard(User)
    case showLogin
    case showRelogin
    case showFingerprint
    case showSignUp
    case showForgotPassword
    case showSuccess
    case showEmailConfirmation
    case showLost2fa
    case showHome
    case showSettings
    case showHelp
    case showContacts
    case showAddUpdateContact(ContactResponse?)
    case showHeaderMenu([(String, String)])
    case showOnWeb(URL)
    case showCardDetails(Wallet)
    case showScan(Wallet)
    case showWalletCardInfo
    case logout(Transition?)
    case showPasswordHint(String, NSAttributedString?)
    case showSetup(User, String, LoginStep2Response)
    case nextSetupStep
    case showMnemonicVerification
    case showChangePassword
    case showChange2faSecret
    case showNew2faSecret
    case showBackupMnemonic
    case showMnemonic(String)
    case showChartCurrency
    case showPersonalData
    case showPersonalDataSubList
    case showWallets
}

