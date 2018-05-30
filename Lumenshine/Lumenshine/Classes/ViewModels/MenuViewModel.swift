//
//  MenuViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UIImage

protocol MenuViewModelType: Transitionable {
    var items: [[String?]] { get }
    var icons: [[UIImage?]] { get }
    func menuItemSelected(at indexPath: IndexPath)
    
}

class MenuViewModel : MenuViewModelType {
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate var lastIndex = IndexPath(row: 0, section: 1)
    
    init(service: AuthService, user: User) {
        self.service = service
        self.user = user
        
        if let tokenExists = TFAGeneration.isTokenExists(email: user.email),
            tokenExists == false {
            service.tfaSecret(publicKeyIndex188: user.publicKeyIndex188) { result in
                switch result {
                case .success(let response):
                    TFAGeneration.createToken(tfaSecret: response.tfaSecret, email: user.email)
                case .failure(let error):
                    print("Tfa secret request error: \(error)")
                }
            }
        }
    }
    
    var items: [[String?]] = [
        [nil, "name@email.com"],
        ["Home", "Wallets", "Transactions", "Promotions"],
        ["Settings", "Help Center"]
    ]
    
    var icons: [[UIImage?]] = [
        [MaterialIcon.account.size48pt, nil],
        [MaterialIcon.home.size24pt, MaterialIcon.wallets.size24pt, MaterialIcon.transactions.size24pt, MaterialIcon.promotions.size24pt],
        [MaterialIcon.settings.size24pt, MaterialIcon.help.size24pt]
    ]
    
    var navigationCoordinator: CoordinatorType?
    
    func menuItemSelected(at indexPath:IndexPath) {
        if indexPath == lastIndex { return }
        switch indexPath.section {
        case 0:
            navigationCoordinator?.performTransition(transition: .showSettings)
        case 1:
            if indexPath.row == 0 {
                navigationCoordinator?.performTransition(transition: .showHome)
            }
        case 2:
            if indexPath.row == 0 {
                navigationCoordinator?.performTransition(transition: .showSettings)
            }
        default: break
        }
        lastIndex = indexPath
    }
}
