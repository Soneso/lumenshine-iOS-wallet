//
//  SettingsCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SettingsCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let viewModel: SettingsViewModel
    fileprivate var personalDataViewModel: PersonalDataViewModel?
    fileprivate let service: Services
    fileprivate let user: User
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        self.service = service
        self.user = user
        self.mainCoordinator = mainCoordinator
        self.viewModel = SettingsViewModel(services: service, user: user)
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
        case .showHome:
            showHome()
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
        case .showOccupationList:
            showOccupationList()
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
    
    func showHome() {
        let coordinator = HomeCoordinator(mainCoordinator: mainCoordinator, service: service, user: user)
        let navigationController = AppNavigationController(rootViewController: coordinator.baseController)
        if let drawer = baseController.drawerController {
            drawer.setViewController(navigationController, for: .none)
            drawer.closeSide()
            if let menu = drawer.getViewController(for: .left) as? MenuViewController {
                menu.present(coordinator.baseController)
            }
        }
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
        let viewModel = ReLoginViewModel(service: service.auth, user: user)
        let activateVC = ActivateFingerprintViewController(viewModel: viewModel)
        let composeVC = ComposeNavigationController(rootViewController: activateVC)
        baseController.navigationController?.present(composeVC, animated: true)
    }
    
    func showChartCurrency() {
        let currencyVC = ChartCurrencyViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    func showPersonalData() {
        let personalDataViewModel = PersonalDataViewModel(service: service.userData)
        let personalVC = PersonalDataViewController(viewModel: personalDataViewModel)
        let snackBarVC = SnackbarController(rootViewController: personalVC)
        baseController.navigationController?.pushViewController(snackBarVC, animated: true)
        self.personalDataViewModel = personalDataViewModel
        self.personalDataViewModel?.navigationCoordinator = self
    }
    
    func showOccupationList() {
        let occupationsVC = OccupationsViewController(viewModel: personalDataViewModel!)
        let composeVC = ComposeNavigationController(rootViewController: occupationsVC)
        baseController.navigationController?.present(composeVC, animated: true)
    }
}
