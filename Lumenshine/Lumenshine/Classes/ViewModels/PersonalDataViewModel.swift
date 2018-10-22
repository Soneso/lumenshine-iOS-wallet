//
//  PersonalDataViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/17/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UITextInputTraits

protocol PersonalDataViewModelType: Transitionable {
    var itemDistribution: [Int] { get }
    var occupationList: [String] { get }
    var isFiltering: Bool { get set }
    
    func setupOccupations()
    func occupationSelected(at indexPath: IndexPath)
    func saveSelectedOccupation()
    func filterItems(searchText: String)
    func sectionTitle(at section: Int) -> String?
    func placeholder(at indexPath: IndexPath) -> String?
    func textValue(at indexPath: IndexPath) -> String?
    func keyboardType(at indexPath: IndexPath) -> UIKeyboardType
    func inputViewOptions(at indexPath: IndexPath) -> ([String]?, Int?)
    func isDateInputView(at indexPath: IndexPath) -> Bool
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath)
    func shouldBeginEditing(at indexPath: IndexPath) -> Bool
    func submit(response: @escaping EmptyResponseClosure)
}

class PersonalDataViewModel : PersonalDataViewModelType {
    
    fileprivate let service: UserDataService
    fileprivate let entries: [[PersonalDataEntry]]
    fileprivate var selectedValues: [PersonalDataEntry:String] = [:]
    fileprivate var countries: [CountryResponse]?
    fileprivate var salutations: [String]?
    fileprivate var occupations: [Occupation]?
    fileprivate var filteredOccupations: [Occupation]?
    fileprivate var selectedOccupation: Occupation?
    fileprivate var userData: UserData?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: UserDataService) {
        self.service = service
        self.entries = [[.salutation, .lastname, .forename, .additionalName, .countryCode, .state, .city, .zipCode, .address, .mobileNR,
                         .birthday, .birthPlace, .birthCountryCode, .languageCode],
                        [.occupation, .employerName, .employerAddress],
                        [.bankAccountNumber, .bankNumber, .bankPhoneNumber],
                        [.taxID, .taxIDName]]
        
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
        
        self.service.getUserData { [weak self] result in
            switch result {
            case .success(let response):
                self?.setUserData(response)
            case .failure(let error):
                print("Get user data failure: \(error)")
            }
        }
    }
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    var occupationList: [String] {
        let list = isFiltering ? filteredOccupations : occupations
        return list?.map { $0.name } ?? []
    }
    
    var isFiltering: Bool = false
    
    func setupOccupations() {
        if occupations?.isEmpty ?? true {
            getOccupationList()
        }
    }
    
    func occupationSelected(at indexPath: IndexPath) {
        let list = isFiltering ? filteredOccupations : occupations
        selectedOccupation = list?[indexPath.row]
    }
    
    func saveSelectedOccupation() {
        selectedValues[.occupation] = selectedOccupation?.name
    }
    
    func filterItems(searchText: String) {
        filteredOccupations = occupations?.filter({( occupation : Occupation) -> Bool in
            return occupation.name.lowercased().contains(searchText.lowercased())
        })
    }
    
    func sectionTitle(at section: Int) -> String? {
        switch section {
        case 0:
            return R.string.localizable.my_data()
        case 1:
            return R.string.localizable.my_occupation()
        case 2:
            return R.string.localizable.my_bank_account()
        case 3:
            return R.string.localizable.my_tax_info()
        default:
            return nil
        }
    }
    
    func placeholder(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).placeholder
    }
    
    func textValue(at indexPath: IndexPath) -> String? {
        return selectedValues[entry(at: indexPath)]
    }
    
    func inputViewOptions(at indexPath: IndexPath) -> ([String]?, Int?) {
        switch entry(at: indexPath) {
        case .countryCode:
            return (countries?.map { $0.code }, nil)
        case .salutation:
            return (salutations, nil)
        default: break
        }
        return (nil, nil)
    }
    
    func isDateInputView(at indexPath: IndexPath) -> Bool {
        switch entry(at: indexPath) {
        case .birthday:
            return true
        default:
            return false
        }
    }
    
    func keyboardType(at indexPath: IndexPath) -> UIKeyboardType {
        switch entry(at: indexPath) {
        case .email:
            return .emailAddress
        case .zipCode:
            return .decimalPad
        case .mobileNR:
            return .phonePad
        default:
            return .default
        }
    }
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath) {
        selectedValues[entry(at: indexPath)] = text
    }
    
    func shouldBeginEditing(at indexPath: IndexPath) -> Bool {
        switch entry(at: indexPath) {
        case .occupation:
            navigationCoordinator?.performTransition(transition: .showOccupationList)
            return false
        default: break
        }
        return true
    }
    
    func submit(response: @escaping EmptyResponseClosure) {
        let (error, validatedData) = validateUserData()
        if let err = error {
            response(.failure(error: .validationFailed(error: err)))
            return
        }
        
        service.updateUserData(userData: validatedData!, response: response)
    }

}

