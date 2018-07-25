//
//  SettingsViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol SettingsViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    func name(at indexPath: IndexPath) -> String
    func switchValue(at indexPath: IndexPath) -> Bool?
    func switchChanged(value: Bool, at indexPath: IndexPath)
    func itemSelected(at indexPath: IndexPath)
}


class SettingsViewModel: SettingsViewModelType {
    var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let entries: [[SettingsEntry]]
    fileprivate var touchEnabled: Bool
    fileprivate var lastIndex = IndexPath(row: 0, section: 1)
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        self.entries = [[.changePassword, .change2FA, .biometricAuth, .avatar]]
        
        if let touchEnabled = UserDefaults.standard.value(forKey: "touchEnabled") as? Bool {
            self.touchEnabled = touchEnabled
        } else {
            self.touchEnabled = false
        }
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    func name(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).name
    }
    
    func switchValue(at indexPath: IndexPath) -> Bool? {
        if entry(at: indexPath) == .biometricAuth {
            return touchEnabled
        }
        return nil
    }
    
    func switchChanged(value: Bool, at indexPath: IndexPath) {
        switch entry(at: indexPath) {
        case .biometricAuth:
            touchEnable(value: value)
        default: break
        }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        if indexPath == lastIndex { return }
        switch entry(at: indexPath) {
        case .changePassword:
            break
        case .change2FA:
            break
        case .biometricAuth:
            break
        case .avatar:
            break
        }
        lastIndex = indexPath
    }
}

fileprivate extension SettingsViewModel {
    func touchEnable(value: Bool) {
        touchEnabled = value
        UserDefaults.standard.setValue(touchEnabled, forKey: "touchEnabled")
    }
    
    func entry(at indexPath: IndexPath) -> SettingsEntry {
        return entries[indexPath.section][indexPath.row]
    }
}
