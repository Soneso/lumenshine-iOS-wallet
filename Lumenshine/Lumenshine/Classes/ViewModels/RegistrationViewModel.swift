//
//  RegistrationViewModel.swift
//  Lumenshine
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
    func show2FA(response: RegistrationResponse, userSecurity: UserSecurity)
    func checkUserSecurity(_ userSecurity: UserSecurity, response: @escaping EmptyResponseClosure)
}

class RegistrationViewModel : RegistrationViewModelType {
    
    fileprivate let service: AuthService
    
    var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
        values = items.map { value in
            return Array<String?>(repeating: nil, count: value.count)
        }
    }
    
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
    
    func show2FA(response: RegistrationResponse, userSecurity: UserSecurity) {
        guard let email = values[0][0] else { return }
        let user = User(id: "1", email: email, publicKeyIndex188: userSecurity.publicKeyIndex188, mnemonic: userSecurity.mnemonic24Word)
        self.navigationCoordinator?.performTransition(transition: .show2FA(user, response))
    }
    
    func checkUserSecurity(_ userSecurity: UserSecurity, response: @escaping EmptyResponseClosure) {
        guard let email = values[0][0] else { return }
        self.service.loginStep2(publicKeyIndex188: userSecurity.publicKeyIndex188) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let login2Response):
                    let user = User(id: "1", email: email, publicKeyIndex188: userSecurity.publicKeyIndex188, mnemonic: userSecurity.mnemonic24Word)
                    let loginViewModel = LoginViewModel(service: self.service, user: user)
                    loginViewModel.navigationCoordinator = self.navigationCoordinator
                    loginViewModel.verifyLogin2Response(login2Response)
                case .failure(let error):
                    response(EmptyResponseEnum.failure(error: error))
                }
            }
        }
    }
}

