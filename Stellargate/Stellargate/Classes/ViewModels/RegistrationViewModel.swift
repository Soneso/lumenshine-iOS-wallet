//
//  RegistrationViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol RegistrationViewModelType: Transitionable {
    var items: [[String]] { get }
    var values: [[String?]] { get }
    var sectionTitles: [String] { get }
    func textIsSecure(at indexPath: IndexPath) -> Bool
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath)
    func submit(response: @escaping GenerateAccountResponseClosure)
    func show2FA(response: RegistrationResponse)
}

class RegistrationViewModel : RegistrationViewModelType {
    
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
        values = items.map { value in
            return Array<String?>(repeating: nil, count: value.count)
        }
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var values: [[String?]]
    var items: [[String]] = [
        ["Email", "Password"],
        ["Forename", "Last name", "Company name", "Salutation", "Title",
         "Street address", "Street number", "Zip code", "City", "State",
         "Country", "Nationality", "Mobile phone", "Birth day", "Birth place"]
    ]
    
    var sectionTitles: [String] = [
        R.string.localizable.account_data_title(),
        R.string.localizable.user_data_title()
    ]
    
    func textIsSecure(at indexPath: IndexPath) -> Bool {
        if indexPath.section == 0, indexPath.row == 1 {
            return true
        }
        return false
    }
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath) {
        values[indexPath.section][indexPath.row] = text
    }
    
    func submit(response: @escaping GenerateAccountResponseClosure) {
        guard let email = values[0][0] else {
            response(.failure(error: .unexpectedDataType))
            return
        }
        guard let password = values[0][1] else {
            response(.failure(error: .unexpectedDataType))
            return
        }
        service.generateAccount(email: email, password: password) { result in
            response(result)
        }
    }
    
    func show2FA(response: RegistrationResponse) {
        guard let email = values[0][0] else { return }
        self.navigationCoordinator?.performTransition(transition: .show2FA(email, response))
    }
}

