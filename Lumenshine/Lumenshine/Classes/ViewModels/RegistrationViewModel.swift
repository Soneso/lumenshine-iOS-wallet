//
//  RegistrationViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UITextInputTraits

protocol RegistrationViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    var sectionTitles: [String] { get }
    func textIsSecure(at indexPath: IndexPath) -> Bool
    func placeholder(at indexPath: IndexPath) -> String?
    func textValue(at indexPath: IndexPath) -> String?
    func inputViewOptions(at indexPath: IndexPath) -> ([String]?, Bool?, Int?)
    func keyboardType(at indexPath: IndexPath) -> UIKeyboardType
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath)
    func submit(response: @escaping GenerateAccountResponseClosure)
    func show2FA(response: RegistrationResponse, userSecurity: UserSecurity)
    func checkUserSecurity(_ userSecurity: UserSecurity, response: @escaping EmptyResponseClosure)
}

class RegistrationViewModel : RegistrationViewModelType {
    
    fileprivate let service: AuthService
    fileprivate let entries: [[RegistrationEntry]]
    fileprivate var selectedValues: [RegistrationEntry:String] = [:]
    fileprivate var countries: [CountryResponse]?
    fileprivate var salutations: [String]?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: AuthService) {
        self.service = service
        self.entries = [[.email, .password],
                        [.forename, .lastname, .company, .salutation, .title, .street, .streetNr,
                         .zipCode, .city, .state, .country, .nationality, .phone, .birthday, .birthplace]]
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
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
        return selectedValues[entry(at: indexPath)]
    }
    
    func inputViewOptions(at indexPath: IndexPath) -> ([String]?, Bool?, Int?) {
        switch entry(at: indexPath) {
        case .country, .nationality:
            return (countries?.map { $0.name }, nil, nil)
        case .salutation:
            return (salutations, nil, nil)
        case .birthday:
            return (nil, true, nil)
        default: break
        }
        return (nil, nil, nil)
    }
    
    func keyboardType(at indexPath: IndexPath) -> UIKeyboardType {
        switch entry(at: indexPath) {
        case .email:
            return .emailAddress
        case .zipCode:
            return .decimalPad
        case .phone:
            return .phonePad
        default:
            return .default
        }
    }
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath) {
        selectedValues[entry(at: indexPath)] = text
    }
    
    func submit(response: @escaping GenerateAccountResponseClosure) {        
        let (error, validatedData) = validateUserData()
        if let err = error {
            response(.failure(error: .validationFailed(error: err)))
            return
        }
        
        let password = selectedValues.removeValue(forKey: .password)
        
        service.generateAccount(email: selectedValues[.email]!, password: password!, userData: validatedData!) { result in
            response(result)
        }
    }
    
    func show2FA(response: RegistrationResponse, userSecurity: UserSecurity) {
    }
    
    func checkUserSecurity(_ userSecurity: UserSecurity, response: @escaping EmptyResponseClosure) {
    }
}

fileprivate extension RegistrationViewModel {
    func entry(at indexPath: IndexPath) -> RegistrationEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func validateUserData() -> (ErrorResponse?, Dictionary<String,String>?) {
        var validatedData = Dictionary<RegistrationEntry,String>()
        validatedData.merge(selectedValues, uniquingKeysWith: {(_, last) in last})
        
        guard let email = validatedData[.email], email.isEmail() else {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_email()
            return (error, nil)
        }
        
        guard let password = validatedData[.password], password.isValidPassword() else {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_password()
            return (error, nil)
        }
        
        if let phone = validatedData[.phone] {
            let charSet = CharacterSet(charactersIn: "()-").union(.whitespaces)
            let components = phone.components(separatedBy: charSet)
            let phoneNr = components.joined(separator: "")
            if !phoneNr.isMobilePhone() {
                let error = ErrorResponse()
                error.errorMessage = R.string.localizable.invalid_phone()
                return (error, nil)
            }
            validatedData[.phone] = phoneNr
        }
        
        if let countryName = validatedData[.country] {
            let country = countries?.filter {
                $0.name == countryName
            }
            validatedData[.country] = country?.first?.code
        }
        
        if let nationalityName = validatedData[.nationality] {
            let nationality = countries?.filter {
                $0.name == nationalityName
            }
            validatedData[.nationality] = nationality?.first?.code
        }
        
        validatedData.removeValue(forKey: .password)
        let tupleArray = validatedData.map { ($0.rawValue, $1) }
        let userData = Dictionary(uniqueKeysWithValues: tupleArray)
        
        return (nil, userData)
    }
}

