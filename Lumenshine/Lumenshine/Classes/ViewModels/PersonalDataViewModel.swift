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
    var subItems: [String] { get }
    var isFiltering: Bool { get set }
    
    var dataChangedClosure: (() -> ())? { get set }
    var cellSizeRefreshCallback: (() -> ())? { get set }
    
    func sectionTitle(at section: Int) -> String?
    func placeholder(at indexPath: IndexPath) -> String?
    func cellHeight(at indexPath: IndexPath) -> CGFloat
    func cellHeightChanged(_ height: CGFloat, at indexPath: IndexPath)
    func cellIdentifier(at indexPath: IndexPath) -> String
    func textValue(at indexPath: IndexPath) -> String?
    func keyboardType(at indexPath: IndexPath) -> UIKeyboardType
    func inputViewOptions(at indexPath: IndexPath) -> ([String]?, Int?)
    func isDateInputView(at indexPath: IndexPath) -> Bool
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath)
    func shouldBeginEditing(at indexPath: IndexPath) -> Bool
    func submit(response: @escaping EmptyResponseClosure)
    
    func subItemSelected(at indexPath: IndexPath)
    func filterSubItems(searchText: String)
    func subListTitle() -> String?
    var isDataChanged: Bool { get }
}

class PersonalDataViewModel : PersonalDataViewModelType {
    
    fileprivate let service: UserDataService
    fileprivate let entries: [[PersonalDataEntry]]
    fileprivate var selectedValues: [PersonalDataEntry:PersonalDataProtocol] = [:]
    fileprivate var cellHeights: [PersonalDataEntry:CGFloat] = [:]
    fileprivate let normalCellHeight: CGFloat = 25
    fileprivate var salutations: [String]?
    fileprivate var userData: UserData?
    
    fileprivate var countries: [CountryResponse]?
    fileprivate var languages: [LanguageResponse]?
    fileprivate var occupations: [Occupation]?
    
    fileprivate var activeEntry: PersonalDataEntry?
    fileprivate var activeList: [PersonalDataProtocol]?
    fileprivate var filteredActiveList: [PersonalDataProtocol]?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(service: UserDataService) {
        self.service = service
        self.entries = [[.salutation, .lastname, .forename, .additionalName, .countryCode, .state, .city, .zipCode, .address, .mobileNR,
                         .birthday, .birthPlace, .birthCountryCode, .languageCode],
                        [.occupation, .employerName, .employerAddress],
                        [.bankAccountNumber, .bankNumber, .bankPhoneNumber],
                        [.taxID, .taxIDName]]
        
        getSalutationList()
        
        self.service.getUserData { [weak self] result in
            switch result {
            case .success(let response):
                self?.setUserData(response)
            case .failure(let error):
                print("Get user data failure: \(error)")
            }
        }
    }
    
    var dataChangedClosure: (() -> ())?
    var cellSizeRefreshCallback: (() -> ())?
    
    var itemDistribution: [Int] {
        return entries.map { $0.count }
    }
    
    var subItems: [String] {
        let list = isFiltering ? filteredActiveList : activeList
        return list?.map { $0.name } ?? []
    }
    
    var isFiltering: Bool = false
    
    var isDataChanged: Bool = false
    
    func subItemSelected(at indexPath: IndexPath) {
        guard let entry = activeEntry else { return }
        let list = isFiltering ? filteredActiveList : activeList
        
        selectedValues[entry] = list?[indexPath.row]
        isDataChanged = true
        self.dataChangedClosure?()
    }
    
