//
//  HelpCenterViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol HelpCenterViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    func name(at indexPath: IndexPath) -> String?
    func detail(at indexPath: IndexPath) -> String?
    func iconName(at indexPath: IndexPath) -> String
    func headerTitle(at section: Int) -> String?
    
    func itemSelected(at indexPath: IndexPath)
}

class HelpCenterViewModel : HelpCenterViewModelType {
    
    fileprivate let service: AuthService
    fileprivate let user: User?
    fileprivate let entries: [[HelpEntry]]
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService, user: User?) {
        self.service = service
        self.user = user
        
        self.entries = [[.inbox],
                        [.FAQ1, .FAQ2, .FAQ3, .FAQ4],
                        [.basics, .wallets, .security, .stellar]]
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    func name(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).title
    }
    
    func iconName(at indexPath: IndexPath) -> String {
        return entry(at: indexPath).icon.name
    }
    
    func detail(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).detail
    }
    
    func headerTitle(at section: Int) -> String? {
        switch section {
        case 1:
            return R.string.localizable.faq()
        case 2:
            return R.string.localizable.topics()
        default:
            return nil
        }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        if indexPath.section != 0 {
            navigationCoordinator?.performTransition(transition: .showHelpForEntry(name(at: indexPath)))
        }
    }
}

fileprivate extension HelpCenterViewModel {
    func entry(at indexPath: IndexPath) -> HelpEntry {
        return entries[indexPath.section][indexPath.row]
    }
}
