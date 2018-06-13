//
//  RegistrationViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol RegistrationViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    var sectionTitles: [String] { get }
    func textIsSecure(at indexPath: IndexPath) -> Bool
    func placeholder(at indexPath: IndexPath) -> String?
    func textValue(at indexPath: IndexPath) -> String?
    func inputViewOptions(at indexPath: IndexPath) -> [String]?
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath)
    func submit(response: @escaping GenerateAccountResponseClosure)
    func show2FA(response: RegistrationResponse, userSecurity: UserSecurity)
    func checkUserSecurity(_ userSecurity: UserSecurity, response: @escaping EmptyResponseClosure)
}

class RegistrationViewModel : RegistrationViewModelType {
    
    fileprivate let service: AuthService
    fileprivate let entries: [[RegistrationEntry]]
    fileprivate var values: [[String?]]
    fileprivate var countries: [CountryResponse]?
    fileprivate var salutations: [String]?
    
    var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
        self.entries = [[.email, .password],
                        [.forename, .lastname, .company, .salutation, .title, .street, .streetNr,
                         .zipCode, .city, .state, .country, .nationality, .phone, .birthday, .birthplace]]
        
        values = entries.map { value in
            return Array<String?>(repeating: nil, count: value.count)
        }
        
        self.service.countryList { [weak self] result in
            switch result {
            case .success(let response):
                self?.countries = response.countries
            case .failure(let error):
                print("Get country list failure: \(error.localizedDescription)")
            }
        }
        
        self.service.salutationList { [weak self] result in
            switch result {
            case .success(let response):
                self?.salutations = response.salutations
            case .failure(let error):
                print("Get salutations failure: \(error.localizedDescription)")
            }
        }
    }
    
    var itemDistribution: [Int] {
        return entries.map {
            $0.count
        }
    }
    
    var sectionTitles: [String] = [
        R.string.localizable.account_data_title(),
        R.string.localizable.user_data_title()
    ]
    
    func placeholder(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).placeholder
    }
    
    func textIsSecure(at indexPath: IndexPath) -> Bool {
        return entry(at: indexPath).secureText
    }
    
    func textValue(at indexPath: IndexPath) -> String? {
        return values[indexPath.section][indexPath.row]
    }
    
    func inputViewOptions(at indexPath: IndexPath) -> [String]? {
        switch entry(at: indexPath) {
        case .country, .nationality:
            return countries?.map {
                $0.name
            }
        case .salutation:
            return salutations
        default: break
        }
        return nil
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

fileprivate extension RegistrationViewModel {
    func entry(at indexPath: IndexPath) -> RegistrationEntry {
        return entries[indexPath.section][indexPath.row]
    }
}

