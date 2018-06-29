//
//  SettingsViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol SettingsViewModelType: Transitionable {
    var items: [[String?]] { get }
    func detailText(forCell indexPath: IndexPath) -> String?
    func didSelect(cellAt indexPath: IndexPath)
}


class SettingsViewModel: SettingsViewModelType {
    var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate var touchEnabled: Bool
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool {
            self.touchEnabled = touchEnabled
        } else {
            self.touchEnabled = false
        }
    }
    
    var items: [[String?]] = [
        [R.string.localizable.touch_id(),
         R.string.localizable.logout()]
    ]
    
    
    func detailText(forCell indexPath: IndexPath) -> String? {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return touchEnabled ? R.string.localizable.enabled() : R.string.localizable.disabled()
            default: break
            }
        default: break
        }
        return nil
    }
    
    func didSelect(cellAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: touchEnable()
            case 1: logout()
            default: break
            }
        default: break
        }
    }
}

fileprivate extension SettingsViewModel {
    func touchEnable() {
        touchEnabled = !touchEnabled
        UserDefaults.standard.setValue(touchEnabled, forKey: "touchEnabled")
    }
    
    func logout() {
        TFAGeneration.removeToken(email: user.email)
        BaseService.removeToken()
        navigationCoordinator?.performTransition(transition: .logout(nil))
    }
}
