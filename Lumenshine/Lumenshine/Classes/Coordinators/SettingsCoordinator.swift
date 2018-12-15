//
//  SettingsCoordinator.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SettingsCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let viewModel: SettingsViewModel
    fileprivate var personalDataViewModel: PersonalDataViewModel?
    fileprivate let user: User
    
    init(mainCoordinator: MainCoordinator, user: User) {
        self.user = user
        self.mainCoordinator = mainCoordinator
        self.viewModel = SettingsViewModel(user: user)
        self.baseController = SettingsTableViewController(viewModel: viewModel)
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .logout:
            logout()
        case .showChangePassword:
            showChangePassword()
        case .showPasswordHint(let hint, let attributedText):
            showPasswordHint(hint, attributedText: attributedText)
        case .showSuccess:
            showSuccess()
        case .showSettings:
            showSettings()
        case .showChange2faSecret:
            showChange2faSecret()
        case .showNew2faSecret:
            showNew2faSecret()
        case .showBackupMnemonic:
            showBackupMnemonic()
        case .showMnemonic(let mnemonic):
            showMnemonic(mnemonic)
        case .showFingerprint:
            showActivateFingerprint()
        case .showChartCurrency:
            showChartCurrency()
        case .showPersonalData:
            showPersonalData()
        case .showPersonalDataSubList:
            showPersonalDataSubList()
        default: break
        }
    }
}

fileprivate extension SettingsCoordinator {
    func logout() {
        let loginCoordinator = LoginMenuCoordinator(mainCoordinator: mainCoordinator)
        if let window = UIApplication.shared.delegate?.window ?? baseController.view.window {        
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginCoordinator.baseController
            }, completion: nil)
        }
    }
    
    func showChangePassword() {
        let changeVC = ChangePasswordViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(changeVC, animated: true)
    }
    
    func showChange2faSecret() {
        let changeVC = Change2faSecretViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(changeVC, animated: true)
    }
    
    func showNew2faSecret() {
        let tfaSecretVC = Confirm2faCodeViewController(viewModel: viewModel)
        let snackBarVC = SnackbarController(rootViewController: tfaSecretVC)
        baseController.navigationController?.pushViewController(snackBarVC, animated: true)
    }
    
    func showPasswordHint(_ hint: String, attributedText: NSAttributedString?) {
        let title = R.string.localizable.password_hint_title()
        let textVC = InfoViewController(info: hint, attributedText: attributedText, title: title)
        let composeVC = ComposeNavigationController(rootViewController: textVC)
        baseController.navigationController?.present(composeVC, animated: true)
    }
    
    func showSuccess() {
        let changeVC = ChangePasswordSuccessViewController(viewModel: viewModel)
        baseController.navigationController?.popToRootViewController(animated: false)
        baseController.navigationController?.pushViewController(changeVC, animated: true)
    }
    
    func showSettings() {
        baseController.navigationController?.popToRootViewController(animated: true)
    }
    
    func showBackupMnemonic() {
        let backupVC = RevealMnemonicViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(backupVC, animated: true)
    }
    
    func showMnemonic(_ mnemonic: String) {
        let backupVC = BackupMnemonicViewController(mnemonic: mnemonic)
        baseController.navigationController?.popViewController(animated: false)
        baseController.navigationController?.pushViewController(backupVC, animated: true)
    }
    
    func showActivateFingerprint() {
        let viewModel = ReLoginViewModel(user: user)
        let activateVC = ActivateFingerprintViewController(viewModel: viewModel)
        let composeVC = ComposeNavigationController(rootViewController: activateVC)
        baseController.navigationController?.present(composeVC, animated: true)
    }
    
    func showChartCurrency() {
        let currencyVC = ChartCurrencyViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    func showPersonalData() {
        let personalDataViewModel = PersonalDataViewModel()
        let personalVC = PersonalDataViewController(viewModel: personalDataViewModel)
        baseController.navigationController?.pushViewController(personalVC, animated: true)
        self.personalDataViewModel = personalDataViewModel
        self.personalDataViewModel?.navigationCoordinator = self
    }
    
    func showPersonalDataSubList() {
        let occupationsVC = ListViewController(viewModel: personalDataViewModel!)
        let composeVC = ComposeNavigationController(rootViewController: occupationsVC)
        baseController.navigationController?.present(composeVC, animated: true)
    }
}