    func filterSubItems(searchText: String) {
        filteredActiveList = activeList?.filter({( entry : PersonalDataProtocol) -> Bool in
            return entry.name.lowercased().contains(searchText.lowercased())
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
    
    func cellHeight(at indexPath: IndexPath) -> CGFloat {
        return (cellHeights[entry(at: indexPath)] ?? normalCellHeight) + 30
    }
    
    func cellHeightChanged(_ height: CGFloat, at indexPath: IndexPath) {
        if height != cellHeights[entry(at: indexPath)] {
            cellHeights[entry(at: indexPath)] = height
            cellSizeRefreshCallback?()
        }
    }
    
    func cellIdentifier(at indexPath: IndexPath) -> String {
        switch entry(at: indexPath) {
        case .occupation, .employerAddress:
            return MultilineInputTableViewCell.CellIdentifier
        default:
            return InputTableViewCell.CellIdentifier
        }
    }
    
    func textValue(at indexPath: IndexPath) -> String? {
        return selectedValues[entry(at: indexPath)]?.name
    }
    
    func inputViewOptions(at indexPath: IndexPath) -> ([String]?, Int?) {
        switch entry(at: indexPath) {
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
        case .mobileNR, .bankPhoneNumber:
            return .phonePad
        default:
            return .default
        }
    }
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath) {
        selectedValues[entry(at: indexPath)] = PersonalData(name: text)
        isDataChanged = true
        self.dataChangedClosure?()
    }
    
    func shouldBeginEditing(at indexPath: IndexPath) -> Bool {
        switch entry(at: indexPath) {
        case .occupation:
            if occupations?.isEmpty ?? true {
                getOccupationList()
            }
            activeList = occupations
        case .languageCode:
            if languages?.isEmpty ?? true {
                getLanguageList()
            }
            activeList = languages
        case .countryCode, .birthCountryCode:
            if countries?.isEmpty ?? true {
                getCountryList()
            }
            activeList = countries
        default: return true
        }
        activeEntry = entry(at: indexPath)
        navigationCoordinator?.performTransition(transition: .showPersonalDataSubList)
        return false
    }
    
    func subListTitle() -> String? {
        switch activeEntry! {
        case .occupation:
            return R.string.localizable.occupation()
        case .languageCode:
            return R.string.localizable.language()
        case .countryCode:
            return R.string.localizable.country()
        case .birthCountryCode:
            return R.string.localizable.birth_country()
        default:
            return nil
        }
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
        var validatedData = Dictionary<PersonalDataEntry, PersonalDataProtocol>()
        validatedData.merge(selectedValues, uniquingKeysWith: {(_, last) in last})
        
        if let email = validatedData[.email], !email.name.isEmail() {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_email()
            return (error, nil)
        }
        
        if let phone = validatedData[.mobileNR]?.name {
            let charSet = CharacterSet(charactersIn: "()-").union(.whitespaces)
            let components = phone.components(separatedBy: charSet)
            let phoneNr = components.joined(separator: "")
            if !phoneNr.isMobilePhone() {
                let error = ErrorResponse()
                error.errorMessage = R.string.localizable.invalid_phone()
                return (error, nil)
            }
            validatedData[.mobileNR] = PersonalData(name: phoneNr)
        }
        
        validatedData.removeValue(forKey: .occupation)
        let tupleArray = validatedData.map { ($0.rawValue, $1.code ?? $1.name) }
        var userData = Dictionary(uniqueKeysWithValues: tupleArray)
        
        if let occupation = selectedValues[.occupation] as? Occupation {
            userData["occupation_name"] = occupation.name
            userData["occupation_code08"] = occupation.code
            userData["occupation_code88"] = occupation.code88
        }
        
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
    
    func getSalutationList() {
        if let path = Bundle.main.path(forResource: "iso_salutations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let decoder = JSONDecoder()
                self.salutations = try decoder.decode(Array<String>.self, from: data)
            } catch {
                print("Failure reading salutations JSON: \(error)")
            }
        }
    }
    
    func getCountryList() {
        if let path = Bundle.main.path(forResource: "iso_countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let decoder = JSONDecoder()
                self.countries = try decoder.decode(Array<CountryResponse>.self, from: data)
            } catch {
                print("Failure reading countries JSON: \(error)")
            }
        }
    }
    
    func getLanguageList() {
        if let path = Bundle.main.path(forResource: "iso_languages", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let decoder = JSONDecoder()
                self.languages = try decoder.decode(Array<LanguageResponse>.self, from: data)
                
            } catch {
                print("Failure reading languages JSON: \(error)")
            }
        }
    }
    
    func setUserData(_ userData: UserData) {
        self.userData = userData
        if countries?.isEmpty ?? true {
            getCountryList()
        }
        if let country = countries?.first(where: {$0.code == userData.countryCode}) {
            selectedValues[.countryCode] = PersonalData(name: country.name, code: country.code)
        }
        if let birthCountry = countries?.first(where: {$0.code == userData.birthCountryCode}) {
            selectedValues[.birthCountryCode] = PersonalData(name: birthCountry.name, code: birthCountry.code)
        }
        
        if languages?.isEmpty ?? true {
            getLanguageList()
        }
        if let lang = languages?.first(where: {$0.code == userData.languageCode}) {
            selectedValues[.languageCode] = PersonalData(name: lang.name, code: lang.code)
        }
        
        selectedValues[.additionalName] = PersonalData(name: userData.additionalName)
        selectedValues[.address] = PersonalData(name: userData.address)
        selectedValues[.bankAccountNumber] = PersonalData(name: userData.bankAccountNumber)
        selectedValues[.bankNumber] = PersonalData(name: userData.bankNumber)
        selectedValues[.bankPhoneNumber] = PersonalData(name: userData.bankPhoneNumber)
        selectedValues[.birthday] = PersonalData(name: DateUtils.shortDateString(from: userData.birthday))
        selectedValues[.birthPlace] = PersonalData(name: userData.birthPlace)
        selectedValues[.city] = PersonalData(name: userData.city)
        selectedValues[.company] = PersonalData(name: userData.company)
        selectedValues[.email] = PersonalData(name: userData.email)
        selectedValues[.employerAddress] = PersonalData(name: userData.employerAddress)
        selectedValues[.employerName] = PersonalData(name: userData.employerName)
        selectedValues[.forename] = PersonalData(name: userData.forename)
        selectedValues[.lastname] = PersonalData(name: userData.lastname)
        selectedValues[.mobileNR] = PersonalData(name: userData.mobileNR)
        selectedValues[.nationality] = PersonalData(name: userData.nationality)
        selectedValues[.occupation] = Occupation(name: userData.occupation, code08: userData.occupationCode08, code88: userData.occupationCode88)
        selectedValues[.registrationDate] = PersonalData(name: DateUtils.shortDateString(from: userData.registrationDate))
        selectedValues[.salutation] = PersonalData(name: userData.salutation)
        selectedValues[.state] = PersonalData(name: userData.state)
        selectedValues[.taxID] = PersonalData(name: userData.taxID)
        selectedValues[.taxIDName] = PersonalData(name: userData.taxIDName)
        selectedValues[.title] = PersonalData(name: userData.title)
        selectedValues[.zipCode] = PersonalData(name: userData.zipCode)
    }
}