fileprivate extension PersonalDataViewModel {
    func entry(at indexPath: IndexPath) -> PersonalDataEntry {
        return entries[indexPath.section][indexPath.row]
    }
    
    func validateUserData() -> (ErrorResponse?, Dictionary<String,String>?) {
        var validatedData = Dictionary<PersonalDataEntry,String>()
        validatedData.merge(selectedValues, uniquingKeysWith: {(_, last) in last})
        
        if let email = validatedData[.email], !email.isEmail() {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_email()
            return (error, nil)
        }
        
        if let phone = validatedData[.mobileNR] {
            let charSet = CharacterSet(charactersIn: "()-").union(.whitespaces)
            let components = phone.components(separatedBy: charSet)
            let phoneNr = components.joined(separator: "")
            if !phoneNr.isMobilePhone() {
                let error = ErrorResponse()
                error.errorMessage = R.string.localizable.invalid_phone()
                return (error, nil)
            }
            validatedData[.mobileNR] = phoneNr
        }
        
        if let nationalityName = validatedData[.nationality] {
            let nationality = countries?.filter {
                $0.name == nationalityName
            }
            validatedData[.nationality] = nationality?.first?.code
        }
        
        let tupleArray = validatedData.map { ($0.rawValue, $1) }
        let userData = Dictionary(uniqueKeysWithValues: tupleArray)
        
        return (nil, userData)
    }
    
    func getOccupationList() {
        if let path = Bundle.main.path(forResource: "occupations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let decoder = JSONDecoder()
                self.occupations = try decoder.decode(Array<Occupation>.self, from: data)
                
            } catch {
                print("Failure reading Occupation JSON: \(error)")
            }
        }
    }
    
    func setUserData(_ userData: UserData) {
        self.userData = userData
        selectedValues[.additionalName] = userData.additionalName
        selectedValues[.address] = userData.address
        selectedValues[.bankAccountNumber] = userData.bankAccountNumber
        selectedValues[.bankNumber] = userData.bankNumber
        selectedValues[.bankPhoneNumber] = userData.bankPhoneNumber
        selectedValues[.birthCountryCode] = userData.birthCountryCode
        selectedValues[.birthday] = DateUtils.shortDateString(from: userData.birthday)
        selectedValues[.birthPlace] = userData.birthPlace
        selectedValues[.city] = userData.city
        selectedValues[.company] = userData.company
        selectedValues[.countryCode] = userData.countryCode
        selectedValues[.email] = userData.email
        selectedValues[.employerAddress] = userData.employerAddress
        selectedValues[.employerName] = userData.employerName
        selectedValues[.forename] = userData.forename
        selectedValues[.languageCode] = userData.languageCode
        selectedValues[.lastname] = userData.lastname
        selectedValues[.mobileNR] = userData.mobileNR
        selectedValues[.nationality] = userData.nationality
        selectedValues[.occupation] = userData.occupation
        selectedValues[.registrationDate] = DateUtils.shortDateString(from: userData.registrationDate)
        selectedValues[.salutation] = userData.salutation
        selectedValues[.state] = userData.state
        selectedValues[.taxID] = userData.taxID
        selectedValues[.taxIDName] = userData.taxIDName
        selectedValues[.title] = userData.title
        selectedValues[.zipCode] = userData.zipCode
    }
}


